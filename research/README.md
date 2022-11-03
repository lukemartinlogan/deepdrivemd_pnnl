# Research

- [performance characteristics](perf.md)
- [Task Information & Volume Analysis for Workflow Input/Output](task_info.md)
- [Workflow Simulator for Co-scheduling](/examples/co-scheduling/)
- [Comparison between file-based and adios](examples/co-scheduling/benchmark.md)


To run MD on bluesky:
```
source /share/apps/python/miniconda3.7/etc/profile.d/conda.sh
conda activate /files0/oddite/conda/ddmd/
mkdir test_run
cd test_run
python /files0/oddite/deepdrivemd/src/deepdrivemd/sim/openmm/run_openmm.py -c /files0/oddite/deepdrivemd/src/test/bba/md_direct.yml
```

