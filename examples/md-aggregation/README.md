# MD/Aggregation Example

This page provides an example of running MD/Aggregation tasks from DeepDriveMD
workflow.

## Installation

It will require to install DeepDriveMD specific packages such as OpenMM=7.4.0
and Python 3.7x for the compatibility. For example, the latest OpenMM 7.7.0 may
not be backward compatible to DeepDriveMD 0.0.2.

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

MD/Aggregation tasks (python scripts) are directly called from the local github
repository.  And the example requires to use the environment vabiable to lookup
the path:

```
git clone https://gitlab.pnnl.gov/perf-lab/workflows/deepdrivemd.git
export DDMD_LOCAL_GIT_PATH=`pwd`/deepdrivemd
```

After this environment is set, MD/Agg tasks are used to call like:
```
(md) python $DDMD_LOCAL_GIT_PATH/sim/openmm/run_openmm.py
(agg) python $DDMD_LOCAL_GIT_PATH/aggregation/basic/aggregate.py
```

## How to Run

The shell script is provided to run MD simulations (`run_openmm.py`) and
aggregation (`aggregate.py`) sequentially. And the user parameter specifies how
many MD processes will be launched (1st param) and the number of output files
(.h5) to aggregate from the simulation (2nd param). For example:

```
$ bash md_agg_example.sh
syntax: ./md_agg_example.sh (number of md tasks to run) (number o f h5 files to aggregate)

examples:
  ./md_agg_example.sh 6 (running 6 MD processes and aggregate them all)
  ./md_agg_example.sh 6 2 (running 6 MD processes and aggregate 2 of them in task idx order)

Note that "export $DDMD_LOCAL_GIT_PATH=" must be set to locate scripts i.e., run_openmm.py
```

The current directory will be a working directory which will create
files/sub-directories by following DeepDriveMD API :

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

### 2 MD processes and Aggregation (Example)

The following command indicates to run 2 md processes and then aggregate 2
output .h5 files specifically. The second parameter (for the number of md
output files to aggregate) can be omitted to aggregate all output files.

```
$ ./md_agg_example.sh 2 2 
```

#### Timing

On Bluesky, each md with basic settings e.g. bba input system and 0.1 ns
simulation time steps would take about 4 minutes:

```
real    4m34.677s
user    15m1.858s
sys     4m46.647s
```

### Output (.h5) files

The default settings (`md_direct_template.yml`) are 0.1 ns simulation time
steps with 1ps reporter steps `simulation_length_ns: 0.1` and
`report_interval_ps: 1.0` which will generate 100 records in the hdf5 dataset,
for example, two h5 files are produced and 1 aggregated file contains 200
records:

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

## Aggregation Only

If you already have output (.h5) files from MD, and wants to aggregate only, the script (aggregate.py) can be called with the configuration file in YAML format.

[Template file](agg_direct_template.yml) is provided which contains:
```
rmsd: True
fnc: True
contact_map: True
point_clud: True
experiment_directory: ./
output_path: aggregation_runs/stage0000/task0000/aggregated.h5
last_n_h5_files: $MD_CNT
```

- rmsd: boolean value to aggregate or not, one of the dataset from md output (Root-mean-square deviation)
- fnc:  boolean value to aggregate or not, one of the dataset from md output (fraction of contacts)
- contact_map:  boolean value to aggregate or not, contact map of residues
- point_cloud:  boolean value to aggregate or not, point clouds for 3d-AAE
- experiment_directory: path to find all md output (.h5) under DeepDriveMD API, therefore `molecular_dynamics_runs/stageXXXX/taskXXXX` will be followed to find matches
- output_path: path to save aggregated file in .h5
- last_n_h5_files: integer, to indicate a number of md output files to aggregate. None for collecting all

Once you have adjusted yaml file ready, the syntax to run the script is like:
```
python ./deepdrivemd/aggregation/basic/aggregate.py -c (new yaml filename)
```
