# MD/Aggregation Example

This page provides an example of running MD/Aggregation tasks from DeepDriveMD workflow.

## Installation

It will require to install DeepDriveMD specific packages such as OpenMM=7.4.0 and Python 3.7x for the compatibility.

```
module load gcc/7.5.0 # gcc 7+ required for Numpy/h5py compiliation
conda create -n ddmd python=3.7
conda activate ddmd
conda install openmm=7.4.0 -c omnia
conda install hdf5
pip install git+https://github.com/braceal/MD-tools.git
pip install deepdrivemd
```

## Setup

MD/Aggregation tasks (python scripts) are directly called from the local github repository.
And the example requires to use the environment vabiable to lookup the path:

```
git clone https://gitlab.pnnl.gov/perf-lab/workflows/deepdrivemd.git
export DDMD_LOCAL_GIT_PATH=`pwd`/deepdrivemd
```

After this environment is set, MD/Agg tasks are used to call like:
```
(md) python $DDMD_LOCAL_GIT_PATH/sim/openmm/run_openmm.py
(agg) python $DDMD_LOCAL_GIT_PATH/aggregation/basic/aggregate.py
```

## Run

The shell script runs MD simulations (`run_openmm.py`) and aggregation (`aggregate.py`) sequentially. And the user parameter specifies how many MD processes will be launched (1st param) and the number of output files (.h5) to aggregate from the simulation (2nd param). For example:

```
$ bash md_agg_example.sh
syntax: ./md_agg_example.sh (number of md tasks to run) (number o f h5 files to aggregate)

examples:
  ./md_agg_example.sh 6 (running 6 MD processes and aggregate them all)
  ./md_agg_example.sh 6 2 (running 6 MD processes and aggregate 2 of them in task idx order)

Note that "export $DDMD_LOCAL_GIT_PATH=" must be set to locate scripts i.e., run_openmm.py
```

The current directory will be a working directory which will create files/sub-directories by following DeepDriveMD API :

```
$ ls */*
system/1FME-folded.pdb  system/epoch-130-20201203-150026.pt

aggregation_runs/stage0000:
task0000

molecular_dynamics_runs/stage0000:
task0000  task0001

system/bba:
1FME-folded.pdb  epoch-130-20201203-150026.pt  system

system/system:
1FME-unfolded.pdb
```

- system: input data 
- aggregation_runs/stageXXXX/taskXXXX: output path of aggregation task
- molecular_dynamics_runs/stageXXXX/taskXXXX: output path of md task

### 2 MD processes and Aggregation

```
$ ./md_agg_example.sh 2 2 # indicating 2 md processes and 2 output .h5 files to aggregate

```

The default settings (`md_direct_template.yml`) are 0.1 ns simulation time steps with 1ps reporter steps `simulation_length_ns: 0.1` and `report_interval_ps: 1.0` which will generate 100 records in the hdf5 dataset, for example, two h5 files are produced and 1 aggregated file contains 200 records:

```

$ h5ls molecular_dynamics_runs/stage0000/task0000/stage0000_task0000.h5
contact_map              Dataset {100}
fnc                      Dataset {100}
point_cloud              Dataset {100, 3, 28}
rmsd                     Dataset {100}
$ h5ls molecular_dynamics_runs/stage0000/task0001/stage0000_task0001.h5
contact_map              Dataset {100}
fnc                      Dataset {100}
point_cloud              Dataset {100, 3, 28}
rmsd                     Dataset {100}
$ h5ls aggregation_runs/stage0000/task0000/aggregated.h5
contact_map              Dataset {200}
fnc                      Dataset {200}
point_cloud              Dataset {200, 3, 28}
rmsd                     Dataset {200}

```
