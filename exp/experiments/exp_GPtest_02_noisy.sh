#!/bin/bash
#
# Job-submitting script for GP model testing

# QUEUE = Metacentrum walltime (2h/4h/1d/2d/1w) -- queue will be decided accordingly
export EXPID='exp_GPtest_02'

# Enable this option for using Matlab MCR compilated binaries:
export useMCR=1

# CWD = Directory of this particular file
CWD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. $CWD/../bash_settings.sh
export EXPPATH_SHORT="$CWD"

export ID
export DIM
export FUNC
export INST
export OPTS
export MATLAB_FCN

subtask() {
  # make sure that these variables will be exported
  export EXPID
  export EXPPATH_SHORT
  export ID
  export DIM
  export INST
  export OPTS
  export FUNC=`echo $FUNC | tr '\n' ' '`
  if [ "$useMCR" == 1 ]; then
    echo "MCR binary submit: ID=$ID : DIM=$DIM : FUNC=$FUNC : INST=$INST"
    qsub -N "${EXPID}__${ID}" -l "walltime=$QUEUE" -v FUNC,DIM,INST,OPTS,EXPID,EXPPATH_SHORT $EXPPATH_SHORT/../modelTesting_binary_metajob.sh
  else
    echo ID=$ID : DIM=$DIM : FUNC=$FUNC : INST=$INST : MATLAB_FCN=$MATLAB_FCN
    # submission on Metacentrum
    # TODO: convert into the new PBS-Pro task scheduler
    qsub -N "${EXPID}__$1" -l "walltime=$QUEUE" -v FUNC,DIM,INST,MATLAB_FCN,EXPID,EXPPATH_SHORT $EXPPATH_SHORT/../modelTesting_metajob.sh && echo "submitted ok."
  fi
  ID=$((ID+1))
}

OPTS=""

QUEUE="48:00:00"
ID=1;

MATLAB_FCN="exp_GPtest_02_noisy"
INST="[1 2 3 4 5 41 42 43 44 45 46 47 48 49 50]"

DIM=2
for i in `seq 101 106`; do
  FUNC=$i; subtask $ID
done

DIM=5
for i in `seq 101 106`; do
  FUNC=$i; subtask $ID
done

DIM=10
for i in `seq 101 106`; do
  FUNC=$i; subtask $ID
done

