SHELL := /bin/bash

ROOT := /home/cav/Desktop/CAV_100
TIME = /usr/bin/time --format "\ntime: \t%es"

LoopInvGen_variants := tools/_LoopInvGen.Equalities_
LoopInvGen_variants += tools/_LoopInvGen.Intervals_
LoopInvGen_variants += tools/_LoopInvGen.Octagons_
LoopInvGen_variants += tools/_LoopInvGen.Polyhedra_
LoopInvGen_variants += tools/_LoopInvGen.Polynomials_
LoopInvGen_variants += tools/_LoopInvGen.Peano_



.SILENT :
.ONESHELL :
.NOTPARALLEL :

.PHONY : all clean clean_loopinvgen_variants motivating_example reset transform

# #
# END OF : PRELUDE
# #

error :
	echo "Please provide a target to \`make\` (do NOT ignore surrounding quotes)"
	echo "--------------------------------------------------------------------"
	echo "  > motivating_example:"
	echo "    [Estimated time: ~5 mins]"
	echo "      + Generates Fig. 5(a) by running LoopInvGen on the motivating"
	echo "        example (Fig.4) with each of the six grammars."
	echo ""
	echo "  > \"competition(TIMEOUT)\":"
	echo "    [Estimated time: ~6 hours at TIMEOUT = 900]"
	echo "      + Generates data supporting the claims made in Section 5.3"
	echo "        regarding performance of LIG vs LoopInvGen+HE."
	echo "      + TIMEOUT is an integer value (number of seconds)."
	echo "        We used TIMEOUT = 900 for the results reported in the paper."
	echo ""
	echo "  > \"expressiveness(TIMEOUT)\":"
	echo "    [Estimated time: ~20 days at TIMEOUT = 1800]"
	echo "      + Generates Fig. 2, Fig. 3, Fig. 7 and Fig. 8 by running each"
	echo "        benchmark (180) on all solvers including LoopInvGen+HE (6)"
	echo "        with each grammar (6) from Fig. 1."
	echo "      + TIMEOUT is an integer value (number of seconds)."
	echo "        We used TIMEOUT = 1800 for the results reported in the paper."
	echo "      + Recommendation:"
	echo "          - Use TIMEOUT = 180, i.e. 3 mins first."
	echo "            The generated plots and data should still exhibit the"
	echo "            trends claimed in the paper, and it should take no more"
	echo "            than 2 - 3 days."
	echo ""
	echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "
	echo ""
	echo "  > dependencies:"
	echo "      - Builds ALL LoopInvGen variants and other dependencies."
	echo ""
	echo "  > clean:"
	echo "      - Removes ALL generated files."
	exit 255


clean :
	rm -rf tools/_*_ _output_
	cd tools/compare ; dune clean


dependencies : clean_loopinvgen_variants tools/_LIG+HE_ transform
	echo "Everything built!"



competition(%) : tools/_LIG+HE_
	rm -rf _output_/competition_@_$*
	mkdir -p _output_/competition_@_$*/details
	cd tools/LIG/bin
	rm -rf *.r* *.pro *.states
	cd "${ROOT}/tools/_LIG+HE_"
	./build_all.sh -S > /dev/null 2> /dev/null
	###
	echo "=> Running 'LIG+HE' on 'benchmarks/SyGuS-Comp18' ..."
	./test_all.sh -T "starexec/bin/starexec_run_default" -b "${ROOT}/benchmarks/SyGuS-Comp18" \
								-t "$*" -l "${ROOT}/_output_/competition_@_$*/details/LIG+HE_logs"
	###
	echo "=> Running 'LIG' on 'benchmarks/SyGuS-Comp18' ..."
	./test_all.sh -T "../LIG/bin/starexec_run_default" -b "${ROOT}/benchmarks/SyGuS-Comp18" \
								-t "$*" -l "${ROOT}/_output_/competition_@_$*/details/LIG_logs"
	###
	cd "${ROOT}/_output_/competition_@_$*/details"
	LIGHE_SOLVED=`grep ",PASS," "LIG+HE_logs/results.csv" | wc -l`
	LIGHE_SOLVE_TIME=`grep ",PASS," "LIG+HE_logs/results.csv" | cut -d',' -f3 | datamash sum 1`
	LIG_SOLVED=`grep ",PASS," "LIG_logs/results.csv"| wc -l`
	LIG_SOLVE_TIME=`grep ",PASS," "LIG_logs/results.csv" | cut -d',' -f3 | datamash sum 1`
	###
	echo ""
	echo "#) Performance summary:" | tee "../Section_5.3_competition_report.txt"
	echo -e "  + LIG:     Solved = $${LIG_SOLVED},\t Time = $${LIG_SOLVE_TIME}s" | tee -a "../Section_5.3_competition_report.txt"
	echo -e "  + LIG+HE:  Solved = $${LIGHE_SOLVED},\t Time = $${LIGHE_SOLVE_TIME}s" | tee -a "../Section_5.3_competition_report.txt"
	echo -e "\n- - - - - - - -\n"
	echo "*) A brief summary of results has been saved to '_output_/competition_@_$*/Section_5.3_competition_report.txt'."
	echo "*) Check '_output_/competition_@_$*/details' for full logs."


