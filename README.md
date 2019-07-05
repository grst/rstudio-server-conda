# Howto run Rstudio Server in an Anaconda environment

I usually rely on the [conda package manager]() to manage my environments during development. Thanks to [conda-forge](https://conda-forge.org/) and [bioconda](https://bioconda.github.io/) most R packages are now also available through conda. 

Unfortunately, there seems to be [no straightforward way](https://community.rstudio.com/t/start-rstudio-server-session-in-conda-environment/12516/15) to use conda envs in Rstudio server. This is why I came up with the two scripts in this repo. 

## How it works
* Rstudio server, can be started in non-daemonized mode by each user individually on a custom port (similar to a jupyter notebook). This instance can then run in a conda environment:
```
> conda activate my_project
> /usr/lib/rstudio-server/bin/rserver \
   --server-daemonize=0 \
   --www-port 8787 \
   --rsession-which-r=$(which R) \
   --rsession-ld-library-path=$CONDA_PREFIX/lib
```
* To avoid additional problems with library paths, also `rsession` needs to run within the conda environment. This is achieved by wrapping `rsession` into the [rsession.sh](https://github.com/grst/rstudio-server-conda/blob/master/rsession.sh) script. The path to the wrapped `rsession` executable can be passed to `rserver` as command line argument. 
```
rserver # ...
    --rsession-path=rsession.sh
```


* When using multiple users a unique `secret-cookie-key` has to be regenerated for each user. The path to the secret cookie key can be passed to `rserver` as a command line parameter.
```
uuid > /tmp/rstudio-server/${USER}_secure-cookie-key
rserver # ...
  --secure-cookie-key-file /tmp/rstudio-server/${USER}_secure-cookie-key
```

## Installation and usage
### 1. Prerequisites
* installed [rstudio server](https://www.rstudio.com/products/rstudio/download-server/)
* installed [conda](https://docs.conda.io/en/latest/miniconda.html)
* installed [uuid](https://linux.die.net/man/1/uuid) ("`sudo <PKG_MGR> install uuid")

### 2. Disable rstudio server service. 
You might need to disable the system-wide Rstudio server service.
Due to licensing restrictions of rstudio server community edition, only one rstudio process
can run for each user simultaneously. 

This is how it works on systemd-based systems:

```bash
sudo systemctl disable rstudio-server.service
sudo systemctl stop rstudio-server.service
```

### 3. Clone this repo
```
git clone https://github.com/grst/rstudio-server-conda.git
```

### 4. Run rstudio server in the conda env
```
conda activate my_project
./start_rstudio_server.sh 8787  # use any free port number here. 
```
