#!/bin/bash

USER=$(whoami)


# User directories
MNT_HOME=$HOME #/people/$USER
SCRIPT_DIR=$MNT_HOME/scripts/deepdrivemd/examples/hermes_ddmd
CONFIG_DIR=$SCRIPT_DIR/hermes_configs

DLIFE_VOL_DIR=$SCRIPT_DIR/vol-tracker/src
VOL_NAME="tracker"

# Hermes running dirs -----------

# Hermes config files -----------
DEFAULT_CONF_NAME=hermes_server_default.yaml
HERMES_DEFAULT_CONF=$CONFIG_DIR/$DEFAULT_CONF_NAME

CONF_NAME=hermes_server.yaml
HERMES_CONF=$CONFIG_DIR/$CONF_NAME

CLIENT_CONF_NAME=hermes_client.yaml
HERMES_CLIENT_CONF=$CONFIG_DIR/$CLIENT_CONF_NAME


HERMES_INSTALL_DIR="`which hermes_daemon |sed 's/.\{18\}$//'`"


# Debug
ASAN_LIB=""

# System storage dirs -----------
# export DEV1_DIR="/mnt/nvme/mtang11/hermes_slabs" # first Hermes storage target
# export DEV2_DIR="/mnt/ssd/mtang11/hermes_slabs" # second Hermes torage target

export DEV1_DIR="/tmp/ddmd_test_slab1" # test dir
export DEV2_DIR="/tmp/ddmd_test_slab2" # test dir


# Other tools dirs -----------
LOG_DIR=$SCRIPT_DIR/tmp_outputs
mkdir -p $LOG_DIR

#conda activate /files0/oddite/conda/ddmd/ # original global env
#conda activate hermes_ddmd # local

# export GLOG_minloglevel=2
# export FLAGS_logtostderr=2
export HDF5_USE_FILE_LOCKING='TRUE' #'TRUE'

export HERMES_TRAIT_PATH=$HERMES_INSTALL_DIR/lib
echo "HERMES_TRAIT_PATH = $HERMES_TRAIT_PATH"

export HERMES_PAGESIZE=524288
export HERMES_PAGE_SIZE=524288
# page size : 4096 8192 32768 65536 131072 262144 524288 1048576 4194304 8388608
# default : 1048576