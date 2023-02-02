#!/bin/bash
#SBATCH --job-name=deepdrivemd
#SBATCH --partition=a100
#SBATCH --account=oddite
#SBATCH --time=00:30:00
#SBATCH -N 2
#SBATCH -n 12


MD_RUNS=12
ITER_COUNT=1 # TBD
SIM_LENGTH=1.6

NODE_COUNT=2
GPU_PER_NODE=6
MD_START=0
MD_SLICE=$(($MD_RUNS/$NODE_COUNT))
NODE_NAMES=`echo $SLURM_JOB_NODELIST|scontrol show hostnames`

EXPERIMENT_PATH=/qfs/projects/oddite/leeh736/ddmd_runs/test_1600ps
DDMD_PATH=/people/leeh736/git/deepdrivemd
MOLECULES_PATH=/qfs/projects/oddite/leeh736/git/molecules

OPENMM () {

    task_id=$(seq -f "task%04g" $1 $1)
    gpu_idx=$(($1 % $GPU_PER_NODE))
    node_id=$2
    yaml_path=$3
    stage_name="molecular_dynamics"
    dest_path=$EXPERIMENT_PATH/${stage_name}_runs/stage0000/$task_id

    if [ "$yaml_path" == "" ]
    then
        yaml_path=$DDMD_PATH/test/bba/${stage_name}_stage_test.yaml
    fi


    module load python/miniconda3.7 gcc/7.5.0
    source activate openmm

    mkdir -p $dest_path
    cd $dest_path
    echo cd $dest_path

    sed -e "s/\$SIM_LENGTH/${SIM_LENGTH}/" -e "s/\$OUTPUT_PATH/${dest_path//\//\\/}/" -e "s/\$EXPERIMENT_PATH/${EXPERIMENT_PATH//\//\\/}/" -e "s/\$DDMD_PATH/${DDMD_PATH//\//\\/}/" -e "s/\$GPU_IDX/${gpu_idx}/" $yaml_path  > $dest_path/$(basename $yaml_path)
    yaml_path=$dest_path/$(basename $yaml_path)

    PYTHONPATH=$DDMD_PATH:$MOLECULES_PATH srun -w $node_id -n1 -N1 --exclusive python $DDMD_PATH/deepdrivemd/sim/openmm/run_openmm.py -c $yaml_path &> ${task_id}_${FUNCNAME[0]}.log &
    #PYTHONPATH=~/git/molecules/ srun -w $node_id -N1 python /people/leeh736/git/DeepDriveMD-pipeline/deepdrivemd/sim/openmm/run_openmm.py -c $yaml_path &>> $task_id.log &
    #srun -n1 env LD_PRELOAD=~/git/tazer_forked/build.h5/src/client/libclient.so PYTHONPATH=~/git/molecules/ python /people/leeh736/git/DeepDriveMD-pipeline/deepdrivemd/sim/openmm/run_openmm.py -c /qfs/projects/oddite/leeh736/ddmd_runs/test/md_direct.yaml &> $task_id.log &
}

AGGREGATE () {

    task_id=task0000
    stage_name="aggregate"
    dest_path=$EXPERIMENT_PATH/molecular_dynamics_runs/stage0000/$task_id
    yaml_path=$DDMD_PATH/test/bba/${stage_name}_stage_test.yaml


    module load python/miniconda3.7 gcc/7.5.0
    source activate openmm


    sed -e "s/\$SIM_LENGTH/${SIM_LENGTH}/" -e "s/\$OUTPUT_PATH/${dest_path//\//\\/}/" -e "s/\$EXPERIMENT_PATH/${EXPERIMENT_PATH//\//\\/}/" $yaml_path  > $dest_path/$(basename $yaml_path)
    yaml_path=$dest_path/$(basename $yaml_path)

    { time PYTHONPATH=~/git/deepdrivemd/ python $DDMD_PATH/deepdrivemd/aggregation/basic/aggregate.py -c $yaml_path ; } &> ${task_id}_${FUNCNAME[0]}.log 

    #env LD_PRELOAD=/qfs/people/leeh736/git/tazer_forked/build.h5.pread64.bluesky/src/client/libclient.so PYTHONPATH=~/git/deepdrivemd/ python /files0/oddite/deepdrivemd/src/deepdrivemd/aggregation/basic/aggregate.py -c /qfs/projects/oddite/leeh736/ddmd_runs/1k/agg_test.yaml &> agg_test_output.log
}

