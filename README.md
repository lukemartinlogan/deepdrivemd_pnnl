This repo is modified DeepDriveMD (DDMD) for CPU Run and OpenMM<=7.5.

# Dependencies

You can setup environments two ways
- [create environment from config files](#ddmd-conda-environment-from-config-files)
- [buid the conda environment from scratch](./docs/conda_env/README.md)

## Prepare Conda Environment from Config Files
1. Prepare Conda
Get the `miniconda3` installation script and run it: `wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh` \
The current conda version tested work that works `conda 23.3.1`.

2. First git clone this repo and save it to `$DDMD_PATH`
```
git clone xxx $DDMD_PATH (recursive, makesure clone all submodules)
cd $DDMD_PATH
```
3. Create the two conda environments
Name your two environment names `$CONDA_OPENMM` `$CONDA_PYTORCH`.
```
cd $DDMD_PATH
conda create -f docs/conda_env/ddmd_openmm7.yaml
conda create -f docs/conda_env/ddmd_pytorch.yaml
```

4. Update python packages in both conda environments
- udpate MD-TOOLs
```
cd $DDMD_PATH/sub_modules/MD-tools
source activate $CONDA_OPENMM
pip install .
source activate $CONDA_PYTORCH
pip install .
```
- update molecules
```
cd $DDMD_PATH/sub_modules/molecules
source activate $CONDA_OPENMM
pip install .
source activate $CONDA_PYTORCH
pip install .
```

## Hermes Dependencies
- If you are runnong on IIT Ares:
`module load hermes/pnnl-tz3s7yx` this automatically loads the Hermes build with VFD, and it's HDF5 dependency.
- If building Hermes yourself:
  - Sequential HDF5 >= 1.14.0
  - Hermes>=1.0 with VFD and POSIX Adaptor support


# Installation
- `h5py==3.8.0` is required for `hdf5-1.14.0` and `Hermes>=1.0`
- `pip install h5py==3.8.0` should be run after deepdrivemd installation due to version restriction with pip
- makesure you have `hdf5-1.14.0` installed and added to $PATH before installing h5py (otherwise it will download hdf5-1.12.0 by default)
```
cd $DDMD_PATH
source activate $CONDA_OPENMM
pip install -e .
pip uninstall h5py; pip install h5py==3.8.0
source activate $CONDA_PYTORCH
pip install -e .
pip uninstall h5py; pip install h5py==3.8.0
```


# Usage
Below describes running one iteration of the 4-stages pipeline. \
Set up experiment path in `$EXPERIMENT_PATH`, this will store all output files and log files from all stages.


---
## Stage 1 : OPENMM
Run code:
```bash
source activate $CONDA_OPENMM
PYTHONPATH=$DDMD_PATH:$MOLECULES_PATH python $DDMD_PATH/deepdrivemd/sim/openmm/run_openmm.py -c $YAML_PATH
```
This stage runs simulation, minimally you have to run 12 simulation tasks for stage 3 & 4 to work. So you must run the above command at least 12 times and each time with a different `TASK_IDX_FORMAT`.
### Environment variables note
- `TASK_IDX_FORMAT` : give a different task ID format for each openmm task, starts with `task0000` up to `task0011` for 12 tasks.
- `SIM_LENGTH` : The simulation size, must be at least `0.1` for stage 3 & 4 to work.
- `GPU_IDX` : set it to 0 since GPU is not used
- `YAML_PATH` : The yaml file that contains the test configuration for the first stage


Setup environment variables and paths:
```bash
SIM_LENGTH=0.1
GPU_IDX=0
TASK_IDX_FORMAT="task0000"
STAGE_IDX=0
OUTPUT_PATH=$EXPERIMENT_PATH/molecular_dynamics_runs/stage0000/$TASK_IDX_FORMAT
YAML_PATH=$DDMD_PATH/test/bba/molecular_dynamics_stage_test.yaml
mkdir -p $OUTPUT_PATH
```
In the yaml file [`molecular_dynamics_stage_test.yaml`](./test/bba/molecular_dynamics_stage_test.yaml), makesure to modify the following fields accordingly:
```yaml
experiment_directory: $EXPERIMENT_PATH
stage_idx: $STAGE_IDX
output_path: $OUTPUT_PATH
pdb_file: $DDMD_PATH/data/bba/system/1FME-unfolded.pdb
initial_pdb_dir: $DDMD_PATH/data/bba
simulation_length_ns: $SIM_LENGTH
reference_pdb_file: $DDMD_PATH/data/bba/1FME-folded.pdb
gpu_idx: $GPU_IDX
```


Sample output under one task folder (total 12 tasks folders):
```log
ls -l $EXPERIMENT_PATH/molecular_dynamics_runs/stage0000/task0000:
-rw-rw-r-- 1 mtang11 mtang11 1.6M Aug 11 01:08 aggregated.h5
-rw-rw-r-- 1 mtang11 mtang11  722 Aug 11 01:08 aggregate_stage_test.yaml
-rw-rw-r-- 1 mtang11 mtang11  786 Aug 10 21:50 molecular_dynamics_stage_test.yaml
-rw-rw-r-- 1 mtang11 mtang11 599K Aug 10 21:56 stage0000_task0000.dcd
-rw-rw-r-- 1 mtang11 mtang11 164K Aug 10 21:56 stage0000_task0000.h5
-rw-rw-r-- 1 mtang11 mtang11  39K Aug 10 21:50 system__1FME-unfolded.pdb
```
--- 

## Stage 2 : AGGREGATE (TODO)
- output and log will be under one of the task folder in `$EXPERIMENT_PATH/$TEST_OUT_PATH/molecular_dynamics_runs`
- can be skipped with `SHORTENED_PIPELINE=true`
- must prefix `PYTHONPATH=$DDMD_PATH:$MOLECULES_PATH` before the python command
(See [task0000 in molecular_dynamics_runs](#stage-1--openmm) folder for expected output)
```log
ls -l $EXPERIMENT_PATH/molecular_dynamics_runs/stage0000/task0000:
-rw-rw-r-- 1 mtang11 mtang11 1.6M Aug 11 01:08 aggregated.h5
```

## Stage 3 : TRAINING (TODO)
- output and log will be in `$EXPERIMENT_PATH/$TEST_OUT_PATH/machine_learning_runs`
- can be run in background with `SHORTENED_PIPELINE=true`
- must prefix `PYTHONPATH=$DDMD_PATH:$MOLECULES_PATH` before the python command
- log might show warning message can ignore
Expected output:
```log
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

## Stage 4 : INFERENCE (TODO)
- output and log will be in `$EXPERIMENT_PATH/$TEST_OUT_PATH/inference_runs`
- must prefix `OMP_NUM_THREADS=4 PYTHONPATH=$DDMD_PATH/:$MOLECULES_PATH` before python command, the number of threads can be changed. 
```log
/home/mtang11/experiments/ddmd_runs/test_100ps_i1_nfs1/inference_runs/stage0003/task0000:
total 32K
-rw-rw-r-- 1 mtang11 mtang11  479 Aug 11 01:10 inference_stage_test.yaml
-rw-rw-r-- 1 mtang11 mtang11 3.2K Aug 11 01:10 task0000_INFERENCE.log
-rw-rw-r-- 1 mtang11 mtang11 1.5K Aug 11 01:10 virtual-h5-metadata.json
-rw-rw-r-- 1 mtang11 mtang11  18K Aug 11 01:10 virtual_stage0003_task0000.h5
```


# Others
Original Repo: https://github.com/DeepDriveMD/DeepDriveMD-pipeline