expressiveness(%) : cvc4_results(%) \
										eusolver_results(%) \
										loopinvgen_results(%) \
										sketchac_results(%) \
										stoch_results(%) \
										loopinvgen_he_results(%)
	cd "${ROOT}/_output_/expressiveness_@_$*/details"
	"${ROOT}/scripts/plot_overfitting.py"	LoopInvGen "./LoopInvGen/report.csv" \
																				SketchAC   "./SketchAC/report.csv" \
																				EUSolver   "./EUSolver/report.csv" \
																				CVC4       "./CVC4/report.csv" \
																			  Stoch      "./Stoch/report.csv" \
																				"../Fig_2_overfitting_plot.pdf"
	"${ROOT}/scripts/plot_plearn_vs_he.py" "./LoopInvGen/report.csv" \
																				 "./LoopInvGen+HE/report.csv" \
																				 "../Fig_8a_PLearn_vs_HE.pdf"
	"${ROOT}/scripts/compare_performance.py" "PLearn(LoopInvGen)" "./LoopInvGen/PLearn_perf_report.csv" \
																					 "LoopInvGen+HE"			"./LoopInvGen+HE/perf_report.csv" \
																					 "LoopInvGen"					"./LoopInvGen/perf_report.csv" \
																					 > "../Fig_8b_performance_data.csv"
	echo -e "\n- - - - - - - -\n"
	echo "*) The following files have been generated in '_output_/expressiveness_@_$*':"
	echo "     + Fig_2_overfitting_plot.pdf"
	echo "     + Fig_3_correlation_report.txt"
	echo "     + Fig_7a_LoopInvGen_PLearn.pdf"
	echo "     + Fig_7b_CVC4_PLearn.pdf"
	echo "     + Fig_7c_Stoch_PLearn.pdf"
	echo "     + Fig_7d_SketchAC_PLearn.pdf"
	echo "     + Fig_7e_EUSolver_PLearn.pdf"
	echo "     + Fig_8a_PLearn_vs_HE.pdf"
	echo "     + Fig_8b_performance_report.txt"
	echo "*) Check '_output_/expressiveness_@_$*/details' for more details."


