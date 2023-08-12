#!/bin/bash

for mbyte in 100 200 400 800
do
    for njob in 1 2 4 8
    do
        each_mbyte=$(expr $mbyte / $njob)
        for mode in "file_based" "co_scheduling" "adios"
        do
            adios_on=""
            if [ "$mode" == "file_based" ]
            then
                # shared filesystem e.g., NFS/LUSTER/GPFS
                cd /qfs/projects/oddite/leeh736
            elif [ "$mode" == "co_scheduling" ]
            then
                cd /files0/oddite/deepdrivemd/src/example/co-scheduling
            fi

            if [ "$mode" != "adios" ]
            then
                # producer (simulation output)
                { time python /files0/oddite/deepdrivemd/src/examples/co-scheduling/sim_emulator.py --residue 100 -n $njob -a 1000 -f $(expr 100 \* $each_mbyte) ; } 2> $mode.$mbyte.$njob.log
                echo time python /files0/oddite/deepdrivemd/src/examples/co-scheduling/sim_emulator.py --residue 100 -n $njob -a 1000 -f $(expr 100 \* $each_mbyte) to $mode.$mbyte.$njob.log

                # consumer (aggregator to concatenate)
                { time python aggregate.py -no_rmsd -no_fnc --input_path . --output_path ./aggregate.$mbyte.$njob.h5 ; } 2> agg.$mode.$mbyte.$njob.log
            else
                #Running these concurrently by background mode
                adios_on=" --adios-bp --adios-sst"
                # producer
                python /files0/oddite/deepdrivemd/src/examples/co-scheduling/sim_emulator.py --residue 100 -n $njob -a 1000 -f $(expr 100 \* $each_mbyte) $adios_on &> $mode.$mbyte.$njob.log &
                # consumer
                PYTHONPATH=/people/leeh736/git/DeepDriveMD-pipeline:$PYTHONPATH python ~/git/DeepDriveMD-pipeline/deepdrivemd/aggregation/stream/aggregator.py -c /qfs/projects/oddite/leeh736/bluesky-md-simulation.yaml &> agg.adios.$mbyte.$njob.log &
                echo  PYTHONPATH=/people/leeh736/git/DeepDriveMD-pipeline:$PYTHONPATH python ~/git/DeepDriveMD-pipeline/deepdrivemd/aggregation/stream/aggregator.py -c /qfs/projects/oddite/leeh736/bluesky-md-simulation.yaml  agg.adios.$mbyte.$njob.log 
            fi
            wait
        done
    done
done
