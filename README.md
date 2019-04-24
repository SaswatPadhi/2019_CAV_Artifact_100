CAV'19 Artifact for Paper 100
<a href='https://zenodo.org/record/2653957'><img align='right' src='https://img.shields.io/badge/DOI-10.5281%2Fzenodo.2653957-blue.svg'/></a>
=============================

This repository contains the code to reproduce the claims made in our CAV paper titled "_Overfitting in Synthesis: Theory and Practice_".


## Installation

### Using VM Image (Official CAV'19 Artifact)
1. Grab the `cav19-artifact-100.zip` file from [Zenodo](https://zenodo.org/record/2653957).
    - Optionally, verify that the `sha1sum` of the zip file matches with `cav19-artifact-100.sha1`:
        - Download the `cav19-artifact-100.zip` and `cav19-artifact-100.sha1` to the same directory.
        - In that directory, run: `sha1sum -c cav19-artifact-100.sha1`.
        - You should see `cav19-artifact-100.zip: OK`.
2. Upon extracting the zip file, you should see:
    - `CAV19_Artifact_100.ova` VM image,
    - a copy of this file (`Getting_Started.md`), and
    - the artifact evaluation instructions (`Instructions.html`).
3. [Download](https://www.virtualbox.org/wiki/Downloads) and install `virtualbox` on your machine.
4. [Import the `.ova` image](https://docs.oracle.com/cd/E26217_01/E26796/html/qs-import-vm.html) to your virtualbox.
5. Make sure you assign enough memory (8 GB minimum, 16 GB recommended).
6. Boot the system and perform some basic checks:
    - Login with user `cav` and password `ae`.
    - Start a terminal session and try:
        - `cd CAV_100`
        - `make clean ; make dependencies`
7. If you didn't notice any errors so far and you get the `Everything built!` message,
   then you can proceed with the [artifact evaluation steps](CAV-AE.md).

### Alternatives

LoopInvGen+HE has now been merged into the main LoopInvGen repo.
See [LoopInvGen](../../../LoopInvGen) repository for instructions on using docker builds, or native installation.



## LICENSE

The code in this repository, LoopInvGen and LoopInvGen+HE are all licensed under the [MIT License](LICENSE.md).