motivating_example : clean_loopinvgen_variants
	rm -rf _output_/motivating_example
	mkdir -p _output_/motivating_example/details
	cd _output_/motivating_example
	###
	echo -e "\n=> Running 'LoopInvGen.Equalities' on 'fib_19.sl' ..." | tee -a Fig_5a_motivating_example_report.txt
	${TIME} bash -c "${ROOT}/tools/_LoopInvGen.Equalities_/loopinvgen.sh -S ./details/Equalities.stats \
											${ROOT}/benchmarks/set_logic_XIA/LIA/2017.ASE_FiB/fib_19.sl \
										2> /dev/null" |& tee -a Fig_5a_motivating_example_report.txt
	echo -n "rounds: " | tee -a Fig_5a_motivating_example_report.txt
	"${ROOT}/scripts/count_rounds.sh" ./details/Equalities.stats | tee -a Fig_5a_motivating_example_report.txt
	echo -e "\n- - - - - - - -\n" | tee -a Fig_5a_motivating_example_report.txt
	###
	echo -e "\n=> Running 'LoopInvGen.Intervals' on 'fib_19.sl' ..." | tee -a Fig_5a_motivating_example_report.txt
	${TIME} bash -c "${ROOT}/tools/_LoopInvGen.Intervals_/loopinvgen.sh -S ./details/Intervals.stats \
											${ROOT}/benchmarks/set_logic_XIA/LIA/2017.ASE_FiB/fib_19.sl \
										2> /dev/null" |& tee -a Fig_5a_motivating_example_report.txt
	echo -n "rounds: " | tee -a Fig_5a_motivating_example_report.txt
	"${ROOT}/scripts/count_rounds.sh" ./details/Intervals.stats | tee -a Fig_5a_motivating_example_report.txt
	echo -e "\n- - - - - - - -\n" | tee -a Fig_5a_motivating_example_report.txt
	###
	echo -e "\n=> Running 'LoopInvGen.Octagons' on 'fib_19.sl' ..." | tee -a Fig_5a_motivating_example_report.txt
	${TIME} bash -c "${ROOT}/tools/_LoopInvGen.Octagons_/loopinvgen.sh -S ./details/Octagons.stats \
											${ROOT}/benchmarks/set_logic_XIA/LIA/2017.ASE_FiB/fib_19.sl \
										2> /dev/null" |& tee -a Fig_5a_motivating_example_report.txt
	echo -n "rounds: " | tee -a Fig_5a_motivating_example_report.txt
	"${ROOT}/scripts/count_rounds.sh" ./details/Octagons.stats | tee -a Fig_5a_motivating_example_report.txt
	echo -e "\n- - - - - - - -\n" | tee -a Fig_5a_motivating_example_report.txt
	###
	echo -e "\n=> Running 'LoopInvGen.Polyhedra' on 'fib_19.sl' ..." | tee -a Fig_5a_motivating_example_report.txt
	${TIME} bash -c "${ROOT}/tools/_LoopInvGen.Polyhedra_/loopinvgen.sh -S ./details/Polyhedra.stats \
											${ROOT}/benchmarks/set_logic_XIA/LIA/2017.ASE_FiB/fib_19.sl \
										2> /dev/null" |& tee -a Fig_5a_motivating_example_report.txt
	echo -n "rounds: " | tee -a Fig_5a_motivating_example_report.txt
	"${ROOT}/scripts/count_rounds.sh" ./details/Polyhedra.stats | tee -a Fig_5a_motivating_example_report.txt
	echo -e "\n- - - - - - - -\n" | tee -a Fig_5a_motivating_example_report.txt
	###
	echo -e "\n=> Running 'LoopInvGen.Polynomials' on 'fib_19.sl' ..." | tee -a Fig_5a_motivating_example_report.txt
	${TIME} bash -c "${ROOT}/tools/_LoopInvGen.Polynomials_/loopinvgen.sh -S ./details/Polynomials.stats \
											${ROOT}/benchmarks/set_logic_NIA/LIA/2017.ASE_FiB/fib_19.sl \
										2> /dev/null" |& tee -a Fig_5a_motivating_example_report.txt
	echo -n "rounds: " | tee -a Fig_5a_motivating_example_report.txt
	"${ROOT}/scripts/count_rounds.sh" ./details/Polynomials.stats | tee -a Fig_5a_motivating_example_report.txt
	echo -e "\n- - - - - - - -\n" | tee -a Fig_5a_motivating_example_report.txt
	###
	echo -e "\n=> Running 'LoopInvGen.Peano' on 'fib_19.sl' ..." | tee -a Fig_5a_motivating_example_report.txt
	${TIME} bash -c "${ROOT}/tools/_LoopInvGen.Peano_/loopinvgen.sh -S ./details/Peano.stats \
											${ROOT}/benchmarks/set_logic_NIA/LIA/2017.ASE_FiB/fib_19.sl \
										2> /dev/null" |& tee -a Fig_5a_motivating_example_report.txt
	echo -n "rounds: " | tee -a Fig_5a_motivating_example_report.txt
	"${ROOT}/scripts/count_rounds.sh" ./details/Peano.stats | tee -a Fig_5a_motivating_example_report.txt
	echo -e "\n- - - - - - - -\n"
	echo "*) A brief summary has been saved to '_output_/motivating_example/Fig_5a_motivating_example_report.txt'."
	echo "*) Check '_output_/motivating_example/details' for more full stats."


# #
# END OF : PUBLIC TARGETS
# -----------------------
# The targets below this line are only for internal use.
# They should not be invoked directly as `make XXX`.
# #

tools/_%_ : base-LIG/%.patch
	echo "=> Building '$*' ..."
	rm -rf "tools/_$*_"
	cp -r "base-LIG/LoopInvGen+HE" "tools/_$*_"
	cp -r "base-LIG/$*.patch" "tools/_$*_"
	cd "tools/_$*_"
	patch -s -p1 < "$*.patch"
	dune build @NoLog
	./build_all.sh > /dev/null
	cd "${ROOT}"

