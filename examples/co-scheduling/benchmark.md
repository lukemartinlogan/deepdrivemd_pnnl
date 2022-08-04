# 3 Examples of Running Sim/Agg steps

| Size | N Jobs | Sim (co-sched) | Agg (co-sched) | Simulation (file-based) | Aggregator (file-based) | Sim (adios) | Agg (Adios) |
| ---- | ------ | ----------------------- | ----------------------- | -------------- | -------------- | ----------- | ----------- |
| 100MB | 1   |  7.628s | 0.959s |  9.739s | 2.778s | 44.64s | 15.85s |
| 200MB | 1   | 15.462s | 1.517s |  19.000s |5.039s | 178.19s | 75.35s |
| 400MB | 1   |  29.153s | 3.209s |  36.884s | 10.348s | 299.75s | 245.79s |
| 800MB | 1   |  56.670s | 6.736s |  1min 11.389s |19.983s | -| 778.34s |
| 100MB | 2   | 4.529s | - |   6.122s |- | -| -|
| 200MB | 2   |  8.126s | - |   10.844s |- | -| -|
| 400MB | 2   | 14.870s | - |  20.913s |- | -| -|
| 800MB | 2   | 30.843s |  - |  44.980s |- | -| -|
| 100MB | 4   |  2.506s | - |  4.119s |- | -| -|
| 200MB | 4   | 4.527s |  - |  8.146s |- | -| -|
| 400MB | 4   |  8.023s | - |  15.155s |- | -| -|
| 800MB | 4   |  16.751s | -  |  29.030s |- | -| -|
| 100MB | 8   |  1.603s |- |  3.129s |- | -| -|
| 200MB | 8   |  2.595s | - |  5.950s |- | -| -|
| 400MB | 8   |  4.429s | - |  12.166s |- | -| -|
| 800MB | 8   |  10.178s | - |  24.021s |- | -| -|


## `bench.sh` script

The pseudo code of testing 100MB/200MB/400MB/800MB sizes across 1,2,4 and 8 number of jobs look like:
``
for mbyte in 100 200 400 800
do
   for njob in 1 2 4 8
   do
       for type in 'co-sched' 'shared-file' 'adios'
       do
           python sim_emulator.py -n $njob -f ( $mbyte / $njob ) -n $njob ...(suppressed)...
           python aggregate.py ...(suppressed)...
       done
   done
done
```

### Sample Command lines

With a fixed number of elements (frames, 10k):

- 100MB of h5: `python sim_emulator.py --residue 100 -a 1000 -f 10000 -n 1`
- 200MB of h5: `python sim_emulator.py --residue 145 -a 1000 -f 10000 -n 1`
- 400MB of h5: `python sim_emulator.py --residue 210 -a 1000 -f 10000 -n 1`
- 800MB of h5: `python sim_emulator.py --residue 295 -a 1000 -f 10000 -n 1`

With a same size of elements but increased number of elements:

- 100MB of h5: `python sim_emulator.py --residue 100 -a 1000 -f 10000 -n 1`
- 200MB of h5: `python sim_emulator.py --residue 100 -a 1000 -f 20000 -n 1`
- 400MB of h5: `python sim_emulator.py --residue 100 -a 1000 -f 40000 -n 1`
- 800MB of h5: `python sim_emulator.py --residue 100 -a 1000 -f 80000 -n 1`



## ADIOS Run
simulation output (consumer)
`sst` for the streaming, and `bp` for file store.
```
python sim_emulator.py --residue 100 -n 12 -a 1000 -f 10000 --adios-bp --adios-sst
```
