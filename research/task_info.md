## Task Information

There are four tasks to complete a single iteration starting from `Simulation` to `Agent` in a logical order. The following table shows input/output files types that each task script requires/produces. HDF5 is commonly used across the tasks.

![ddmd](/research/figures/ddmd_diagram.png)


| Order | Task type	| Task Script | Input file(s) | Output file(s) | Input/Output File Count |
| ----- | --------- | ----------- | ------------- | -------------- | ------------- |
| 1     | Simulation | [run_openmm.py](/deepdrivemd/sim/openmm/run_openmm.py) | .pdb | .dcd, .h5, .chk | 1 (input) : 3 (output) | 
| 2     | Aggregation | [aggregate.py](/deepdrivemd/aggregation/basic/aggregate.py) | .h5 files | .h5 | 12 : 1 |
| 3     | Training | [train.py](/deepdrivemd/models/aae/train.py) | .h5 | .pt files, .json files | 1 : 3 |
| 4     | Agent (Outlier) | [lof.py](/deepdrivemd/agents/lof/lof.py) | .pt files, .h5, .dcd files | .pdb files, .json | multiple : multiple | 
- `files` meaning multiple input/output files
- `.pdb`: Protein Data bank file in a plain text format
- `.dcd`: trajectory files (for MD simulation) in a binary format
- `.chk`: checkpoint file i.e. from OpenMM simulation tool
- `.h5`: HDF5 file to keep dataset for training samples
- `.pt`: embeddings from PyTorch
- `.json`: json file to store metadata e.g., loss value

## Record Size with Sample Dataset (data is projected to grow)

A record (a row in a database) is a main entity to directly impact on the size of output produced over the workflow lifetime.  The table below shows small/medium/large examples to demonstrate rapidly increasing data volumes. For example, running `1 picosecond (ps)` simulation time can generate 200 records (`200 * 50` femtosecond report time by default == `1ps`) from a single task, which result in 23.8MB/1.11GB/4.49G/635.70GB of hdf5 preprocessing files for SMALL/MEDIUM I/MEDIUM II/LARGE datasets respectively. Biophysical systems like bba and Spike-ACE2 can be mapped to these sizes for the projected volume of actual datasets.

| Protein System Input         |                 |         |          | Simulation Output (byte) | Aggregation         | Training Output      | Agent (Outlier) Output |
|------------------------------|-----------------|---------|----------|--------------------------|---------------------|----------------------|------------------------|
| Size (Name)                  | Input file size | atoms   | residues | trajectory (.dcd)        | Preprocessing (.h5) | "model (.pt, .json)" | New system (.pdb)      |
| SMALL (e.g. bba)             | <10MB           | 504     | 20       | 6048                     | 1040                | 10M (approx)         | 40320                  |
| MEDIUM I (e.g. adrp)         | <100MB          | 1249    | 155      | 14988                    | 49910               |  10M (approx)             | 99920                  |
| MEDIUM II (e.g. 3clpro)      | <100MB          | 2352    | 314      | 28224                    | 200960              | 10M (approx)            | 188160                 |
| LARGE (e.g. Spike-ACE2 8.5M) | <100GB          | 8562699 | 3768     | 102752388                | 28440864            | 10M (approx)            | 685015920              |

- single record(frame) size of trajectory (.dcd) in byte: `atoms * 3 (dimension) * 4 (float32)`
- single record size of Preprocessing (.h5) e.g., contact_map and point_cloud: `residues ^ 2 * 2 (int16) + residues * 3 (dimensions) * 4 (float32)`
- file size of a new system (.pdb): `atoms * 80 (fixed column length to describe 3D location, xyz of an atom in space)`


## Task Counts (Funnel-shaped data flow)

A number of tasks is presented below for the main components which can scale from 120 to 7680 tasks. It can be typical to increase task counts for expanding simulation space and managing complex systems. 

| Simulation | Aggregation | Training      | Agent (Outlier) | \|V\| | \|E\| | 
| ---------- | ----------- | ------------- | --------------- | -------|----- | 
| 120        | 10          | 3             | 1               | 411    | 542  |
| 240        | 20          | 3             | 1               | 791    | 1052  |
| 480        | 40          | 3             | 1               | 1551    | 2072  |
| 960        | 80          | 3             | 1               | 3071    | 4112  |
| 1920       | 160          | 3             | 1               | 6111    | 8192  |
| 3840       | 320          | 3             | 1               | 12191    | 16532  |
| 7680       | 640          | 3             | 1               | 24351    | 32762  |

- |V| = simulation * (1 task + 2 outputs) + aggregation * (1 task + 1 output) + training * (1 task + 2 outputs) + agent * (1 task + 21 outputs)
- |E| = Σ deg(v) / 2


## Estimated Data Volumes with Common User Settings (accumulated size in MB)

Data volumes can be affected by user settings, and the table below for SMALL/MEDIUM dataset is provided to get close estimate with user settings. The values e.g., 10 iterations with 12:1 aggregation ratio and three concurrent network models have been broadly used according to the experience.

![Simulation-Aggregation](/research/figures/sim_agg_relation.png)

User Settings:
* time step: 10
* iteration: 10
* record count: 200 (per timestep)
* aggregation ratio: 12:1 (sim:agg)
* a number of models: 3
* outliers to detect: 20

###  SMALL (e.g. bba)
| Number of Simulation Tasks | To Aggregation | To Training | To Agent  | To Sim | 
| ---------- | -------------- | ----------- | --------- |------- | 
| 120       | 238.04 MB    | same as left       | 1684.28 MB  | 7.69 MB |
| 240       | 476.07 MB       | same as left      | 3068.55 MB  | 7.69 MB | 
| 480       | 952.15 MB       | same as left      | 5837.11 MB  | 7.69 MB | 
| 960       | 1904.30 MB      | same as left     | 11374.22 MB | 7.69 MB | 
| 1920      | 3808.59 MB      | same as left     | 22448.44 MB | 7.69 MB | 
| 3840      | 7617.19 MB      | same as left    | 44596.88 MB | 7.69 MB | 
| 7680      | 15234.38 MB     | same as left   | 88893.75 MB | 7.69 MB |

* To Aggregation: Size of Simulation output as Aggregation reads
* To Training: Size of Aggregation output as Training reads
* To Agent: Size of Training output and Simulation output as Agent reads
* To Sim: Size of Agent output as Simulation reads in the next iteration

### MEDIUM II (e.g. 3clpro)

| Number of Simulation Tasks | To Aggregation | To Training | To Agent  | To Sim | 
| ---------- | -------------- | ----------- | --------- |------- | 
| 120       | 44.92 GB         | same as left       | 6.60   GB | 35.89 MB |
| 240       | 89.84 GB         | same as left       | 12.91  GB | 35.89 MB  | 
| 480       | 179.67 GB        | same as left       | 25.53  GB | 35.89 MB  | 
| 960       | 359.34 GB        | same as left      | 50.76  GB | 35.89 MB  | 
| 1920      | 718.69 GB        | same as left     | 101.23 GB | 35.89 MB  | 
| 3840      | 1437.38 GB       | same as left     | 202.17 GB | 35.89 MB  | 
| 7680      | 2874.76 GB       | same as left    | 404.04 GB | 35.89 MB  | 

Settings:
* time step: 10
* iteration: 10
* record count: 200 (per timestep)
* aggregation ratio: 12:1 (sim:agg)
* a number of models: 3
* outliers to detect: 20