transform :
	cd tools/compare
	dune build
	cd "${ROOT}"

clean_loopinvgen_variants : | $(LoopInvGen_variants)
	rm -rf tools/_LoopInvGen.*_/_log
	cd "${ROOT}"


cvc4_results(%) : transform
	rm -rf _output_/expressiveness_@_"$*"/details/CVC4/*
	mkdir -p "_output_/expressiveness_@_$*/details/CVC4/Equalities" \
				   "_output_/expressiveness_@_$*/details/CVC4/Intervals" \
				   "_output_/expressiveness_@_$*/details/CVC4/Octagons" \
				   "_output_/expressiveness_@_$*/details/CVC4/Polyhedra" \
				   "_output_/expressiveness_@_$*/details/CVC4/Polynomials" \
				   "_output_/expressiveness_@_$*/details/CVC4/Peano"
	cd tools/compare
	###
	echo "=> Running 'CVC4' on 'set_logic_XIA' with 'Equalities.g' ..."
	./test_all.sh -t "$*" -T "scripts/run-cvc4.sh" -b "${ROOT}/benchmarks/set_logic_XIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/CVC4/Equalities" \
								-- "${ROOT}/grammars/Equalities.g"
	###
	echo "=> Running 'CVC4' on 'set_logic_XIA' with 'Intervals.g' ..."
	./test_all.sh -t "$*" -T "scripts/run-cvc4.sh" -b "${ROOT}/benchmarks/set_logic_XIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/CVC4/Intervals" \
								-- "${ROOT}/grammars/Intervals.g"
	###
	echo "=> Running 'CVC4' on 'set_logic_XIA' with 'Octagons.g' ..."
	./test_all.sh -t "$*" -T "scripts/run-cvc4.sh" -b "${ROOT}/benchmarks/set_logic_XIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/CVC4/Octagons" \
								-- "${ROOT}/grammars/Octagons.g"
	###
	echo "=> Running 'CVC4' on 'set_logic_XIA' with 'Polyhedra.g' ..."
	./test_all.sh -t "$*" -T "scripts/run-cvc4.sh" -b "${ROOT}/benchmarks/set_logic_XIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/CVC4/Polyhedra" \
								-- "${ROOT}/grammars/Polyhedra.g"
	###
	echo "=> Running 'CVC4' on 'set_logic_NIA' with 'Polynomials.g' ..."
	./test_all.sh -t "$*" -T "scripts/run-cvc4.sh" -b "${ROOT}/benchmarks/set_logic_NIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/CVC4/Polynomials" \
								-- "${ROOT}/grammars/Polynomials.g"
	###
	echo "=> Running 'CVC4' on 'set_logic_NIA' with 'Peano.g' ..."
	./test_all.sh -t "$*" -T "scripts/run-cvc4.sh" -b "${ROOT}/benchmarks/set_logic_NIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/CVC4/Peano" \
								-- "${ROOT}/grammars/Peano.g"
	###
	cd "${ROOT}/_output_/expressiveness_@_$*/details/CVC4"
	"${ROOT}/scripts/compute_plearn.py" "Equalities/results.csv" \
																			"Intervals/results.csv" \
																			"Octagons/results.csv" \
																			"Polyhedra/results.csv" \
																			"Polynomials/results.csv" \
																			"Peano/results.csv" \
																			> ./report.csv
	"${ROOT}/scripts/plot_plearn.py" CVC4 report.csv \
																	 "../../Fig_7b_CVC4_PLearn.pdf"
	cd "${ROOT}"

