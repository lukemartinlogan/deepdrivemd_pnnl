# Test Scripts used for paper final evaluations
These scripts are for the variants configurations used in the final evluations. Does not included the measurements for the original pipeline (baseline case).

## Naming
bgfs - the shared storage used is BeeGFS.
nfs - the shared storage used is NFS.
shm - the node-local storage is a tmpfs.
ssd - the node-local storage is a SSD.
cosch - stage 3 (training) and stage 4 (inference) are coscheduled on the same node.

## Path on each test
The default shared storage is controled with `FS_PATH`. The default node-local path is `LOCAL_PATH`. If additional tests are needed, change the two variables accordingly.
