#!/bin/bash
#SBATCH --job-name=ddmd_100ps_1n12ti1_nfs_0
#SBATCH --time=00:30:00
#SBATCH -N 1
#SBATCH -n 12
#SBATCH --output=./R_%x.out
#SBATCH --error=./R_%x.err

SHORTENED_PIPELINE=false
MD_RUNS=12
ITER_COUNT=1 # TBD
SIM_LENGTH=0.1

DROP_CACHE=false

# export HDF5_PAGE_BUFFER_SIZE=1048576 # 4096 8192 32768 65536 131072 262144 524288 1048576 4194304 8388608
# echo "HDF5_PAGE_BUFFER_SIZE=$HDF5_PAGE_BUFFER_SIZE"

NODE_COUNT=$SLURM_JOB_NUM_NODES
GPU_PER_NODE=6
MD_START=0
MD_SLICE=$(($MD_RUNS/$NODE_COUNT))
NODE_NAMES=`echo $SLURM_JOB_NODELIST|scontrol show hostnames`
STAGE_IDX=0
STAGE_IDX_FORMAT=$(seq -f "stage%04g" $STAGE_IDX $STAGE_IDX)

NODE_NAMES=`echo $SLURM_JOB_NODELIST|scontrol show hostnames`


# EXPERIMENT_PATH=/qfs/projects/oddite/leeh736/ddmd_runs/adjusted_ddmd_stages
# DDMD_PATH=/people/leeh736/git/deepdrivemd
# MOLECULES_PATH=/qfs/projects/oddite/leeh736/git/molecules
SIZE=$(echo "$SIM_LENGTH * 1000" | bc)
SIZE=${SIZE%.*}
TRIAL="nfs1"
FS_PATH="NFS"

TEST_OUT_PATH=test_${SIZE}ps_i${ITER_COUNT}_${TRIAL}

set -x
if [ "$FS_PATH" == "NFS" ]
then
    echo "Running on NFS"
    export EXPERIMENT_PATH=~/experiments/$USER/ddmd_runs/$TEST_OUT_PATH #NFS
    export DDMD_PATH=/home/mtang11/scripts/deepdrivemd #NFS
    export MOLECULES_PATH=/home/mtang11/scripts/deepdrivemd/examples/hermes_ddmd/molecules #NFS
else
    echo "Running on PFS"
    echo "PFS not available yet"
    exit 1

    export EXPERIMENT_PATH=~/experiments/$USER/ddmd_runs/$TEST_OUT_PATH #NFS
    export DDMD_PATH=/home/mtang11/scripts/deepdrivemd #NFS
    export MOLECULES_PATH=/home/mtang11/scripts/deepdrivemd/examples/hermes_ddmd/molecules #NFS
fi
set +x

