# DeepDriveMD


## Code base

### DeepDriveMD local repo

```
/files0/oddite/deepdrivemd/src
```

### Conda environment

```
source /share/apps/python/miniconda3.7/etc/profile.d/conda.sh
conda activate /files0/oddite/conda/ddmd/
```

### BBA protein folding example

```
/files0/oddite/deepdrivemd/src/test/bba/bluesky-md-simulation.yaml 
```

### Experiment output directory

```
/files0/oddite/deepdrivemd/runs/
```

### Test Run 

```
python -m deepdrivemd.deepdrivemd -c <experiment_config.yaml>
```

## Software

### OpenMM - Molecular Dynamics simulation

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
