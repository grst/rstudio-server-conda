#!/bin/bash

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

conda deactivate
conda deactivate
conda deactivate
conda activate ${CONDA_ENV}

export RETICULATE_PYTHON=$CONDA_PREFIX/bin/python
export TERM=linux

source set_blas_cores 1

/usr/lib/rstudio-server/bin/rsession $@
