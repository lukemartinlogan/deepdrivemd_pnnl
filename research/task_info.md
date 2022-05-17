## Task Information
| Task type	| Task Script | Input file(s) | Output file(s) | 
| --------- | ----------- | ------------- | -------------- |  
| Simulation | run_openmm.py | .pdb | .dcd, .h5, .chk | 
| Aggregation | aggregate.py | .h5 files | .h5 | 
| Training | train.py | .h5 | .pt files, .json files | 
| Agent (Outlier) | agent.py | .pt files, .dcd files | .pdb files, .json | 
- `files` meaning multiple input/output files

## Record Size with Sample Dataset

| Protein System Input         |                 |         |          | Simulation Output (byte) |                     | Training Output      | Agent (Outlier) Output |
|------------------------------|-----------------|---------|----------|--------------------------|---------------------|----------------------|------------------------|
| Size (Name)                  | Input file size | atoms   | residues | trajectory (.dcd)        | Preprocessing (.h5) | "model (.pt, .json)" | New system (.pdb)      |
| SMALL (e.g. bba)             | <10MB           | 504     | 20       | 6048                     | 1040                | 10M (approx)         | 40320                  |
| MEDIUM I (e.g. adrp)         | <100MB          | 1249    | 155      | 14988                    | 49910               |                      | 99920                  |
| MEDIUM II (e.g. 3clpro)      | <100MB          | 2352    | 314      | 28224                    | 200960              |                      | 188160                 |
| LARGE (e.g. Spike-ACE2 8.5M) | <100GB          | 8562699 | 3768     | 102752388                | 28440864            |                      | 685015920              |

- single record(frame) size of trajectory (.dcd): `atoms * 3 (dimension) * 4 (float32)`
- single record size of Preprocessing (.h5) e.g., contact_map and point_cloud: `residues ^ 2 * 2 (int16) + residues * 3 (dimensions) * 4 (float32)`
- file size of a new system (.pdb): `atoms * 80 (column length)`



## Workflow size with Vertex and Edge Count 

* A number of tasks is presented for main components (Simulation, Aggregation, Training and Agent)
* 1 iteration only

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

## Data Volumes To Transfer Between Components (accumulated, size in MB)

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

Settings:
* time step: 10
* iteration: 10
* record count: 200 (per timestep)
* aggregation ratio: 12:1 (sim:agg)
* a number of models: 3
* outliers to detect: 20

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
