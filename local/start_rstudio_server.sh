#!/bin/bash

##############################################
# USAGE: ./start_rstudio_server <PORT>
#   e.g. ./start_rstudio_server 8787
##############################################

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
USER=$(whoami)
# set a user-specific secure cookie key
COOKIE_KEY_PATH=/tmp/rstudio-server/${USER}_secure-cookie-key
rm -f $COOKIE_KEY_PATH
mkdir -p $(dirname $COOKIE_KEY_PATH)

# Rserver >= version 1.3 requires the --auth-revocation-list-dir parameter
if [ $(sed -n '/^1.3./p;q' /usr/lib/rstudio-server/VERSION) ] ;
then
  REVOCATION_LIST_DIR=/tmp/rstudio-server/${USER}_revocation-list-dir
  mkdir -p $REVOCATION_LIST_DIR
  REVOCATION_LIST_PAR="--auth-revocation-list-dir=$REVOCATION_LIST_DIR"
else
  REVOCATION_LIST_PAR=""
fi

python -c 'import uuid; print(uuid.uuid4())' > $COOKIE_KEY_PATH
chmod 600 $COOKIE_KEY_PATH

# store the currently activated conda environment in a file to be read by rsession.sh
CONDA_ENV_PATH=/tmp/rstudio-server/${USER}_current_env
rm -f $CONDA_ENV_PATH
echo "## Current env is >>"
echo $CONDA_PREFIX
echo $CONDA_PREFIX > $CONDA_ENV_PATH

export RETICULATE_PYTHON=$CONDA_PREFIX/bin/python

# store the current path in database config
sed -i "s,directory=.*,directory=\/tmp\/rstudio-server\/${USER}_database," $CWD/database.conf

/usr/lib/rstudio-server/bin/rserver --server-daemonize=0 \
  --www-port=$1 \
  --secure-cookie-key-file=$COOKIE_KEY_PATH \
  --server-pid-file="$CWD/rstudio-server.pid" \
  --server-data-dir="$CWD/rstudio-server" \
  --rsession-which-r=$(which R) \
  --rsession-ld-library-path=$CONDA_PREFIX/lib \
  --rsession-path="$CWD/rsession.sh" \
  --server-user $USER \
  --database-config-file "$CWD/database.conf" \
  $REVOCATION_LIST_PAR


