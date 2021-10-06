#!/bin/bash

source /opt/conda/etc/profile.d/conda.sh && \
  conda activate $CONDA_PREFIX && \
  rserver \
    --www-address=127.0.0.1 \
    --www-port=$PORT \
    --rsession-which-r=$RSTUDIO_WHICH_R \
    --rsession-ld-library-path=$CONDA_PREFIX/lib \
    `# optional: old behaviour of R sessions` \
    --auth-timeout-minutes=0 --auth-stay-signed-in-days=30  \
    `# activate password authentication` \
    --auth-none=0  --auth-pam-helper-path=pam-helper \
    --server-user $USER