eusolver_results(%) : transform
	rm -rf _output_/expressiveness_@_"$*"/details/EUSolver/*
	mkdir -p "_output_/expressiveness_@_$*/details/EUSolver/Equalities" \
				   "_output_/expressiveness_@_$*/details/EUSolver/Intervals" \
				   "_output_/expressiveness_@_$*/details/EUSolver/Octagons" \
				   "_output_/expressiveness_@_$*/details/EUSolver/Polyhedra" \
				   "_output_/expressiveness_@_$*/details/EUSolver/Polynomials" \
				   "_output_/expressiveness_@_$*/details/EUSolver/Peano"
	cd tools/compare
	###
	echo "=> Running 'EUSolver' on 'set_logic_LIA' with 'Equalities.g' ..."
	./test_all.sh -t "$*" -T "scripts/run-eusolver.sh" -b "${ROOT}/benchmarks/set_logic_LIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/EUSolver/Equalities" \
								-V "-L NIA" -- "${ROOT}/grammars/Equalities.g"
	###
	echo "=> Running 'EUSolver' on 'set_logic_LIA' with 'Intervals.g' ..."
	./test_all.sh -t "$*" -T "scripts/run-eusolver.sh" -b "${ROOT}/benchmarks/set_logic_LIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/EUSolver/Intervals" \
								-V "-L NIA" -- "${ROOT}/grammars/Intervals.g"
	###
	echo "=> Running 'EUSolver' on 'set_logic_LIA' with 'Octagons.g' ..."
	./test_all.sh -t "$*" -T "scripts/run-eusolver.sh" -b "${ROOT}/benchmarks/set_logic_LIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/EUSolver/Octagons" \
								-V "-L NIA" -- "${ROOT}/grammars/Octagons.g"
	###
	echo "=> Running 'EUSolver' on 'set_logic_LIA' with 'Polyhedra.g' ..."
	./test_all.sh -t "$*" -T "scripts/run-eusolver.sh" -b "${ROOT}/benchmarks/set_logic_LIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/EUSolver/Polyhedra" \
								-V "-L NIA" -- "${ROOT}/grammars/Polyhedra.g"
	###
	echo "=> Running 'EUSolver' on 'set_logic_LIA' with 'Polynomials.g' ..."
	./test_all.sh -t "$*" -T "scripts/run-eusolver.sh" -b "${ROOT}/benchmarks/set_logic_LIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/EUSolver/Polynomials" \
								-V "-L NIA" -- "${ROOT}/grammars/Polynomials.g"
	###
	echo "=> Running 'EUSolver' on 'set_logic_LIA' with 'Peano.g' ..."
	./test_all.sh -t "$*" -T "scripts/run-eusolver.sh" -b "${ROOT}/benchmarks/set_logic_LIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/EUSolver/Peano" \
								-V "-L NIA" -- "${ROOT}/grammars/Peano.g"
	###
	cd "${ROOT}/_output_/expressiveness_@_$*/details/EUSolver"
	"${ROOT}/scripts/compute_plearn.py" "Equalities/results.csv" \
																			"Intervals/results.csv" \
																			"Octagons/results.csv" \
																			"Polyhedra/results.csv" \
																			"Polynomials/results.csv" \
																			"Peano/results.csv" \
																			> ./report.csv
	"${ROOT}/scripts/plot_plearn.py" EUSolver report.csv \
																	 "../../Fig_7e_EUSolver_PLearn.pdf"
	cd "${ROOT}"

