#!/bin/bash

# See also https://www.rocker-project.org/use/singularity/
source ./yaml_parser.sh


# Main parameters for the script with default values
PORT=${PORT:-8888}
USER=$(whoami)
PASSWORD=${PASSWORD:-notsafe}
TMPDIR=${TMPDIR:-tmp}

#custom parameters, like container and project specific bind paths
eval $(parse_yaml $YAML_FILE)

# Set-up temporary paths
RSTUDIO_TMP="${TMPDIR}/$(echo -n $CONDA_PREFIX | md5sum | awk '{print $1}')"
mkdir -p $RSTUDIO_TMP/{run,var-lib-rstudio-server,local-share-rstudio}

R_BIN=/opt/R/4.1.2/bin/R
PY_BIN=$CONDA_PREFIX/bin/python

if [ ! -f $CONTAINER ]; then
	singularity build --fakeroot $CONTAINER Singularity
fi

if [ -z "$CONDA_PREFIX" ]; then
  echo "Activate a conda env or specify \$CONDA_PREFIX"
  exit 1
fi

echo "Starting rstudio service on port $PORT ..."
echo "Home is $HOME"
echo "Conda prefix is $CONDA_PREFIX"
echo "R bin is $R_BIN"
echo "Container is $CONTAINER"
echo "YAML parameters are $YAML_FILE"

singularity exec \
	`#TODO: are any of these not important` \
	--bind $RSTUDIO_TMP/run:/run \
	--bind $RSTUDIO_TMP/var-lib-rstudio-server:/var/lib/rstudio-server \
	--bind /sys/fs/cgroup/:/sys/fs/cgroup/:ro \
	--bind database.conf:/etc/rstudio/database.conf \
	--bind rsession.conf:/etc/rstudio/rsession.conf \
	--bind $RSTUDIO_TMP/local-share-rstudio:/home/rstudio/.local/share/rstudio \
	--bind ${CONDA_PREFIX}:${CONDA_PREFIX} \
	--bind /home/${USER}/rstudio-server-conda/singularity:/home/${USER}/rstudio-server-conda/singularity \
	--bind $HOME/.config/rstudio:/home/rstudio/.config/rstudio \
	--bind /mnt/morbo/Data/Public/parigi_spatial_intestine/:/mnt/morbo/Data/Public/parigi_spatial_intestine/ \
	        `# add additional bind mount required for your use-case` \
	--bind /opt:/opt \
	--bind /data/users/${USER}:/data/users/${USER} \
	--env CONDA_PREFIX=$CONDA_PREFIX \
	--env RSTUDIO_WHICH_R=$R_BIN \
	--env RETICULATE_PYTHON=$PY_BIN \
	--env PASSWORD=$PASSWORD \
	--env TZ=EST \
	--env PORT=$PORT \
	--env USER=$USER \
	$CONTAINER \
	./init.sh


