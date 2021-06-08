#!/bin/bash

# See also https://www.rocker-project.org/use/singularity/

# Main parameters for the script with default values
PORT=${PORT:-8787}
PASSWORD=${PASSWORD:-notsafe}
CONTAINER="rstudio_latest.sif"  # path to singularity container (will be automatically downloaded)

# Set-up temporary paths
HASH="$(echo -n $CONDA_PREFIX | md5sum | awk '{print $1}')"
mkdir -p tmp/$HASH/run tmp/$HASH/var-lib-rstudio-server tmp/$HASH/local-share-rstudio
printf 'provider=sqlite\ndirectory=/var/lib/rstudio-server\n' > database.conf
touch rsession.conf

R_BIN=$CONDA_PREFIX/bin/R
PY_BIN=$CONDA_PREFIX/bin/python

if [ ! -f $CONTAINER ]; then
	singularity pull $CONTAINER docker://rocker/rstudio:latest
fi

if [ -z "$CONDA_PREFIX" ]; then
  echo "Activate a conda env or specify \$CONDA_PREFIX"
  exit 1
fi

echo "Starting container..."
singularity exec \
	--bind tmp/$HASH/run:/run \
	--bind tmp/$HASH/var-lib-rstudio-server:/var/lib/rstudio-server \
	--bind database.conf:/etc/rstudio/database.conf \
	--bind rsession.conf:/etc/rstudio/rsession.conf \
  --bind tmp/$HASH/local-share-rstudio:/home/rstudio/.local/share/rstudio \
	--bind ${CONDA_PREFIX}:${CONDA_PREFIX} \
	--bind $HOME/.config/rstudio:/home/rstudio/.config/rstudio \
  `# add additional bind mount required for your use-case` \
  --bind /data:/data \
	--env RSTUDIO_WHICH_R=$R_BIN \
	--env RETICULATE_PYTHON=$PY_BIN \
	--env PASSWORD=$PASSWORD \
	rstudio_latest.sif \
	rserver \
		--www-address=127.0.0.1 \
		--www-port=$PORT \
		--rsession-which-r=$R_BIN \
		--rsession-ld-library-path=$CONDA_PREFIX/lib \
    `# optional: old behaviour of R sessions` \
		--auth-timeout-minutes=0 --auth-stay-signed-in-days=30  \
    `# activate password authentication` \
		--auth-none=0  --auth-pam-helper-path=pam-helper