TRAINING () {

    task_id=task0000
    stage_name="machine_learning"
    dest_path=$EXPERIMENT_PATH/${stage_name}_runs/stage0000/$task_id
    stage_name="training"
    yaml_path=$DDMD_PATH/test/bba/${stage_name}_stage_test.yaml


    mkdir -p $EXPERIMENT_PATH/model_selection_runs/stage0000/task0000/
    cp -p $DDMD_PATH/test/bba/stage0000_task0000.json $EXPERIMENT_PATH/model_selection_runs/stage0000/task0000/

    module load python/miniconda3.7 gcc/7.5.0
    source activate pytorch_sm80

    mkdir -p $dest_path
    cd $dest_path
    echo cd $dest_path

    sed -e "s/\$SIM_LENGTH/${SIM_LENGTH}/" -e "s/\$OUTPUT_PATH/${dest_path//\//\\/}/" -e "s/\$EXPERIMENT_PATH/${EXPERIMENT_PATH//\//\\/}/" $yaml_path  > $dest_path/$(basename $yaml_path)
    yaml_path=$dest_path/$(basename $yaml_path)

   PYTHONPATH=~/git/deepdrivemd/:$MOLECULES_PATH python ~/git/deepdrivemd/deepdrivemd/models/aae/train.py -c $yaml_path &> ${task_id}_${FUNCNAME[0]}.log 

}

INFERENCE () {

    task_id=task0000
    stage_name="inference"
    dest_path=$EXPERIMENT_PATH/${stage_name}_runs/stage0000/$task_id
    yaml_path=$DDMD_PATH/test/bba/${stage_name}_stage_test.yaml


    module load python/miniconda3.7 gcc/7.5.0
    source activate pytorch_sm80

    mkdir -p $dest_path
    cd $dest_path
    echo cd $dest_path

    mkdir -p $EXPERIMENT_PATH/agent_runs/stage0000/task0000/


    sed -e "s/\$SIM_LENGTH/${SIM_LENGTH}/" -e "s/\$OUTPUT_PATH/${dest_path//\//\\/}/" -e "s/\$EXPERIMENT_PATH/${EXPERIMENT_PATH//\//\\/}/" $yaml_path  > $dest_path/$(basename $yaml_path)
    yaml_path=$dest_path/$(basename $yaml_path)


   OMP_NUM_THREADS=4 PYTHONPATH=~/git/deepdrivemd/:$MOLECULES_PATH  python ~/git/deepdrivemd/deepdrivemd/agents/lof/lof.py -c $yaml_path &> ${task_id}_${FUNCNAME[0]}.log 

}
#

# Python environment on Bluesky
module load python/miniconda3.7 gcc/7.5.0
source activate openmm

for iter in $(seq $ITER_COUNT)
do

    # STAGE 1: OpenMM
    for node in $NODE_NAMES
    do
        while [ $MD_SLICE -gt 0 ] && [ $MD_START -lt $MD_RUNS ]
        do
            echo $node
            OPENMM $MD_START $node
            MD_START=$(($MD_START + 1))
            MD_SLICE=$(($MD_SLICE - 1))
        done
        MD_SLICE=$(($MD_RUNS/$NODE_COUNT))
    done

    wait


    # STAGE 2: Aggregate
    srun -N1 $( AGGREGATE )

    wait


    # STAGE 3: Training

    srun -N1 $( TRAINING )

    wait


    # STAGE 4: Inference

    srun $( INFERENCE )

    wait

done