loopinvgen_results(%) : clean_loopinvgen_variants
	rm -rf _output_/expressiveness_@_"$*"/details/LoopInvGen/*
	mkdir -p "_output_/expressiveness_@_$*/details/LoopInvGen/Equalities" \
				   "_output_/expressiveness_@_$*/details/LoopInvGen/Intervals" \
				   "_output_/expressiveness_@_$*/details/LoopInvGen/Octagons" \
				   "_output_/expressiveness_@_$*/details/LoopInvGen/Polyhedra" \
				   "_output_/expressiveness_@_$*/details/LoopInvGen/Polynomials" \
				   "_output_/expressiveness_@_$*/details/LoopInvGen/Peano"
	###
	echo "=> Running 'LoopInvGen.Equalities' on 'set_logic_XIA' ..."
	cd "${ROOT}/tools/_LoopInvGen.Equalities_"
	./test_all.sh -t "$*" -b "${ROOT}/benchmarks/set_logic_XIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/LoopInvGen/Equalities" \
								-- -S "#BENCHMARK_OUT_PREFIX.stats"
	###
	echo "=> Running 'LoopInvGen.Intervals' on 'set_logic_XIA' ..."
	cd "${ROOT}/tools/_LoopInvGen.Intervals_"
	./test_all.sh -t "$*" -b "${ROOT}/benchmarks/set_logic_XIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/LoopInvGen/Intervals" \
								-- -S "#BENCHMARK_OUT_PREFIX.stats"
	###
	echo "=> Running 'LoopInvGen.Octagons' on 'set_logic_XIA' ..."
	cd "${ROOT}/tools/_LoopInvGen.Octagons_"
	./test_all.sh -t "$*" -b "${ROOT}/benchmarks/set_logic_XIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/LoopInvGen/Octagons" \
								-- -S "#BENCHMARK_OUT_PREFIX.stats"
	###
	echo "=> Running 'LoopInvGen.Polyhedra' on 'set_logic_XIA' ..."
	cd "${ROOT}/tools/_LoopInvGen.Polyhedra_"
	./test_all.sh -t "$*" -b "${ROOT}/benchmarks/set_logic_XIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/LoopInvGen/Polyhedra" \
								-- -S "#BENCHMARK_OUT_PREFIX.stats"
	###
	echo "=> Running 'LoopInvGen.Polynomials' on 'set_logic_NIA' ..."
	cd "${ROOT}/tools/_LoopInvGen.Polynomials_"
	./test_all.sh -t "$*" -b "${ROOT}/benchmarks/set_logic_NIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/LoopInvGen/Polynomials" \
								-- -S "#BENCHMARK_OUT_PREFIX.stats"
	###
	echo "=> Running 'LoopInvGen.Peano' on 'set_logic_NIA' ..."
	cd "${ROOT}/tools/_LoopInvGen.Peano_"
	./test_all.sh -t "$*" -b "${ROOT}/benchmarks/set_logic_NIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/LoopInvGen/Peano" \
								-- -S "#BENCHMARK_OUT_PREFIX.stats"
	###
	cd "${ROOT}/_output_/expressiveness_@_$*/details/LoopInvGen"
	"${ROOT}/scripts/extract_stats.sh" Equalities "${ROOT}/benchmarks/set_logic_XIA" \
																		 > "Equalities/extended_results.csv"
	"${ROOT}/scripts/extract_stats.sh" Intervals "${ROOT}/benchmarks/set_logic_XIA" \
																		 > "Intervals/extended_results.csv"
	"${ROOT}/scripts/extract_stats.sh" Octagons "${ROOT}/benchmarks/set_logic_XIA" \
																		 > "Octagons/extended_results.csv"
	"${ROOT}/scripts/extract_stats.sh" Polyhedra "${ROOT}/benchmarks/set_logic_XIA" \
																		 > "Polyhedra/extended_results.csv"
	"${ROOT}/scripts/extract_stats.sh" Polynomials "${ROOT}/benchmarks/set_logic_NIA" \
																		 > "Polynomials/extended_results.csv"
	"${ROOT}/scripts/extract_stats.sh" Peano "${ROOT}/benchmarks/set_logic_NIA" \
																		 > "Peano/extended_results.csv"
	###
	"${ROOT}/scripts/compute_plearn.py" "Equalities/results.csv" \
																			"Intervals/results.csv" \
																			"Octagons/results.csv" \
																			"Polyhedra/results.csv" \
																			"Polynomials/results.csv" \
																			"Peano/results.csv" \
																			-P "`pwd`/PLearn_perf_report.csv" \
																			-c "`pwd`/perf_report.csv" \
																			> ./report.csv
	"${ROOT}/scripts/plot_plearn.py" LoopInvGen report.csv \
																	 "../../Fig_7a_LoopInvGen_PLearn.pdf"
	"${ROOT}/scripts/compute_correlation.py" "Equalities/extended_results.csv" \
																					 "Intervals/extended_results.csv" \
																					 "Octagons/extended_results.csv" \
																					 "Polyhedra/extended_results.csv" \
																					 "Polynomials/extended_results.csv" \
																					 "Peano/extended_results.csv" \
																					 > ../../Fig_3_correlation_report.txt
	cd "${ROOT}"

