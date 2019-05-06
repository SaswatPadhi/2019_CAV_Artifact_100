# Artifact Evaluation Instructions for CAV'19 Paper 100

This software package describes steps to reproduce the experiments
reported in the CAV'19 paper titled "_Overfitting in Synthesis: Theory and Practice_".

### Contributions
- All 180 invariant-inference SyGuS benchmarks
- Implementation of all 6 grammars in the SyGuS format
- Working code for the _hybrid enumeration_ (_HEnum_) technique
- Scripts to reproduce the various empirical claims made in the paper:
  - Recording the number of failures with increasing grammar expressiveness
  - Measuring the running time and number of CEGIS rounds for LoopInvGen
  - Comparing the performance of _PLearn_ and _HEnum_

### Claims Supported by This Artifact
- Several state-of-the-art SyGuS solvers show performance degradation upon increasing grammar expressiveness. <br>
  _Caveat_: Running within a VM might result in significant performance degradation. We recommend using our [`docker`][Docker] image (available in the [LoopInvGen] repo) which are [reported](http://domino.research.ibm.com/library/cyberdig.nsf/papers/0929052195DD819C85257D2300681E7B/$File/rc25482.pdf) to have a much smaller overhead than VMs.
- The number of CEGIS rounds and synthesis time (for LoopInvGen) increase with increasing grammar expressiveness; thus indicating likely overfitting.
- The runtime overhead due _HEnum_ is negligible
- Compared to a highly tuned version of LoopInvGen that won SyGuS-Comp 2018, _HEnum_ shows significant speedup (~&hairsp;5&hairsp;&times;).

### Claims Partially Supported by This Artifact
- Performance benefit due to the _PLearn_ framework <br>
  _Reason_: Running _PLearn_ with 6 different grammars requires at least 6 independent cores and 6&hairsp;&times; more memory. Therefore, instead of actually running the various configurations _in parallel_ and returning the first solution, we run each configuration sequentially and consider the _minimum time_ taken by any configuration.

<hr>

## **tl;dr&hairsp;:** Quick Verification of Claims Made in The Paper

- All commands must be run within `~/CAV_100/` directory in the VM.
- Press <kbd>CTRL</kbd>+<kbd>ALT</kbd>+<kbd>T</kbd> to launch a terminal.
- Do **not** omit the quotes (&thinsp;"&thinsp;) around the target names for `make`.
- Use `firefox <path/to/file.pdf>` to open PDF files from the shell.

**Commands:**

- `make motivating_example`: Runs the motivating example `fib_19.sl` (Fig.4 in our paper) on various configurations of LoopInvGen.
  - _Estimested Time:_ ~&thinsp;5 mins
  - _Expected Output:_
    - Data for Fig.5(a) @ `_output_/Fig_5a_motivating_example_report.txt`

- `make "competition(`<kbd>TIMEOUT</kbd>`)"`: Runs LoopInvGen+HE and the version of LoopInvGen that won the _Inv_ track, on the 127 official benchmarks from the 2018 SyGuS Competition with the given <kbd>TIMEOUT</kbd>.
  - _Estimested Time:_ ~&thinsp;12 hours (&#x1F61E;) at <kbd>TIMEOUT</kbd> = 1800 (which was used for the results reported in our paper)
  - _Recommendation:_ Running with <kbd>TIMEOUT</kbd> = 900 should be enough and should terminate in ~&thinsp;6 hours
  - _Expected Output:_
    - Data for &sect;5.3 @ `_output_/Section_5.3_competition_report.txt`

- `make "expressiveness(`<kbd>TIMEOUT</kbd>`)"`: With the given <kbd>TIMEOUT</kbd>, runs _each_ of the 180 benchmarks on _each_ of the 5 SyGuS tools with _each_ of the 6 grammars.
  - _Estimested Time:_ ~&thinsp;20 days (&#x1F62D;) at <kbd>TIMEOUT</kbd> = 1800 (which was used for the results reported in our paper)
  - _Recommendation:_ With <kbd>TIMEOUT</kbd> = 180, the generated data should still exhibit the trends claimed in the paper (but may be a little noisy), and it should take no more than 2 - 3 days ...
  - _Expected Output:_
    - Fig.2 @ `_output_/Fig_2_overfitting_plot.pdf`
    - Data for Fig.3 @ `_output_/Fig_3_correlation_report.txt`
    - Fig.7(a) @ `_output_/Fig_7a_LoopInvGen_PLearn.pdf`
    - Fig.7(b) @ `_output_/Fig_7b_CVC4_PLearn.pdf`
    - Fig.7(c) @ `_output_/Fig_7c_Stoch_PLearn.pdf`
    - Fig.7(d) @ `_output_/Fig_7d_SketchAC_PLearn.pdf`
    - Fig.7(e) @ `_output_/Fig_7e_EUSolver_PLearn.pdf`
    - Fig.8(a) @ `_output_/Fig_8a_PLearn_vs_HE.pdf`
    - Data for Fig.8(b) @ `_output_/Fig_8b_performance_report.txt`

<hr>

## Description of The Tools, Grammars and Benchmarks

The SyGuS tools included in this artifact support the SyGuS input format (SyGuS-IF) version 1.0. SyGuS-IF is very similar to the SMT-LIB2 format that is supported by most SMT solvers. Please see <http://sygus.org/language_1.0> for more details on the input format.

Some of these tools fully or partially support an extension of SyGuS-IF, called _Inv_ extension, which allows for succinctly describing invariant-synthesis problems -- see <http://sygus.org/assets/pdf/SyGuS-IF_2015.pdf> for more details on this extension. The _Inv_ extension also assumes a default grammar (for expressing boolean combinations of linear inequalities over integers). Many tools simply assume this default grammar and do not allow users to override it while using the _Inv_ extension. We describe our solution below.

### The SyGuS Tools

We compare 5 state-of-the-art SyGuS tools, all of which participate in the annual SyGuS competition (SyGuS-Comp).

- _CVC4_&thinsp; by Reynolds et al. (see <https://doi.org/10.1007/978-3-319-21668-3_12>)
  - Available on GitHub: https://github.com/CVC4/CVC4
- _EUSolver_ <sup>[$](#dollar)</sup>&thinsp;<sup>[@](#at)</sup>&thinsp; by Alur et al. (see <https://doi.org/10.1007/978-3-662-54577-5_18>)
  - Available on [StarExec] server.
- _LoopInvGen_ <sup>[#](#hash)</sup>&thinsp; which is our prior work (see <https://doi.org/10.1145/2908080.2908099>)
  - Available on GitHub: [LoopInvGen]
- _SketchAC_ <sup>[$](#dollar)</sup>&thinsp;<sup>[@](#at)</sup>&thinsp;<sup>[&](#ampersand)</sup>&thinsp; by Jeon et al. (see <https://doi.org/10.1007/978-3-319-21668-3_22>)
  - Publicly available on [StarExec] server
- _Stoch_ <sup>[$](#dollar)</sup>&thinsp;<sup>[%](#percent)</sup>&thinsp;<sup>[@](#at)</sup>&thinsp;<sup>[&](#ampersand)</sup>&thinsp; by Alur et al. (see <http://ieeexplore.ieee.org/document/6679385/>)
  - Publicly available on [StarExec] server

<a name='dollar' href=''><sup>$</sup></a>&nbsp; These tools do not support the _Inv_ extension at all, or do not allow custom grammars when using the _Inv_ extension. We translate benchmarks to the base SyGuS-IF which assumes no default grammar, and therefore allows us to provide custom grammars.
<br>
<a name='hash' href=''><sup>#</sup></a>&nbsp; LoopInvGen does not allow users to provide an explicit grammar, but it allows users to provide a set of operators that can be arbitrarily applied to constants and variable symbols. We compile multiple versions of LoopInvGen with different sets of operators that correspond to our grammars
<br>
<a name='percent' href=''><sup>%</sup></a>&nbsp; The Stoch solver does not contain a `mod` operator, so we define it as a user-defined function, as described below.
<br>
<a name='at' href=''><sup>@</sup></a>&nbsp; These tools do not recognize the `(set-logic NIA)` statement, but they are able to infer non-linear invariants. Therefore, we provide benchmarks with `(set-logic LIA)` and grammars allowing non-linear expressions, and finally force the verifier to check under the _NIA_ logic.
<br>
<a name='ampersand' href=''><sup>&</sup></a>&nbsp; These tools sometimes return expressions that are not well-typed, for example `(and 1 (< x 0))`. Instead of rejecting them entirely, we weaken our verifier to check if substituting `1` &#x21a6; `true` and `0` &#x21a6; `false` (when they are applied to boolean operators) results in a valid invariant.

The Stoch solver also renames all input variables, for example (x, y z) to (x0, x1, x2).
Therefore, we always perform &alpha;-reduction on the predicate within our verification script before checking its validity.

We provide wrapper scripts for these tools (located in `~/CAV_100/tools/compare/scripts`) which handle these exceptions listed above and provide a consistent API for solving an arbitrary invariant-synthesis problem with an arbitrary grammar.

### The Grammars

The 6 grammars for quantifier-free predicates over integers, as described in our paper, are defined in the various `.g` files within `~/CAV_100/grammars`. These files are a straightforward encoding of the BNF grammars shown in the paper, and the syntax is self-explanatory.

_NOTE:_ The `Peano.g` file defines a `modfn` function for `Stoch`. For solvers which support `mod`, overriding this keyword is not allowed, so we choose `modfn` as the function name and simply rewrite it to `mod` in generated solutions.

### The Benchmarks

We evaluate the SyGuS tools on _180_ invariant-synthesis benchmarks:
_127_ official benchmarks from the Inv track of [2018 SyGuS competition (SyGuS-Comp)](http://sygus.org/comp/2018/), augmented with benchmarks from the [2018 Software Verification competition (SV-Comp)](https://sv-comp.sosy-lab.org/2018/index.php) and challenging
verification problems proposed in prior work (see [9, 10]).

There are 3 subdirectories within `~/CAV_100/benchmarks`:

- `set_logic_XIA`: These are the original benchmarks sorted by the underlying logic they use (Linear Integer Arithmetic = _LIA_ or Non-linear Integer Arithmetic = _NIA_) and their source (SyGuS-Comp, SVComp, etc.)

- `set_logic_NIA`: These benchmarks are the same as `set_logic_XIA`, except that the first line of each benchmark has been modified to `(set-logic NIA)` if it was `(set-logic LIA)`. These benchmarks are used instead of their `set_logic_XIA` copy when we evaluate with grammars allowing non-linear expressions, such as `Polynomials.g` or `Peano.g`, to test the impact of grammar expressiveness. A non-linear invariant would otherwise simply be rejected for _LIA_ logic.

- `set_logic_LIA`: These benchmarks are the same as `set_logic_XIA`, except that the first line of each benchmark has been modified to `(set-logic LIA)` if it was `(set-logic NIA)`. These benchmarks are used instead of their `set_logic_XIA` copy when we evaluate tools that do not recognize `(set-logic NIA)` (see <sup>[@]</sup> above).

<hr>

## Running Various Tools on New Problems:

_NOTE:_ &thinsp; Please run `make dependencies` within `~/CAV_100` before trying the following commands.

We provide example commands (to be run at `~/CAV_100`) for performing single-benchmark or batch verification with the various tools included in the VM. The batch verification script (`test_all.sh`) invokes a verifier which checks the validity of the inferred invariant.

#### &nbsp; &rArr; &nbsp; CVC4&thinsp;:

##### Infer Invariant for a Single Problem

```bash
timeout 30 ./tools/compare/scripts/run-cvc4.sh benchmarks/set_logic_XIA/LIA/2016.SyGuS-Comp/w1.sl grammars/Octagons.g
```

##### Batch Verification of an Entire Directory of Problems

```bash
./tools/compare/test_all.sh -t 30 -T ./tools/compare/scripts/run-cvc4.sh -b benchmarks/set_logic_NIA/LIA/others -- `pwd`/grammars/Peano.g
```

#### &nbsp; &rArr; &nbsp; EUSolver&thinsp;:

##### Infer Invariant for a Single Problem

```bash
timeout 30 ./tools/compare/scripts/run-eusolver.sh benchmarks/set_logic_XIA/LIA/2016.SyGuS-Comp/w1.sl grammars/Octagons.g
```

##### Batch Verification of an Entire Directory of Problems

```bash
./tools/compare/test_all.sh -t 30 -T ./tools/compare/scripts/run-eusolver.sh -b benchmarks/set_logic_LIA/LIA/others -V "-L NIA" -- `pwd`/grammars/Peano.g
```

- The `-V` option is used to pass low-level arguments to the verifier -- in this case, the `-L NIA` flag which forces checking the invariant under _NIA_ logic.

#### &nbsp; &rArr; &nbsp; LoopInvGen&thinsp;:

##### Infer Invariant for a Single Problem

```bash
timeout 30 ./tools/_LoopInvGen.Octagons_/loopinvgen.sh benchmarks/set_logic_XIA/LIA/2016.SyGuS-Comp/w1.sl
```

##### Batch Verification of an Entire Directory of Problems

```bash
./tools/_LoopInvGen.Octagons_/test_all.sh -t 30 -b benchmarks/set_logic_NIA/LIA/others
```

#### &nbsp; &rArr; &nbsp; LoopInvGen+HE&thinsp;:

- The source code for _LoopInvGen+HE_ is available in `~/CAV_100/base-LIG/LoopInvGen+HE`. The `Synthesizer.ml` file implements the _HEnum_ and `Divide` algorithms described in our paper (Algorithm 2).
- _LoopInvGen+HE_ takes a `-L` or `--level` argument that controls the grammar that is explored. As we define in the paper, this value ranges from 1 = Equalities to 6 = Peano

##### Infer Invariant for a Single Problem

```bash
timeout 30 ./tools/_LoopInvGen+HE_/loopinvgen.sh -L 3 benchmarks/set_logic_XIA/LIA/2016.SyGuS-Comp/w1.sl
```

##### Batch Verification of an Entire Directory of Problems

```bash
./tools/_LoopInvGen+HE_/test_all.sh -t 30 -b benchmarks/set_logic_NIA/LIA/others -- -L 6
```

#### &nbsp; &rArr; &nbsp; SketchAC&thinsp;:

##### Infer Invariant for a Single Problem

```bash
timeout 30 ./tools/compare/scripts/run-sketchac.sh benchmarks/set_logic_XIA/LIA/2016.SyGuS-Comp/w1.sl grammars/Octagons.g
```

##### Batch Verification of an Entire Directory of Problems

```bash
./tools/compare/test_all.sh -t 30 -T ./tools/compare/scripts/run-sketchac.sh -b benchmarks/set_logic_LIA/LIA/others -V "-t -L NIA" -- `pwd`/grammars/Peano.g
```

- The `-V` option is used to pass low-level arguments to the verifier -- in this case, the `-L NIA` flag which forces checking the invariant under _NIA_ logic and the `-t` flag which weakens the type-checker to treat "1" and "0" as "true" and "false" when applied to boolean operators.


#### &nbsp; &rArr; &nbsp; Stoch&thinsp;:

##### Infer Invariant for a Single Problem

```bash
timeout 30 ./tools/compare/scripts/run-stoch.sh benchmarks/set_logic_XIA/LIA/2016.SyGuS-Comp/w1.sl grammars/Octagons.g
```

##### Batch Verification of an Entire Directory of Problems

```bash
./tools/compare/test_all.sh -t 30 -T ./tools/compare/scripts/run-stoch.sh -b benchmarks/set_logic_LIA/LIA/others -V "-t -L NIA" -- `pwd`/grammars/Peano.g
```

- The `-V` option is used to pass low-level arguments to the verifier -- in this case, the `-L NIA` flag which forces checking the invariant under _NIA_ logic and the `-t` flag which attempts to check the new expression resulting from the substitution `1` &#x21a6; `true` and `0` &#x21a6; `false` (whenever they are applied to boolean operators).



[Docker]:     https://www.docker.com/
[LoopInvGen]: https://github.com/SaswatPadhi/LoopInvGen/
[StarExec]:   https://www.starexec.org/
