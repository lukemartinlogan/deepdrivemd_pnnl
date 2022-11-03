# DeepDriveMD

DeepDriveMD: Deep-Learning Driven Adaptive Molecular Simulations. The workflow is for coupling molecular dynamics (MD) ensemble simulations to sampling agents guided by machine learning techniques, and the default data transfer is made through a shared filesystem e.g., Lustre and GPFS.

![execution-diagram](/research/figures/ddmd_execution_diagram.png)

This repo is originated from https://github.com/DeepDriveMD/DeepDriveMD-pipeline and added research for data movement between file-based and streaming versions.

## Existing codebase on PNNL Platform for Quick Start

The shared repo is currently located in the path below:

### DeepDriveMD repo on Bluesky

```
/files0/oddite/deepdrivemd/src
```

### NFS Path (shared project /qfs/...)

```
/qfs/projects/oddite/deepdrivemd/
```

### Conda environment

Necessary packages are currently provided via this conda environment.

```
source /share/apps/python/miniconda3.7/etc/profile.d/conda.sh
conda activate /files0/oddite/conda/ddmd/
```

##

### BBA protein folding example

fast-folding the ββα (BBA) canonical fold engineered protein, FSD-EY is included in the `/test/bba` directory as a small example, where 505 atoms and 28 amino-acid residues exist in the biophysical system. 

```
/files0/oddite/deepdrivemd/src/test/bba/bluesky-md-simulation.yaml 
```

### Experiment output directory

While the workflow progresses, the (intermediate/permanent) outputs are generated in a dedicated directory defined in a YAML user definition file. The `experiment_directory` is set under this path:

```
/files0/oddite/deepdrivemd/runs/
```

### Test Run 

Since DeepDriveMD is written as a Python API, the main function to run the workflow with user settings (YAML configuration file) is runnable like this:

```
python -m deepdrivemd.deepdrivemd -c <experiment_config.yaml>
```

For example, the bluesky setting can be executed:
```
python -m deepdrivemd.deepdrivemd -c test/bba/bluesky-md-simulation.yaml 
```
with proper changes to the settings. E.g., It needs to make sure that the `experiment_directory` does not exist prior to the run, as overwriting is not expected. Empty directory should be given.

### MD Run (direct invocation without RADICAL)

```
python /files0/oddite/deepdrivemd/src/deepdrivemd/sim/openmm/run_openmm.py -c /files0/oddite/deepdrivemd/src/test/bba/md_direct.yml
```

## Required Software/Tools

There are several software packages required to run DeepDriveMD including MD simulation and ML training.

### OpenMM - Molecular Dynamics simulation

Manual installation/binary installation can be confirmed through test command like:

```
[leeh736@bluesky openmm]$ python -m openmm.testInstallation

OpenMM Version: 7.7
Git Revision: 130124a3f9277b054ec40927360a6ad20c8f5fa6

There are 2 Platforms available:

1 Reference - Successfully computed forces
2 CPU - Successfully computed forces

Median difference in forces between platforms:

Reference vs. CPU: 6.30456e-06

All differences are within tolerance.
```

### PyTorch/TensorFlow

Please follow the general documentation: https://pytorch.org/docs/stable/index.html or https://www.tensorflow.org/install/pip


### ADIOS

Conda `adios2` is available through the `conda-forge` channel.

The official guide to install is available here: https://github.com/DeepDriveMD/DeepDriveMD-pipeline#deepdrivemd-s-streaming-asynchronous-execution-with-adios

