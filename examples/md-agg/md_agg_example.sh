#!/bin/bash

argv=("$@")
argc=$#
base_path=$(pwd)
system_path=${base_path}/system

if [ $argc -lt 1 ]
then
    echo "syntax: ./$0 (number of md tasks to run) (number o f h5 files to aggregate)"
    echo
    echo "examples:"
    echo "  ./$0 6 (running 6 MD processes and aggregate them all)"
    echo "  ./$0 6 2 (running 6 MD processes and aggregate 2 of them in task idx order)"
    echo
    echo "Note that \"export \$DDMD_LOCAL_GIT_PATH=\" must be set to locate scripts i.e., run_openmm.py"
    exit
fi

if [ "$DDMD_LOCAL_GIT_PATH" == "" ]
then
    echo "\$DDMD_LOCAL_GIT_PATH is missing"
    exit
else
    echo 
    echo ----------------------------------------------------------
    echo $DDMD_LOCAL_GIT_PATH is to lookup ddmd scripts and data
    echo ----------------------------------------------------------
    echo
fi

task_cnt=${argv[0]}
echo ----------------------------------------------------------
echo "$task_cnt md process(es) will be executed."
echo ----------------------------------------------------------
task_cnt_for_seq=$((${task_cnt}-1))

# systems copied
#mkdir -p $system_path
#cp -pr $DDMD_LOCAL_GIT_PATH/data/bba/* system/
ln -sf $DDMD_LOCAL_GIT_PATH/data/bba ./system
#initial_pdb_dir: /files0/oddite/deepdrivemd/src/data/bba


stage_id="stage0000"
md_base_path="molecular_dynamics_runs/${stage_id}/"
agg_base_path="aggregation_runs/${stage_id}/"

# Prepare YAML configurations for each md run
for task_id in `seq -f "task%04g" 0 $task_cnt_for_seq`
do
    mkdir -p ${md_base_path}/${task_id}
    task_yml_path="${md_base_path}/${task_id}/md_direct_${task_id}.yml"
    sed -e "s/\$TASKID/${task_id}/" -e "s/\$SYSTEM_PATH/${system_path//\//\\/}/" md_direct_template.yml > $task_yml_path
done

for task_id in `seq -f "task%04g" 0 $task_cnt`
do
    md_task_yml_path="${md_base_path}/${task_id}/md_direct_${task_id}.yml"
    echo python $DDMD_LOCAL_GIT_PATH/deepdrivemd/sim/openmm/run_openmm.py -c $md_task_yml_path \&
    python $DDMD_LOCAL_GIT_PATH/deepdrivemd/sim/openmm/run_openmm.py -c $md_task_yml_path &
done

# sync
wait

if [ $argc -gt 1 ]
then
    md_cnt_to_agg=${argv[1]}
else
    md_cnt_to_agg=$task_cnt
fi

echo ----------------------------------------------------------
echo "$md_cnt_to_agg outputs (.h5) will be aggregated."
echo ----------------------------------------------------------

# Aggregation
task_id="task0000"
agg_task_yml_path="${agg_base_path}/${task_id}/agg_direct_${md_cnt_to_agg}_files.yml"
sed "s/\$MD_CNT/${md_cnt_to_agg}/" agg_direct_template.yml > $agg_task_yml_path
echo python $DDMD_LOCAL_GIT_PATH/deepdrivemd/aggregation/basic/aggregate.py -c $agg_task_yml_path
python $DDMD_LOCAL_GIT_PATH/deepdrivemd/aggregation/basic/aggregate.py -c $agg_task_yml_path

