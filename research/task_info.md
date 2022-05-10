## Task Information
| Task type	| Task Script | Input file(s) | Output file(s) | 
| --------- | ----------- | ------------- | -------------- |  
| Simulation | run_openmm.py | .pdb | .dcd, .h5, .chk | 
| Aggregation | aggregate.py | .h5 files | .h5 | 
| Training | train.py | .h5 | .pt files, .json files | 
| Agent (Outlier) | agent.py | .pt files, .dcd files | .pdb files, .json | 

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
