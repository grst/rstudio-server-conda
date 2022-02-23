#!/bin/bash

echo "HERE I AM 1"

  rserver \
    --server-user=jared \
    --www-address=10.16.105.100 \
    --www-port=$PORT \
    --rsession-which-r=$RSTUDIO_WHICH_R \
    --rsession-ld-library-path=$CONDA_PREFIX/lib \
    # optional: old behaviour of R session
    --auth-timeout-minutes=0 --auth-stay-signed-in-days=30  \
    # activate password authentication
    --auth-none=0  --auth-pam-helper-path=pam-helper \
  
