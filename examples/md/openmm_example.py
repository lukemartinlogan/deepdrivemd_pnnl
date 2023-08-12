from openmm.app import *
from openmm import *
from openmm.unit import *
from sys import stdout

import argparse
import os

def openmm_example(pdbfile, steps, rsteps, platform, properties):
    pdb = PDBFile(pdbfile)
    forcefield = ForceField('amber14-all.xml', 'amber14/tip3pfb.xml')
    system = forcefield.createSystem(pdb.topology, nonbondedMethod=PME,
                    nonbondedCutoff=1*nanometer, constraints=HBonds)
    integrator = LangevinMiddleIntegrator(300*kelvin, 1/picosecond, 0.004*picoseconds)

    platform = Platform.getPlatformByName(platform)
    simulation = Simulation(pdb.topology, system, integrator, platform, properties)
    simulation.context.setPositions(pdb.positions)
    simulation.minimizeEnergy()
    simulation.reporters.append(PDBReporter('output.pdb', rsteps))
    simulation.reporters.append(StateDataReporter(stdout, rsteps, step=True,
                potentialEnergy=True, temperature=True))
    simulation.step(steps)


def get_argparse():
    parser = argparse.ArgumentParser("openmm_example")
    parser.add_argument("-i", help="input pdb filename", default="input.pdb")
    parser.add_argument("-s", help="number of simulation steps", type=int, default=10000)
    parser.add_argument("-r", help="number of reporter steps", type=int, default=1000)
    parser.add_argument("-p", help="CPU|GPU", default="CPU")
    parser.add_argument("--device", help="GPU Device Index(es)", default="0")
    parser.add_argument("--precision", help="precision", default="double")
    parser.add_argument("--OPENMM_CPU_THREADS", help="number of threads in CPU", default="")
    args = parser.parse_args()
    return args


if __name__ == "__main__":
    args = get_argparse()
    print(args)
    if args.p == "GPU":
        properties = {'DeviceIndex': args.device, 'Precision': args.precision}
    else:
        properties = {}
    if args.OPENMM_CPU_THREADS:
        os.environ['OPENMM_CPU_THREADS'] = args.OPENMM_CPU_THREADS
    openmm_example(pdbfile = args.i, steps = args.s, \
            rsteps = args.r,
            platform = args.p,
            properties = properties)
 
