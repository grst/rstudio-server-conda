#!/bin/bash

# Settings required for conda+rstudio
export RSTUDIO_WHICH_R=${CONDAENV}/bin/R
export RETICULATE_PYTHON=${CONDAENV}/bin/python
echo rsession-which-r=${RSTUDIO_WHICH_R} > /etc/rstudio/rserver.conf
echo rsession-ld-library-path=${CONDAENV}/lib >> /etc/rstudio/rserver.conf
echo "R_LIBS_USER=${CONDAENV}/lib/R/library" > /home/rstudio/.Renviron
# Set root password (with podman, we need to login as root rather than "rstudio")
echo "root:$PASSWORD" | chpasswd
echo "auth-minimum-user-id=0" >> /etc/rstudio/rserver.conf

# Custom settings
echo "session-timeout-minutes=0" > /etc/rstudio/rsession.conf
echo "auth-timeout-minutes=0" >> /etc/rstudio/rserver.conf
echo "auth-stay-signed-in-days=30" >> /etc/rstudio/rserver.conf

# Run original rocker launcher script
/init
