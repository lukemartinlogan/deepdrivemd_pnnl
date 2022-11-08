# Example of OpenMM Simulation

DeepDriveMD workflow uses the OpenMM tool for MD simulation and this page provides a quick example to run the MD simulation individually. First example is to run a simulation with basic user parameters such as number of simulation steps and hardware platforms to use i.e., CPU or CUDA. This is based on the OpenMM official website: http://docs.openmm.org/latest/userguide/application/02_running_sims.html#a-first-example, but a convenient way to control user input parameters.


## Installation

On Bluesky or other systems, conda python package management is handy to setup the openmm, for example:

```
conda create -n openmm python=3.9
conda activate openmm
conda install -c conda-forge openmm
```
OpenMM 7.7 is currently latest version which will include numpy 1.22.3 and other necessary packages.

## Quick Run

The default parameters are currently defined to run the simulation with an example `input.pdb` biophysical system from: https://github.com/openmm/openmm/tree/master/examples, and values are `10000` for simulation steps, `1000` for reporter, `CPU` for platform which can be adjusted by reading the help message below:

```
$ python openmm_example.py  -h
usage: openmm_example [-h] [-i I] [-s S] [-r R] [-p P] [--device DEVICE] [--precision PRECISION]
                      [--OPENMM_CPU_THREADS OPENMM_CPU_THREADS]

optional arguments:
  -h, --help            show this help message and exit
  -i I                  input pdb filename
  -s S                  number of simulation steps
  -r R                  number of reporter steps
  -p P                  CPU|GPU
  --device DEVICE       GPU Device Index(es)
  --precision PRECISION
                        precision
  --OPENMM_CPU_THREADS OPENMM_CPU_THREADS
                        number of threads in CPU
```

Note that, the simulation steps should be greater than the reporter steps as it indicates how frequently capture the simulation progress throughout the entire simulation steps. The following example runs 5000 simulation steps and 1000 reporter steps so that five output occurences we can observe during the simulation on CPU.

```
python openmm_example.py -s 5000 -r 1000 -p CPU
```

and the output messages look like:
```
Namespace(i='input.pdb', s=5000, r=1000, p='CPU', device='0', precision='double', OPENMM_CPU_THREADS=None)
#"Step","Potential Energy (kJ/mole)","Temperature (K)"
1000,-142543.12210898878,285.55191155652125
2000,-140161.39202585924,300.57551662963766
3000,-140555.47244848614,299.7316835009928
4000,-140221.554517121,297.9402501439115
5000,-140626.19196714423,299.9589626210362
```

And the timing on Bluesky (48 Xeon CPUs @ 2.60GHz) takes about 1 minute for 5000 steps:
```
real    1m16.086s
user    15m31.793s
sys     1m11.165s
```

## Threads on CPU

According to the official documentation, the number of CPU threads can be adjusted using the environment variable, and the example script here override the environment variable by the user input like:

```
python openmm_example.py -p CPU --OPENMM_CPU_THREADS=42
```

FYI, the thread description from the documentation is here: https://docs.openmm.org/latest/userguide/library/04_platform_specifics.html?#cpu-platform

## CUDA Platform

When CUDA is available, the OpenMM simulation script can use a GPU device, for example:

```
python openmm_example.py -p GPU --device 1
```

This specifies GPU index 1 device will be assigned for the OpenMM simulation.