loopinvgen_he_results(%) :
	rm -rf _output_/expressiveness_@_"$*"/details/LoopInvGen+HE/*
	mkdir -p "_output_/expressiveness_@_$*/details/LoopInvGen+HE/Equalities" \
				   "_output_/expressiveness_@_$*/details/LoopInvGen+HE/Intervals" \
				   "_output_/expressiveness_@_$*/details/LoopInvGen+HE/Octagons" \
				   "_output_/expressiveness_@_$*/details/LoopInvGen+HE/Polyhedra" \
				   "_output_/expressiveness_@_$*/details/LoopInvGen+HE/Polynomials" \
				   "_output_/expressiveness_@_$*/details/LoopInvGen+HE/Peano"
	cp -r "base-LIG/LoopInvGen+HE" "tools/_LoopInvGen+HE_"
	cd "tools/_LoopInvGen+HE_"
	./build_all.sh > /dev/null
	###
	echo "=> Running 'LoopInvGen+HE' on 'set_logic_XIA' up to expressiveness level 1 ..."
	./test_all.sh -t "$*" -b "${ROOT}/benchmarks/set_logic_XIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/LoopInvGen+HE/Equalities" \
								-- -L 1
	###
	echo "=> Running 'LoopInvGen+HE' on 'set_logic_XIA' up to expressiveness level 2 ..."
	./test_all.sh -t "$*" -b "${ROOT}/benchmarks/set_logic_XIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/LoopInvGen+HE/Intervals" \
								-- -L 2
	###
	echo "=> Running 'LoopInvGen+HE' on 'set_logic_XIA' up to expressiveness level 3 ..."
	./test_all.sh -t "$*" -b "${ROOT}/benchmarks/set_logic_XIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/LoopInvGen+HE/Octagons" \
								-- -L 3
	###
	echo "=> Running 'LoopInvGen+HE' on 'set_logic_XIA' up to expressiveness level 4 ..."
	./test_all.sh -t "$*" -b "${ROOT}/benchmarks/set_logic_XIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/LoopInvGen+HE/Polyhedra" \
								-- -L 4
	###
	echo "=> Running 'LoopInvGen+HE' on 'set_logic_NIA' up to expressiveness level 5 ..."
	./test_all.sh -t "$*" -b "${ROOT}/benchmarks/set_logic_NIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/LoopInvGen+HE/Polynomials" \
								-- -L 5
	###
	echo "=> Running 'LoopInvGen+HE' on 'set_logic_NIA' up to expressiveness level 6 ..."
	./test_all.sh -t "$*" -b "${ROOT}/benchmarks/set_logic_NIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/LoopInvGen+HE/Peano" \
								-- -L 6
	###
	cd "${ROOT}/_output_/expressiveness_@_$*/details/LoopInvGen+HE"
	"${ROOT}/scripts/compute_plearn.py" "Equalities/results.csv" \
																			"Intervals/results.csv" \
																			"Octagons/results.csv" \
																			"Polyhedra/results.csv" \
																			"Polynomials/results.csv" \
																			"Peano/results.csv" \
																			-c "`pwd`/perf_report.csv" \
																			> ./report.csv
	cd "${ROOT}"

sketchac_results(%) : transform
	rm -rf _output_/expressiveness_@_"$*"/details/SketchAC/*
	mkdir -p "_output_/expressiveness_@_$*/details/SketchAC/Equalities" \
				   "_output_/expressiveness_@_$*/details/SketchAC/Intervals" \
				   "_output_/expressiveness_@_$*/details/SketchAC/Octagons" \
				   "_output_/expressiveness_@_$*/details/SketchAC/Polyhedra" \
				   "_output_/expressiveness_@_$*/details/SketchAC/Polynomials" \
				   "_output_/expressiveness_@_$*/details/SketchAC/Peano"
	cd tools/compare
	###
	echo "=> Running 'SketchAC' on 'set_logic_LIA' with 'Equalities.g' ..."
	./test_all.sh -t "$*" -T "scripts/run-sketchac.sh" -b "${ROOT}/benchmarks/set_logic_LIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/SketchAC/Equalities" \
								-V "-t -L NIA" -- "${ROOT}/grammars/Equalities.g"
	###
	echo "=> Running 'SketchAC' on 'set_logic_LIA' with 'Intervals.g' ..."
	./test_all.sh -t "$*" -T "scripts/run-sketchac.sh" -b "${ROOT}/benchmarks/set_logic_LIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/SketchAC/Intervals" \
								-V "-t -L NIA" -- "${ROOT}/grammars/Intervals.g"
	###
	echo "=> Running 'SketchAC' on 'set_logic_LIA' with 'Octagons.g' ..."
	./test_all.sh -t "$*" -T "scripts/run-sketchac.sh" -b "${ROOT}/benchmarks/set_logic_LIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/SketchAC/Octagons" \
								-V "-t -L NIA" -- "${ROOT}/grammars/Octagons.g"
	###
	echo "=> Running 'SketchAC' on 'set_logic_LIA' with 'Polyhedra.g' ..."
	./test_all.sh -t "$*" -T "scripts/run-sketchac.sh" -b "${ROOT}/benchmarks/set_logic_LIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/SketchAC/Polyhedra" \
								-V "-t -L NIA" -- "${ROOT}/grammars/Polyhedra.g"
	###
	echo "=> Running 'SketchAC' on 'set_logic_LIA' with 'Polynomials.g' ..."
	./test_all.sh -t "$*" -T "scripts/run-sketchac.sh" -b "${ROOT}/benchmarks/set_logic_LIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/SketchAC/Polynomials" \
								-V "-t -L NIA" -- "${ROOT}/grammars/Polynomials.g"
	###
	echo "=> Running 'SketchAC' on 'set_logic_LIA' with 'Peano.g' ..."
	./test_all.sh -t "$*" -T "scripts/run-sketchac.sh" -b "${ROOT}/benchmarks/set_logic_LIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/SketchAC/Peano" \
								-V "-t -L NIA" -- "${ROOT}/grammars/Peano.g"
	###
	cd "${ROOT}/_output_/expressiveness_@_$*/details/SketchAC"
	"${ROOT}/scripts/compute_plearn.py" "Equalities/results.csv" \
																			"Intervals/results.csv" \
																			"Octagons/results.csv" \
																			"Polyhedra/results.csv" \
																			"Polynomials/results.csv" \
																			"Peano/results.csv" \
																			> ./report.csv
	"${ROOT}/scripts/plot_plearn.py" SketchAC report.csv \
																	 "../../Fig_7d_SketchAC_PLearn.pdf"
	cd "${ROOT}"