mkdir -p $EXPERIMENT_PATH/*
rm -rf $EXPERIMENT_PATH/*
ls $EXPERIMENT_PATH/* -hl


# load environment variables for Hermes
ulimit -c unlimited
source $HOME/scripts/deepdrivemd/examples/hermes_ddmd/load_hermes_deps.sh
# source $HOME/scripts/deepdrivemd/examples/hermes_ddmd/env_var.sh # for Hermes

mkdir -p $DEV1_DIR/hermes_slabs
mkdir -p $DEV2_DIR/hermes_slabs
rm -rf $DEV1_DIR/hermes_slabs/*
rm -rf $DEV2_DIR/hermes_slabs/*


OPENMM () {

    task_id=$(seq -f "task%04g" $1 $1)
    gpu_idx=$(($1 % $GPU_PER_NODE))
    node_id=$2
    yaml_path=$3
    stage_name="molecular_dynamics"
    dest_path=$EXPERIMENT_PATH/${stage_name}_runs/$STAGE_IDX_FORMAT/$task_id

    if [ "$yaml_path" == "" ]
    then
        yaml_path=$DDMD_PATH/test/bba/${stage_name}_stage_test.yaml
    fi

    eval "$(~/miniconda3/bin/conda shell.bash hook)" # conda init bash
    source activate hermes_openmm7_ddmd

    mkdir -p $dest_path
    cd $dest_path
    echo "Running OPENMM at $node_id ..."
    echo cd $dest_path

    sed -e "s/\$SIM_LENGTH/${SIM_LENGTH}/" -e "s/\$OUTPUT_PATH/${dest_path//\//\\/}/" -e "s/\$EXPERIMENT_PATH/${EXPERIMENT_PATH//\//\\/}/" -e "s/\$DDMD_PATH/${DDMD_PATH//\//\\/}/" -e "s/\$GPU_IDX/${gpu_idx}/" -e "s/\$STAGE_IDX/${STAGE_IDX}/" $yaml_path  > $dest_path/$(basename $yaml_path)
    yaml_path=$dest_path/$(basename $yaml_path)

    PYTHONPATH=$DDMD_PATH:$MOLECULES_PATH srun -w $node_id -n1 -N1 --exclusive ~/.conda/envs/hermes_openmm7_ddmd/bin/python $DDMD_PATH/deepdrivemd/sim/openmm/run_openmm.py -c $yaml_path &> ${task_id}_${FUNCNAME[0]}.log &
    #PYTHONPATH=~/git/molecules/ srun -w $node_id -N1 python /people/leeh736/git/DeepDriveMD-pipeline/deepdrivemd/sim/openmm/run_openmm.py -c $yaml_path &>> $task_id.log &
    #srun -n1 env LD_PRELOAD=~/git/tazer_forked/build.h5/src/client/libclient.so PYTHONPATH=~/git/molecules/ python /people/leeh736/git/DeepDriveMD-pipeline/deepdrivemd/sim/openmm/run_openmm.py -c /qfs/projects/oddite/leeh736/ddmd_runs/test/md_direct.yaml &> $task_id.log &
}

AGGREGATE () {

    echo "Running AGGREGATE ..."

    task_id=task0000
    stage_name="aggregate"
    STAGE_IDX=$(($STAGE_IDX - 1))
    STAGE_IDX_FORMAT=$(seq -f "stage%04g" $STAGE_IDX $STAGE_IDX)
    dest_path=$EXPERIMENT_PATH/molecular_dynamics_runs/$STAGE_IDX_FORMAT/task0000
    yaml_path=$DDMD_PATH/test/bba/${stage_name}_stage_test.yaml

    eval "$(~/miniconda3/bin/conda shell.bash hook)" # conda init bash
    source activate hermes_openmm7_ddmd

    sed -e "s/\$SIM_LENGTH/${SIM_LENGTH}/" -e "s/\$OUTPUT_PATH/${dest_path//\//\\/}/" -e "s/\$EXPERIMENT_PATH/${EXPERIMENT_PATH//\//\\/}/" -e "s/\$STAGE_IDX/${STAGE_IDX}/" $yaml_path  > $dest_path/$(basename $yaml_path)
    yaml_path=$dest_path/$(basename $yaml_path)

    { time PYTHONPATH=$DDMD_PATH/ ~/.conda/envs/hermes_openmm7_ddmd/bin/python $DDMD_PATH/deepdrivemd/aggregation/basic/aggregate.py -c $yaml_path ; } &> ${task_id}_${FUNCNAME[0]}.log 

    #env LD_PRELOAD=/qfs/people/leeh736/git/tazer_forked/build.h5.pread64.bluesky/src/client/libclient.so PYTHONPATH=$DDMD_PATH/ python /files0/oddite/deepdrivemd/src/deepdrivemd/aggregation/basic/aggregate.py -c /qfs/projects/oddite/leeh736/ddmd_runs/1k/agg_test.yaml &> agg_test_output.log
}

TRAINING () {
    echo "Running TRAINING ..."

    task_id=task0000
    stage_name="machine_learning"
    dest_path=$EXPERIMENT_PATH/${stage_name}_runs/$STAGE_IDX_FORMAT/$task_id
    stage_name="training"
    yaml_path=$DDMD_PATH/test/bba/${stage_name}_stage_test.yaml

    echo "TRAINING yaml_path=$yaml_path"


    mkdir -p $EXPERIMENT_PATH/model_selection_runs/$STAGE_IDX_FORMAT/task0000/
    cp -p $DDMD_PATH/test/bba/stage0000_task0000.json $EXPERIMENT_PATH/model_selection_runs/$STAGE_IDX_FORMAT/task0000/${STAGE_IDX_FORMAT}_task0000.json

    eval "$(~/miniconda3/bin/conda shell.bash hook)" # conda init bash
    source activate hm_ddmd_pytorch_deception

    mkdir -p $dest_path
    cd $dest_path
    echo cd $dest_path

    sed -e "s/\$SIM_LENGTH/${SIM_LENGTH}/" -e "s/\$OUTPUT_PATH/${dest_path//\//\\/}/" -e "s/\$EXPERIMENT_PATH/${EXPERIMENT_PATH//\//\\/}/" -e "s/\$STAGE_IDX/${STAGE_IDX}/" $yaml_path  > $dest_path/$(basename $yaml_path)
    yaml_path=$dest_path/$(basename $yaml_path)

   echo PYTHONPATH=$DDMD_PATH/:$MOLECULES_PATH srun -n1 -N1 --exclusive ~/.conda/envs/hm_ddmd_pytorch_deception/bin/python $DDMD_PATH/deepdrivemd/models/aae/train.py -c $yaml_path ${task_id}_${FUNCNAME[0]}.log 
   if [ "$SHORTENED_PIPELINE" == true ]
   then
       PYTHONPATH=$DDMD_PATH/:$MOLECULES_PATH srun -n1 -N1 --exclusive ~/.conda/envs/hm_ddmd_pytorch_deception/bin/python $DDMD_PATH/deepdrivemd/models/aae/train.py -c $yaml_path &> ${task_id}_${FUNCNAME[0]}.log &
   else
       PYTHONPATH=$DDMD_PATH/:$MOLECULES_PATH srun -n1 -N1 --exclusive ~/.conda/envs/hm_ddmd_pytorch_deception/bin/python $DDMD_PATH/deepdrivemd/models/aae/train.py -c $yaml_path &> ${task_id}_${FUNCNAME[0]}.log
   fi

}

INFERENCE () {
    echo "Running INFERENCE ..."

    task_id=task0000
    stage_name="inference"
    dest_path=$EXPERIMENT_PATH/${stage_name}_runs/$STAGE_IDX_FORMAT/$task_id
    yaml_path=$DDMD_PATH/test/bba/${stage_name}_stage_test.yaml
    pretrained_model=$DDMD_PATH/data/bba/epoch-130-20201203-150026.pt


    eval "$(~/miniconda3/bin/conda shell.bash hook)" # conda init bash
    source activate hm_ddmd_pytorch_deception

    mkdir -p $dest_path
    cd $dest_path
    echo cd $dest_path

    mkdir -p $EXPERIMENT_PATH/agent_runs/$STAGE_IDX_FORMAT/task0000/


    sed -e "s/\$SIM_LENGTH/${SIM_LENGTH}/" -e "s/\$OUTPUT_PATH/${dest_path//\//\\/}/" -e "s/\$EXPERIMENT_PATH/${EXPERIMENT_PATH//\//\\/}/" -e "s/\$STAGE_IDX/${STAGE_IDX}/" $yaml_path  > $dest_path/$(basename $yaml_path)
    yaml_path=$dest_path/$(basename $yaml_path)

    # latest model search
    model_checkpoint=$(find $EXPERIMENT_PATH/machine_learning_runs/*/*/checkpoint -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" ")
    if [ "$model_checkpoint" == "" ] && [ "$SHORTENED_PIPELINE" == true ]
    then
        model_checkpoint=$pretrained_model
    fi
    

    STAGE_IDX_PREV=$((STAGE_IDX - 1))
    STAGE_IDX_FORMAT_PREV=$(seq -f "stage%04g" $STAGE_IDX_PREV $STAGE_IDX_PREV)

    # if [ "$STAGE_IDX_PREV" == "2"]
    # then
    #     model_checkpoint=$pretrained_model
    # fi

    sed -i -e "s/\$MODEL_CHECKPOINT/${model_checkpoint//\//\\/}/"  $EXPERIMENT_PATH/model_selection_runs/$STAGE_IDX_FORMAT_PREV/task0000/${STAGE_IDX_FORMAT_PREV}_task0000.json

    echo "model_checkpoint = $model_checkpoint"

    # OMP_NUM_THREADS=4 PYTHONPATH=$DDMD_PATH/:$MOLECULES_PATH srun -N1 ~/.conda/envs/hm_ddmd_pytorch_deception/bin/python $DDMD_PATH/deepdrivemd/agents/lof/lof.py -c $yaml_path &> ${task_id}_${FUNCNAME[0]}.log 
    OMP_NUM_THREADS=4 PYTHONPATH=$DDMD_PATH/:$MOLECULES_PATH ~/.conda/envs/hm_ddmd_pytorch_deception/bin/python $DDMD_PATH/deepdrivemd/agents/lof/lof.py -c $yaml_path &> ${task_id}_${FUNCNAME[0]}.log     

}


