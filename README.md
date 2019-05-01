CAV'19 Artifact for Paper 100
<a href='https://zenodo.org/record/2653957'><img align='right' src='https://img.shields.io/badge/DOI-10.5281%2Fzenodo.2653957-blue.svg'/></a>
=============================

This repository contains the code to reproduce the claims made in our CAV paper titled "Overfitting in Synthesis: Theory and Practice". More specifically, we provide all 180 invariant-inference SyGuS benchmarks, implementations of all 6 grammars presented in our paper, working code for the hybrid enumeration (<code>HEnum</code>) technique, and several scripts to reproduce the empirical claims made in the paper:

  - Recording the number of failures with increasing grammar expressiveness,
  - Measuring the running time and number of CEGIS rounds for LoopInvGen, and
  - Comparing the performance of <code>PLearn</code> and <code>HEnum</code>


## Installation

### Using VM Image (Official CAV'19 Artifact)

1. Grab the `cav19-artifact-100.zip` file from [Zenodo](https://zenodo.org/record/2653957).
2. Optionally, verify that the `sha1sum` of the zip file matches with `cav19-artifact-100.sha1`:
     - Download the `cav19-artifact-100.zip` and `cav19-artifact-100.sha1` files to the same directory.
     - In that directory, run: `sha1sum -c cav19-artifact-100.sha1`.
     - You should see `cav19-artifact-100.zip: OK`.
3. Upon extracting the zip file, you should see:
    - `CAV19_Artifact_100.ova` VM image,
    - a copy of this file (`Getting_Started.md`), and
    - the artifact evaluation instructions (`Instructions.html`).
4. [Download](https://www.virtualbox.org/wiki/Downloads) and install `virtualbox` on your machine.
5. [Import the `.ova` image](https://docs.oracle.com/cd/E26217_01/E26796/html/qs-import-vm.html) to your virtualbox.
6. Make sure you assign enough memory (8 GB minimum, 16 GB recommended).
7. Boot the system and perform some basic checks:
    1. Login with user `cav` and password `ae`.
    2. Start a terminal session (<kbd>CTRL</kbd>+<kbd>ALT</kbd>+<kbd>T</kbd>) and try:
        1. `cd CAV_100`
        2. `make clean ; make dependencies`
8. If you didn't notice any errors so far and you get the `Everything built!` message,
   then you can proceed with the [artifact evaluation steps](CAV-AE.md).

### Alternatives

LoopInvGen+HE has now been merged into the main LoopInvGen repo.
See [LoopInvGen](../../../LoopInvGen) repository for instructions on using docker builds, or native installation.



## LICENSE

The code in this repository, LoopInvGen and LoopInvGen+HE are all licensed under the [MIT License](LICENSE.md).
