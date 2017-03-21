#!/bin/sh
#PBS -l nodes=1:ppn=1
#PBS -l mem=1gb
#PBS -l scratch=1gb

# it suppose the following variables set:
#
#   FUNC           -- list of integers of functions
#   DIM            -- list of integers of dimensions
#   INST           -- list of instances to process
#   OPTS           -- string with options to be eval()-ed
#   EXPPATH_SHORT  -- usually $APPROOT/exp/experiments

# MATLAB Runtime environment
export LD_LIBRARY_PATH=/storage/plzen1/home/bajeluk/bin/mcr_2016b/v91/runtime/glnxa64:/storage/plzen1/home/bajeluk/bin/mcr_2016b/v91/bin/glnxa64:/storage/plzen1/home/bajeluk/bin/mcr_2016b/v91/sys/os/glnxa64:/storage/plzen1/home/bajeluk/bin/mcr_2016a/v901/runtime/glnxa64:/storage/plzen1/home/bajeluk/bin/mcr_2016a/v901/bin/glnxa64:/storage/plzen1/home/bajeluk/bin/mcr_2016a/v901/sys/os/glnxa64:$LD_LIBRARY_PATH

# Load global settings and variables
. $EXPPATH_SHORT/../bash_settings.sh

MATLAB_BINARY_CALL="exp/metacentrum_testmodels"

export SCRATCHDIR
export LOGNAME

if [ -z "$FUNC" ] ; then
  echo "Error: Task FUNC numbers are not known"; exit 1
fi
if [ -z "$DIM" ] ; then
  echo "Error: Task DIM numbers are not known"; exit 1
fi
if [ -z "$INST" ]; then
  echo "Warning: INST is empty, default instances will be used."
fi
if [ -z "$EXPPATH_SHORT" ] ; then
  echo "Error: directory with the experiment is not known"; exit 1
fi

cd "$EXPPATH_SHORT/../.."

echo "====================="
echo -n "Current dir:    "; pwd
echo -n "Current node:   "; cat "$PBS_NODEFILE"
echo    '$HOME =        ' $HOME
echo    '$MCR_CACHE_ROOT = ' $MCR_CACHE_ROOT
echo    "Will be called:" $MATLAB_BINARY_CALL "$EXPID" "$EXPPATH_SHORT" $ID
echo "====================="

######### CALL #########
#
echo '##############'
echo Will be called: $MATLAB_BINARY_CALL \"$EXPID\" \"$EXPPATH_SHORT\" \"$FUNC\" \"$DIM\" \"$INST\" \"$OPTS\"
echo '##############'

$MATLAB_BINARY_CALL "$EXPID" "$EXPPATH_SHORT" "$FUNC" "$DIM" "$INST" "$OPTS"
#
########################

if [ $? -eq 0 ]; then
  echo `date "+%Y-%m-%d %H:%M:%S"` "  **$EXPID**  ==== FINISHED ===="
  rm -rf $SCRATCHDIR/*
  exit 0
else
  echo `date "+%Y-%m-%d %H:%M:%S"` "  **$EXPID**  ==== ENDED WITH ERROR! ===="
  exit 1
fi
