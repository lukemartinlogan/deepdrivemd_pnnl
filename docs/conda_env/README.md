# Environment Setup from Scratch

## Prepare DDMD Env
## DDMD Python Packagse
### molecules
```
git clone https://github.com/braceal/molecules.git $MOLECULES_PATH
cd $MOLECULES_PATH
pip install .
```
## DDMD Conda Environment
### miniconda3
Get the conda installation script and run it: `wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh` \
The current conda version tested work that works `conda 23.3.1`.


### Build Conda Env for Stage 1 & 2 (OPENMM & AGGREGATE)
```
conda create --name openmm7_ddmd
conda activate openmm7_ddmd
conda install -c omnia openmm=7.4
conda install -c omnia -c conda-forge openmm=7.4
python -m simtk.testInstallation # test installation
pip install pyyaml radical.entk simtk.unit numpy MDAnalysis==2.0.0 pydantic==1.9.0
```
#### Install MD-Tools
h5py==3.8.0 uses HDF5-1.14.0 (use this for openmm<=7.4 version)
```
git clone https://github.com/candiceT233/MD-tools ${MD_TOOL_PATH} 
cd $MD_TOOL_PATH
pip install .
```

### Build Conda Env for Stage 3 & 4 (TRAIN & INFERENCE)
Build pytorch-cpu and other dependencies.
```
conda create --name ddmd_pytorch python=3.7
source activate ddmd_pytorch
conda install -c conda-forge pytorch-cpu
pip install scikit-learn scipy matplotlib molecules wandb mpi4py torch MDAnalysis==2.0.0 pydantic==1.9.0
pip install deepdrivemd --no-dependencies
pip install h5py==3.8.0
```