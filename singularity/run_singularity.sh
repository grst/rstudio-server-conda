#!/bin/bash

# See also https://www.rocker-project.org/use/singularity/

R_BIN=$CONDA_PREFIX/bin/R
PY_BIN=$CONDA_PREFIX/bin/python
PORT=${PORT:-8787}
CONTAINER="rstudio_latest.sif"

mkdir -p run var-lib-rstudio-server
printf 'provider=sqlite\ndirectory=/var/lib/rstudio-server\n' > database.conf
touch rsession.conf

if [ ! -f $CONTAINER ]; then 
	singularity pull $CONTAINER docker://rocker/rstudio:latest
fi

singularity exec \
	--bind run:/run \
	--bind var-lib-rstudio-server:/var/lib/rstudio-server \
	--bind database.conf:/etc/rstudio/database.conf \
	--bind rsession.conf:/etc/rstudio/rsession.conf \
	--bind $HOME/.local/share/rstudio:/home/rstudio/.local/share/rstudio \
	--bind ${CONDA_PREFIX}:${CONDA_PREFIX} \
	--bind $HOME/.config/rstudio:/home/rstudio/.config/rstudio \
	--env RSTUDIO_WHICH_R=$R_BIN \
	--env RETICULATE_PYTHON=$PY_BIN \
	--env PASSWORD=notsafe \
	rstudio_latest.sif \
	rserver \
		--www-address=127.0.0.1 \
		--www-port=$PORT \
		--rsession-which-r=$R_BIN \
		--rsession-ld-library-path=$CONDA_PREFIX/lib \
		--auth-timeout-minutes=0 \
		--auth-stay-signed-in-days=30  \
		--auth-none=0  --auth-pam-helper-path=pam-helper
