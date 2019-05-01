#!/bin/bash

if (( ${BASH_VERSION%%.*} < 4 )); then echo "ERROR: [bash] version 4.0+ required!" ; exit -1 ; fi

SELF_DIR="$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

trap 'kill -TERM -$INFER_PID > /dev/null 2> /dev/null' INT
trap "kill -KILL -`ps -o pgid= $$` > /dev/null 2> /dev/null" QUIT TERM

SYGUS_EXT=".sl"
MODE="rerun-failed"

SKIP_MARK="[SKIPPED] "
CONTINUE_FROM="1"
CONTINUE_TILL="1000000000"
BENCHMARKS_DIR=""
LOGS_DIR="$SELF_DIR/_log_all.$(date -d today +%Y.%m.%d-%H.%M)"
Z3_PATH="$SELF_DIR/_dep/z3"

TOOL=""
TIMEOUT="60"
VERIFY="$SELF_DIR/_build/install/default/bin/verify"
ORIGINAL_VERIFY_ARGS=""

show_status() {
  printf "%s%16s" "$1" >&2
  printf %0"$(( ${#1} + 16 ))"d | tr 0 \\b >&2
}

usage() {
  if [ -n "$1" ]; then echo -e "\nERROR: $1" >&2 ; fi
  echo -en "
Usage: $0 [options] -b <benchmarks_path> -- [tool specific options]


Flags:
    [--no-skipped-mark, -n]

Configuration:
    --benchmarks, -b <path>
    [--mode, -m <mode>]               (rerun-failed)\t mode <- {rerun-failed|rerun-all|reverify}
    [--continue-from, -c <int>]       ($CONTINUE_FROM)
    [--continue-till, -C <int>]       ($CONTINUE_TILL)
    [--logs-dir, -l <path>]           ($LOGS_DIR)
    [--time-out, -t <seconds>]        ($TIMEOUT)
    [--tool, -T <path>]               ($TOOL)
    [--z3-path, -z <path>]            ($Z3_PATH)

Arguments to Internal Programs (@ `dirname $VERIFY`):
    [--Verify-args, -V \"<args>\"]    see \``basename "$VERIFY"` -h\` for details


Substitutions supported within [tool specific options] and [--Verify-args]:

#BENCHMARK_PATH       -> The original path to a benchmark.
#BENCHMARK_OUT_PREFIX -> The path prefix for a benchmark within [--logs-dir].
" 1>&2 ; exit -1
}

OPTS=`getopt -n 'parse-options' -o :b:c:C:l:m:nt:T:V:z: --long benchmarks:,continue-from:,continue-till:,logs-dir:,mode:,no-skipped-mark,time-out:,tool:,Verify-args:,z3-path: -- "$@"`
if [ $? != 0 ]; then usage ; fi

eval set -- "$OPTS"

while true ; do
  case "$1" in
    -b | --benchmarks )
         [ -d "$2" ] || usage "Benchmarks directory [$2] not found."
         BENCHMARKS_DIR="`realpath "$2"`"
         shift ; shift ;;
    -c | --continue-from )
         [ "$2" -gt "0" ] || usage "$2 is not a positive index."
         CONTINUE_FROM="$2"
         shift ; shift ;;
    -C | --continue-till )
         [ "$2" -gt "0" ] || usage "$2 is not a positive index."
         CONTINUE_TILL="$2"
         shift ; shift ;;
    -l | --logs-dir )
         LOGS_DIR="`realpath "$2"`"
         shift ; shift ;;
    -m | --mode )
         case "$2" in
           rerun-failed | rerun-all | reverify ) MODE="$2" ;;
           * ) usage "Invalid mode [$2]."
         esac
         shift ; shift ;;
    -n | --no-skipped-mark )
         SKIP_MARK=""
         shift ;;
    -t | --time-out )
         TIMEOUT="$2"
         shift ; shift ;;
    -T | --tool )
         [ -f "$2" ] || usage "Tool [$2] not found."
         TOOL="$2"
         shift ; shift ;;
    -V | --Verify-args )
         ORIGINAL_VERIFY_ARGS="$2"
         shift ; shift ;;
    -z | --z3-path )
         [ -f "$2" ] || usage "Z3 [$2] not found."
         Z3_PATH="$2"
         shift ; shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

