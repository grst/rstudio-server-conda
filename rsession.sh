#!/bin/bash

CORES=8
USER=`whoami`
source /etc/profile

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

source $HOME/.bashrc

# load conda env from file
CONDA_ENV=`cat /tmp/rstudio-server/${USER}_current_env`
echo "## CONDA ENV is >>>"
echo ${CONDA_ENV}

conda activate ${CONDA_ENV}

export RETICULATE_PYTHON=$CONDA_PREFIX/bin/python
export TERM=linux

export OPENBLAS_NUM_THREADS=$CORES OMP_NUM_THREADS=$CORES  \
       MKL_NUM_THREADS=$CORES OMP_NUM_cpus=$CORES  \
       MKL_NUM_cpus=$CORES OPENBLAS_NUM_cpus=$CORES \
       MKL_THREADING_LAYER=GNU


/usr/lib/rstudio-server/bin/rsession $@