stoch_results(%) : transform
	rm -rf _output_/expressiveness_@_"$*"/details/Stoch/*
	mkdir -p "_output_/expressiveness_@_$*/details/Stoch/Equalities" \
				   "_output_/expressiveness_@_$*/details/Stoch/Intervals" \
				   "_output_/expressiveness_@_$*/details/Stoch/Octagons" \
				   "_output_/expressiveness_@_$*/details/Stoch/Polyhedra" \
				   "_output_/expressiveness_@_$*/details/Stoch/Polynomials" \
				   "_output_/expressiveness_@_$*/details/Stoch/Peano"
	cd tools/compare
	###
	echo "=> Running 'Stoch' on 'set_logic_LIA' with 'Equalities.g' ..."
	./test_all.sh -t "$*" -T "scripts/run-stoch.sh" -b "${ROOT}/benchmarks/set_logic_LIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/Stoch/Equalities" \
								-V "-t -L NIA" -- "${ROOT}/grammars/Equalities.g"
	###
	echo "=> Running 'Stoch' on 'set_logic_LIA' with 'Intervals.g' ..."
	./test_all.sh -t "$*" -T "scripts/run-stoch.sh" -b "${ROOT}/benchmarks/set_logic_LIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/Stoch/Intervals" \
								-V "-t -L NIA" -- "${ROOT}/grammars/Intervals.g"
	###
	echo "=> Running 'Stoch' on 'set_logic_LIA' with 'Octagons.g' ..."
	./test_all.sh -t "$*" -T "scripts/run-stoch.sh" -b "${ROOT}/benchmarks/set_logic_LIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/Stoch/Octagons" \
								-V "-t -L NIA" -- "${ROOT}/grammars/Octagons.g"
	###
	echo "=> Running 'Stoch' on 'set_logic_LIA' with 'Polyhedra.g' ..."
	./test_all.sh -t "$*" -T "scripts/run-stoch.sh" -b "${ROOT}/benchmarks/set_logic_LIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/Stoch/Polyhedra" \
								-V "-t -L NIA" -- "${ROOT}/grammars/Polyhedra.g"
	###
	echo "=> Running 'Stoch' on 'set_logic_LIA' with 'Polynomials.g' ..."
	./test_all.sh -t "$*" -T "scripts/run-stoch.sh" -b "${ROOT}/benchmarks/set_logic_LIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/Stoch/Polynomials" \
								-V "-t -L NIA" -- "${ROOT}/grammars/Polynomials.g"
	###
	echo "=> Running 'Stoch' on 'set_logic_LIA' with 'Peano.g' ..."
	./test_all.sh -t "$*" -T "scripts/run-stoch.sh" -b "${ROOT}/benchmarks/set_logic_LIA" \
							  -l "${ROOT}/_output_/expressiveness_@_$*/details/Stoch/Peano" \
								-V "-t -L NIA" -- "${ROOT}/grammars/Peano.g"
	###
	cd "${ROOT}/_output_/expressiveness_@_$*/details/Stoch"
	"${ROOT}/scripts/compute_plearn.py" "Equalities/results.csv" \
																			"Intervals/results.csv" \
																			"Octagons/results.csv" \
																			"Polyhedra/results.csv" \
																			"Polynomials/results.csv" \
																			"Peano/results.csv" \
																			> ./report.csv
	"${ROOT}/scripts/plot_plearn.py" Stoch report.csv \
																	 "../../Fig_7c_Stoch_PLearn.pdf"
	cd "${ROOT}"