[ -f "$TOOL" ] || usage "Tool [$TOOL] not found."
[ -d "$BENCHMARKS_DIR" ] || usage "Benchmarks directory [$BENCHMARKS_DIR] not found."

if [ "$CONTINUE_TILL" -lt "$CONTINUE_FROM" ]; then
  usage "Start index ($CONTINUE_FROM) >= End Index ($CONTINUE_TILL)!"
fi

[ -d "$LOGS_DIR" ] || mkdir -p "$LOGS_DIR"
[ -d "$LOGS_DIR" ] || usage "Logs directory [$LOGS_DIR] not found."

VERIFY="$VERIFY -z $Z3_PATH"
TIMEOUT="${TIMEOUT}s"

ORIGINAL_TOOL_ARGS="$@"

mkdir -p "$LOGS_DIR"

cd "`dirname "$TOOL"`"
TOOL="./`basename "$TOOL"`"

CSV_RESULTS="$LOGS_DIR/results.csv"
TXT_SUMMARY="$LOGS_DIR/summary.txt"

echo -n "" > "$TXT_SUMMARY"
echo "Benchmark,Verdict,Wall_Time(s),Max_Memory(MB)" > "$CSV_RESULTS"

function parse_stats() {
  TESTCASE_REAL_TIME=`grep "real(s)" $TESTCASE_VERDICT_FILE | cut -f2`
  TESTCASE_MAX_MEMORY=`grep "rss(kb)" $TESTCASE_VERDICT_FILE | cut -f2`
  TESTCASE_MAX_MEMORY=$(( TESTCASE_MAX_MEMORY / 1024 ))
  printf "%8.3fs [%5.0f MB]  @  $1$2" $TESTCASE_REAL_TIME $TESTCASE_MAX_MEMORY
}

