This repo is modified DeepDriveMd for CPU Run

# Dependencies
You can setup environments two ways
- [buid the conda environment from scratch](#prepare-ddmd-env)
- [copy the pre-built conda environment on Ares](#clone-conda-environment)

## Hermes Dependencies
- If you are runnong on Ares:
`module load hermes/pnnl-tz3s7yx` this automatically loads the Hermes build with VFD, and it's HDF5 dependency.
- If no hermes module:
  - Sequential HDF5 >= 1.14.0
  - Hermes>=1.0 with VFD and POSIX Adaptor support


## Prepare DDMD Env
## DDMD Python Packagse
### molecules
```
git clone https://github.com/braceal/molecules.git
```
## DDMD Conda Environment
### miniconda3
Get the conda installation script and run it: `wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh` \
The current conda version tested work that works `conda 23.3.1`.


### Build Conda Env OpenMM on Ares
```
conda create --name hermes_openmm7_ddmd
conda activate hermes_openmm7_ddmd
conda install -c omnia openmm=7.4
conda install -c omnia -c conda-forge openmm=7.4
python -m simtk.testInstallation # test installation
pip install pyyaml radical.entk simtk.unit numpy MDAnalysis==2.0.0 pydantic==1.9.0
```
#### Install MD-Tools
h5py==3.8.0 uses HDF5-1.14.0
```
git clone https://github.com/candiceT233/MD-tools # use this for openmm<=7.4 version

cd MD-tools
pip install .
```

### Build Conda Env Pytorch on Ares
Build pytorch-cpu and other dependencies.
```
conda create --name hm_ddmd_pytorch python=3.7
source activate hm_ddmd_pytorch
conda install -c conda-forge pytorch-cpu
pip install scikit-learn scipy matplotlib molecules wandb mpi4py torch MDAnalysis==2.0.0 pydantic==1.9.0
pip install deepdrivemd --no-dependencies
pip install h5py==3.8.0
```

## Clone Conda Environment
You must have Ares access to clone environment:
```
conda create --name hermes_openmm7_ddmd --clone /home/mtang11/miniconda3/envs/hermes_openmm7_ddmd
conda create --name hm_ddmd_pytorch --clone /home/mtang11/miniconda3/envs/hm_ddmd_pytorch
```

# Installation

## Build DDMD (Not required if you cloned the conda environment)
Must build in the **two** conda environment 
rebuild package in deepdrivemd folder
```
cd /path/to/deepdrivemd
python setup.py build
pip install -e .
```
## Reinstall Correct Version of HDF5
```
pip uninstall h5py; pip install h5py==3.8.0
```

# Usage
How do you launch DeepDriveMD without Hermes? Environment variables?
What Hermes adapter can be used? No need to go into detail about things like paths with Hermes.
Below are descriptions with script `ddmd.sh`.

## Experiment Variables
- `SHORTENED_PIPELINE` : `true` means to ignore AGGREGATE and parallelize TRAIN and INFERENCE, `false` all run in order
- `SKIP_SIM` : `true` means not to delete the previous simulated data, shorten debug time
- `MD_RUNS` : the number of OpenMM tasks, currently is parallel, and minimum number is 12 for TRAIN and INFERENCE to work
- `ITER_COUNT` : how many iterations the 4-stages pipeline will run
- `SIM_LENGTH` : simulation size, minimum `0.1` (100ps) for TRAIN and INFERENCE to work
- `TEST_OUT_PATH` : test output folders contaning all the data and logs
- `FS_PATH` : currently only on NFS, can be used to change test on other path later
- `EXPERIMENT_PATH` : must change to your own directory
- `DDMD_PATH` : the deepdrivemd code path, currently on ares /home/mtang11/scripts/deepdrivemd
- `MOLECULES_PATH` : the path to the [molecule](#molecules) package, 
- Others:
  - `NODE_COUNT` and `GPU_PER_NODE` is just kept to go through the OpenMM loop
  - no need to change `MD_START, MD_SLICE, STAGE_IDX, and STAGE_IDX_FORMAT`.
  - `TRIAL` is just a tag to test name path


## Workflow Explain
All log files can be found under the specific task folder in `TEST_OUT_PATH`. If Hermes debug version is run, all the hermes logs will be in those log folder. Each task has it's own log from `&> ${task_id}_${FUNCNAME[0]}.log`.
Ouput example and file sizes is given with experiment running `SIZE=0.1` (100ps).

### Stage 1 : OPENMM
Runs simulation code:
- output multiple task folders to `$EXPERIMENT_PATH/$TEST_OUT_PATH/molecular_dynamics_runs`
- must use [conda environment hermes_openmm7_ddmd](#build-conda-env-openmm-on-ares)
- must prefix `PYTHONPATH=$DDMD_PATH:$MOLECULES_PATH` before the python command
Sample output under one task folder (total 12 tasks folders):
```
/home/mtang11/experiments/ddmd_runs/test_100ps_i1_nfs1/molecular_dynamics_runs/stage0000/task0000:
total 2.4M
-rw-rw-r-- 1 mtang11 mtang11 1.6M Aug 11 01:08 aggregated.h5
-rw-rw-r-- 1 mtang11 mtang11  722 Aug 11 01:08 aggregate_stage_test.yaml
-rw-rw-r-- 1 mtang11 mtang11  786 Aug 10 21:50 molecular_dynamics_stage_test.yaml
-rw-rw-r-- 1 mtang11 mtang11 599K Aug 10 21:56 stage0000_task0000.dcd
-rw-rw-r-- 1 mtang11 mtang11 164K Aug 10 21:56 stage0000_task0000.h5
-rw-rw-r-- 1 mtang11 mtang11 8.4K Aug 10 21:56 stage0000_task0000.log
-rw-rw-r-- 1 mtang11 mtang11  39K Aug 10 21:50 system__1FME-unfolded.pdb
-rw-rw-r-- 1 mtang11 mtang11 2.3K Aug 11 01:08 task0000_AGGREGATE.log
-rw-rw-r-- 1 mtang11 mtang11 2.3K Aug 10 21:56 task0000_OPENMM.log
```

## Stage 2 : AGGREGATE
- output and log will be under one of the task folder in `$EXPERIMENT_PATH/$TEST_OUT_PATH/molecular_dynamics_runs`
- can be skipped with `SHORTENED_PIPELINE=true`
- must prefix `PYTHONPATH=$DDMD_PATH:$MOLECULES_PATH` before the python command
(See [task0000 in molecular_dynamics_runs](#stage-1--openmm) folder for expected output)

## Stage 3 : TRAINING
- output and log will be in `$EXPERIMENT_PATH/$TEST_OUT_PATH/machine_learning_runs`
- can be run in background with `SHORTENED_PIPELINE=true`
- must prefix `PYTHONPATH=$DDMD_PATH:$MOLECULES_PATH` before the python command
- log might show warning message can ignore
Expected output:
```
/home/mtang11/experiments/ddmd_runs/test_100ps_i1_nfs1/machine_learning_runs/stage0002/task0000:
total 6.1M
drwxrwxr-x 2 mtang11 mtang11 4.0K Aug 11 01:09 checkpoint
-rw-rw-r-- 1 mtang11 mtang11 1.5M Aug 11 01:10 discriminator-weights.pt
drwxrwxr-x 2 mtang11 mtang11 4.0K Aug 11 01:10 embeddings
-rw-rw-r-- 1 mtang11 mtang11 2.0M Aug 11 01:10 encoder-weights.pt
-rw-rw-r-- 1 mtang11 mtang11 2.7M Aug 11 01:10 generator-weights.pt
-rw-rw-r-- 1 mtang11 mtang11 1.2K Aug 11 01:10 loss.json
-rw-rw-r-- 1 mtang11 mtang11  495 Aug 11 01:08 model-hparams.json
-rw-rw-r-- 1 mtang11 mtang11   82 Aug 11 01:08 optimizer-hparams.json
-rw-rw-r-- 1 mtang11 mtang11  27K Aug 11 01:10 task0000_TRAINING.log
-rw-rw-r-- 1 mtang11 mtang11  884 Aug 11 01:08 training_stage_test.yaml
-rw-rw-r-- 1 mtang11 mtang11 1.3K Aug 11 01:08 virtual-h5-metadata.json
-rw-rw-r-- 1 mtang11 mtang11  10K Aug 11 01:08 virtual_stage0000_task0000.h5
```

## Stage 4 : INFERENCE
- output and log will be in `$EXPERIMENT_PATH/$TEST_OUT_PATH/inference_runs`
- must prefix `OMP_NUM_THREADS=4 PYTHONPATH=$DDMD_PATH/:$MOLECULES_PATH` before python command, the number of threads can be changed. 
```
/home/mtang11/experiments/ddmd_runs/test_100ps_i1_nfs1/inference_runs/stage0003/task0000:
total 32K
-rw-rw-r-- 1 mtang11 mtang11  479 Aug 11 01:10 inference_stage_test.yaml
-rw-rw-r-- 1 mtang11 mtang11 3.2K Aug 11 01:10 task0000_INFERENCE.log
-rw-rw-r-- 1 mtang11 mtang11 1.5K Aug 11 01:10 virtual-h5-metadata.json
-rw-rw-r-- 1 mtang11 mtang11  18K Aug 11 01:10 virtual_stage0003_task0000.h5
```

## Using `hm_ddmd.sh`
Mostly added functions for preparing hermes host file, starting and stopping hermes. \
Before each python command, load Hermes with:
```
    HDF5_DRIVER=hdf5_hermes_vfd \
        HDF5_PLUGIN_PATH=${HERMES_INSTALL_DIR}/lib:$HDF5_PLUGIN_PATH \
        HERMES_CONF=$HERMES_CONF \
        HERMES_CLIENT_CONF=$HERMES_CLIENT_CONF \
        xxx
```

# Slurm Script (TODO)
Need to add and test the slurm script.

# Others
Original Repo: https://github.com/DeepDriveMD/DeepDriveMD-pipeline