#!/bin/bash

if (( ${BASH_VERSION%%.*} < 4 )); then echo "ERROR: [bash] version 4.0+ required!" ; exit -1 ; fi

SELF_DIR="$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"


LOGS_DIR="$1"
[ -d "$LOGS_DIR" ]        || { echo "Logs directory [$LOGS_DIR] not found." ; exit 1 ; }

BENCHMARKS_DIR="`realpath $2`"
[ -d "$BENCHMARKS_DIR" ]  || { echo "Benchmarks directory [$BENCHMARKS_DIR] not found." ; exit 1 ; }

RESULTS_FILE="$LOGS_DIR/results.csv"
[ -f "$RESULTS_FILE" ]    || { echo "'results.csv' not found in $LOGS_DIR." ;  exit 1 ; }


cat "$RESULTS_FILE" | head -n 1 | tr '\n' ','
echo 'Rounds'

for TESTCASE in `find "$BENCHMARKS_DIR" -name *.sl` ; do
  TESTCASE_NAME=${TESTCASE#$BENCHMARKS_DIR/}
  TESTCASE_NAME=${TESTCASE_NAME%.sl}
  TESTCASE_PREFIX="$LOGS_DIR/$TESTCASE_NAME"

  grep "$TESTCASE" "$RESULTS_FILE" | tr '\n' ','
  if [ -f "$TESTCASE_PREFIX.stats" ]; then
    "$SELF_DIR/count_rounds.sh" "$TESTCASE_PREFIX.stats"
  else
    echo "-"
  fi
done