STAGE_UPDATE() {

    STAGE_IDX=$(($STAGE_IDX + 1))
    tmp=$(seq -f "stage%04g" $STAGE_IDX $STAGE_IDX)
    echo $tmp
}


# conda environment on Deception
eval "$(~/miniconda3/bin/conda shell.bash hook)" # conda init bash

total_start_time=$SECONDS
# total_drop_cache_time=$(($(date +%s%N)/1000000))
drop_cache_time=0

for iter in $(seq $ITER_COUNT)
do

    # Drop Cache
    if [ "$DROP_CACHE" == true ] then
        dc_start_time=$(($(date +%s%N)/1000000))
        srun -n$SLURM_JOB_NUM_NODES -w $hostlist sudo /sbin/sysctl vm.drop_caches=3
        dc_duration=$(( $(date +%s%N)/1000000 - $dc_start_time))
        drop_cache_time=$(( $drop_cache_time + $dc_duration ))
        echo "Current drop_cache_time (ms) : $drop_cache_time"
    fi
    # STAGE 1: OpenMM
    start_time=$SECONDS
    for node in $NODE_NAMES
    do
        while [ $MD_SLICE -gt 0 ] && [ $MD_START -lt $MD_RUNS ]
        do
            
            OPENMM $MD_START $node
            MD_START=$(($MD_START + 1))
            MD_SLICE=$(($MD_SLICE - 1))
        done
        MD_SLICE=$(($MD_RUNS/$NODE_COUNT))
    done

    MD_START=0

    wait

    duration=$(($SECONDS - $start_time))
    echo "OpenMM done... $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed ($duration secs)."

    # STAGE_IDX_FORMAT="$(STAGE_UPDATE)"
    # STAGE_IDX=$((STAGE_IDX + 1))
    # echo $STAGE_IDX_FORMAT

    # # Drop Cache
    # if [ "$DROP_CACHE" == true ] then
    #     dc_start_time=$(($(date +%s%N)/1000000))
    #     srun -n$SLURM_JOB_NUM_NODES -w $hostlist sudo /sbin/sysctl vm.drop_caches=3
    #     dc_duration=$(( $(date +%s%N)/1000000 - $dc_start_time))
    #     drop_cache_time=$(( $drop_cache_time + $dc_duration ))
    #     # echo "Current drop_cache_time (ms) : $drop_cache_time"
    # fi

    # # STAGE 2: Aggregate
    # if [ "$SHORTENED_PIPELINE" != true ]
    # then
    #     start_time=$SECONDS
    #     srun -N1 $( AGGREGATE )
    #     wait 
    #     duration=$(($SECONDS - $start_time))
    #     echo "Aggregate done... $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed ($duration secs)."
    # else
    #     echo "No AGGREGATE, SHORTENED_PIPELINE = $SHORTENED_PIPELINE..."
    # fi

    # wait

    # STAGE_IDX_FORMAT="$(STAGE_UPDATE)"
    # STAGE_IDX=$((STAGE_IDX + 1))
    # echo $STAGE_IDX_FORMAT

    # # Drop Cache
    # if [ "$DROP_CACHE" == true ] then
    #     dc_start_time=$(($(date +%s%N)/1000000))
    #     srun -n$SLURM_JOB_NUM_NODES -w $hostlist sudo /sbin/sysctl vm.drop_caches=3
    #     dc_duration=$(( $(date +%s%N)/1000000 - $dc_start_time))
    #     drop_cache_time=$(( $drop_cache_time + $dc_duration ))
    #     # echo "Current drop_cache_time (ms) : $drop_cache_time"
    # fi
    # # STAGE 3: Training
    # start_time=$SECONDS
    # if [ "$SHORTENED_PIPELINE" != true ]
    # then
    #     TRAINING
    #     duration=$(($SECONDS - $start_time))
    #     echo "Training done... $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed ($duration secs)."
    # else
    #     TRAINING
    #     echo "Training not waited, SHORTENED_PIPELINE = $SHORTENED_PIPELINE..."
    # fi
    

    # STAGE_IDX_FORMAT="$(STAGE_UPDATE)"
    # STAGE_IDX=$((STAGE_IDX + 1))
    # echo $STAGE_IDX_FORMAT
    # if [ "$SHORTENED_PIPELINE" != true ]
    # then
    #     wait
    # fi

    # # Drop Cache
    # if [ "$DROP_CACHE" == true ] then
    #     dc_start_time=$(($(date +%s%N)/1000000))
    #     srun -n$SLURM_JOB_NUM_NODES -w $hostlist sudo /sbin/sysctl vm.drop_caches=3
    #     dc_duration=$(( $(date +%s%N)/1000000 - $dc_start_time))
    #     drop_cache_time=$(( $drop_cache_time + $dc_duration ))
    #     # echo "Current drop_cache_time (ms) : $drop_cache_time"
    # fi
    # # STAGE 4: Inference
    # start_time=$SECONDS
    # # srun -N1 $( INFERENCE )
    # INFERENCE

    # wait
    # duration=$(($SECONDS - $start_time))
    # echo "Inference done... $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed ($duration secs)."

    # STAGE_IDX_FORMAT="$(STAGE_UPDATE)"
    # STAGE_IDX=$((STAGE_IDX + 1))
    # echo $STAGE_IDX_FORMAT

done


total_duration=$(($SECONDS - $total_start_time))
echo "All done... $(($total_duration / 60)) minutes and $(($total_duration % 60)) seconds elapsed ($total_duration secs)."
echo "Drop cache time: $drop_cache_time milliseconds elapsed."

ls $EXPERIMENT_PATH/*/*/* -hl

hostname;date;
sacct -j $SLURM_JOB_ID -o jobid,submit,start,end,state