COUNTER=0
for TESTCASE in `find "$BENCHMARKS_DIR" -name *$SYGUS_EXT` ; do
  TESTCASE_NAME=${TESTCASE#$BENCHMARKS_DIR/}
  TESTCASE_NAME=${TESTCASE_NAME%$SYGUS_EXT}
  TESTCASE_PREFIX="$LOGS_DIR/$TESTCASE_NAME"

  mkdir -p "`dirname \"$TESTCASE_PREFIX\"`"

  TESTCASE_VERDICT_FILE="$TESTCASE_PREFIX.res"
  TESTCASE_RESULT_FILE="$TESTCASE_PREFIX.inv"
  TESTCASE_STDERR_FILE="$TESTCASE_PREFIX.err"

  TOOL_ARGS="${ORIGINAL_TOOL_ARGS//\#BENCHMARK_PATH/$TESTCASE}"
  TOOL_ARGS="${ORIGINAL_TOOL_ARGS//\#BENCHMARK_OUT_PREFIX/$TESTCASE_PREFIX}"

  VERIFY_ARGS="${ORIGINAL_VERIFY_ARGS//\#BENCHMARK_PATH/$TESTCASE}"
  VERIFY_ARGS="${ORIGINAL_VERIFY_ARGS//\#BENCHMARK_OUT_PREFIX/$TESTCASE_PREFIX}"

  (( COUNTER++ ))
  printf "[%4d] %72s => " $COUNTER $TESTCASE_NAME

  if [ -f "$TESTCASE_VERDICT_FILE" ]; then
    OLD_VERDICT=`tail -n 1 $TESTCASE_VERDICT_FILE`
  fi

  if [ "$CONTINUE_FROM" -gt "$COUNTER" ] || [ "$COUNTER" -gt "$CONTINUE_TILL" ] || ( \
       [ "$MODE" != "rerun-all" ] && [ -f "$TESTCASE_VERDICT_FILE" ] && [[ "$OLD_VERDICT" =~ .*PASS.* ]] \
     ); then
    parse_stats "$SKIP_MARK" "$OLD_VERDICT\n"
    echo "$TESTCASE,$OLD_VERDICT,$TESTCASE_REAL_TIME,$TESTCASE_MAX_MEMORY" >> "$CSV_RESULTS"
    continue
  fi

  if [ "$MODE" != "reverify" ] || [ ! -f "$TESTCASE_RESULT_FILE" ]; then
    echo > $TESTCASE_RESULT_FILE ; echo > $TESTCASE_VERDICT_FILE

    show_status "(inferring)"
    \time --format "\nreal(s)\t%e\nuser(s)\t%U\n sys(s)\t%S\n   cpu%%\t%P\nrss(kb)\t%M\n" \
      bash -c "timeout $TIMEOUT $TOOL $TESTCASE $TOOL_ARGS 2> $TESTCASE_STDERR_FILE" \
      > $TESTCASE_RESULT_FILE 2> $TESTCASE_VERDICT_FILE &
    INFER_PID=$!
    wait $INFER_PID
    INFER_RESULT_CODE=$?

    if [ $INFER_RESULT_CODE == 124 ] || [ $INFER_RESULT_CODE == 137 ]; then
      echo -n "[TIMEOUT] " >> $TESTCASE_VERDICT_FILE
    fi
  else
    head -n -1 "$TESTCASE_VERDICT_FILE" > "$TESTCASE_PREFIX.tmp"
    mv "$TESTCASE_PREFIX.tmp" "$TESTCASE_VERDICT_FILE"
    if [[ "$OLD_VERDICT" =~ .*TIMEOUT.* ]]; then
      echo -n "[TIMEOUT] " >> $TESTCASE_VERDICT_FILE
    fi
  fi

  parse_stats "" ""

  show_status "(verifying)"
  RESULT_CODE=0
  timeout 120s $VERIFY -s $TESTCASE $VERIFY_ARGS "$TESTCASE_RESULT_FILE" >> "$TESTCASE_VERDICT_FILE"
  RESULT_CODE=$?
  if [ $RESULT_CODE == 124 ] || [ $RESULT_CODE == 137 ]; then
    echo "UNKNOWN" >> $TESTCASE_VERDICT_FILE
  fi
  VERDICT=`tail -n 1 $TESTCASE_VERDICT_FILE`
  show_status "" ; echo "$VERDICT"

  echo "$TESTCASE,$VERDICT,$TESTCASE_REAL_TIME,$TESTCASE_MAX_MEMORY" >> "$CSV_RESULTS"
done

print_counts () {
  while (( "$#" )) ; do
    echo -n "* $1 = " | tee -a "$TXT_SUMMARY"
    grep -e ",$2," "$CSV_RESULTS" | wc -l | tee -a "$TXT_SUMMARY"
    shift ; shift
  done
}

echo ""
print_counts TOTAL_PASS ".*PASS.*" TOTAL_FAIL ".*FAIL.*"

echo "" | tee -a "$TXT_SUMMARY"
print_counts "PASS" "PASS" \
             "PASS (NO SOLUTION)" "PASS (NO SOLUTION)" \
             "[TIMEOUT] PASS (NO SOLUTION)" "\\[TIMEOUT\\] PASS (NO SOLUTION)"

echo "" | tee -a "$TXT_SUMMARY"
print_counts "UNKNOWN" ".*UNKNOWN.*"

echo "" | tee -a "$TXT_SUMMARY"
print_counts "FAIL" "FAIL {.*}" \
             "FAIL (NO SOLUTION)" "FAIL (NO SOLUTION)" \
             "[TIMEOUT] FAIL" "\\[TIMEOUT\\] FAIL {.*}" \
             "[TIMEOUT] FAIL (NO SOLUTION)" "\\[TIMEOUT\\] FAIL (NO SOLUTION)"

echo -e "\nPASS Stats:" | tee -a "$TXT_SUMMARY"
awk -F',' '{
  if (NR == 1) { header = $3 ; next }
  if ($2 !~ /^PASS$/) { next }

  data[i++] = $3 ; sum += $3
  if (min == "") {
    min = max = $3
    min_file = max_file = $1
  }

  if ($3 > max) { max = $3 ; max_file = $1 }
  else if ($3 < min) { min = $3 ; min_file = $1 }
} END {
  printf "MIN(%s) = %0.3f  [%s]\n", header, min, min_file
  printf "MED(%s) = %0.3f\n", header, data[int((i-1)/2)]
  printf "AVG(%s) = %0.3f\n", header, sum/i
  printf "MAX(%s) = %0.3f  [%s]\n", header, max, max_file
  printf "SUM(%s) = %0.3f\n", header, sum
}' "$CSV_RESULTS" | tee -a "$TXT_SUMMARY"

echo -e "\n# Detailed results have been saved to: $CSV_RESULTS.\n# A text summary has been saved to:    $TXT_SUMMARY."
