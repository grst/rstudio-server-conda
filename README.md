# Running Rstudio Server in a Conda Environment

I usually rely on the [conda package manager](https://docs.conda.io/en/latest/) to manage my environments during development. Thanks to [conda-forge](https://conda-forge.org/) and [bioconda](https://bioconda.github.io/) most R packages are now also available through conda. For production,
I [convert them to containers](https://github.com/grst/containerize-conda) as these are easier to share. 

Unfortunately, there seems to be [no straightforward way](https://community.rstudio.com/t/start-rstudio-server-session-in-conda-environment/12516/15) to use conda envs in Rstudio server. This repository provides two approaches to make rstudio server work with conda envs. 

 * [Running Rstudio Server in a Singularity Container](#running-rstudio-server-in-singularity)
 * [Running Rstudio Server in a Docker/Podman Container](#running-rstudio-server-in-a-container)
 * [Running Rstudio Server locally](#running-locally)

## Running Rstudio Server in Singularity

### Prerequisites

 * [Singularity]
 * [conda]

### Usage

 1. Activate the target conda env or set the environment variable `CONDA_PREFIX`
    to point to the location of the conda env. 
 2. 

## Running Rstudio Server in a Container

With this approach Rstudio Server runs in a Docker container (based on [rocker/rstudio](https://hub.docker.com/r/rocker/rstudio)).  
The conda environment gets mounted into the container - like that there's no need to rebuild the container to add a package and 
`install.packages` can be used without issues. The container-based approach has the following benefits: 

 * Authentication works (#3)
 * Several separate instances of Rstudio server can run in parallel, even without the *Pro* version. 

### Prerequisites

 * [Docker](https://www.docker.com/) or [Podman](https://podman.io/)
 * [docker-compose](https://github.com/docker/compose) or [podman-compose](https://github.com/containers/podman-compose)
 * [conda](https://docs.conda.io/en/latest/miniconda.html) or [mamba](https://github.com/conda-forge/miniforge#mambaforge)

### Usage

1. Clone this repository

   ```bash
   git clone git@github.com:grst/rstudio-server-conda.git
   ```

2. Build the rstudio container (fetches the latest version of [rocker/rstudio](https://hub.docker.com/r/rocker/rstudio) and adds some custom scripts)

   ```bash
   cd rstudio-server-conda/docker
   docker-compose build     # or podman-compose
   ```

3. Copy the docker-compose.yml file into your project directory and adjust the paths.

   You may want to add additional volumes with your data. 

   ```yml
   [...]
      ports:
         # port on the host : port in the container (the latter is always 8787)
         - "8889:8787"
       volumes:
         # mount conda env into exactely the same path as on the host system - some paths are hardcoded in the env.
         - /home/sturm/anaconda3/envs/R400:/home/sturm/anaconda3/envs/R400
         # Share settings between rstudio instances
         - /home/sturm/.local/share/rstudio/monitored/user-settings:/root/.local/share/rstudio/monitored/user-settings
         # mount the working directory containing your R project.
         - /home/sturm/projects:/projects
       environment:
         # password used for authentication
         - PASSWORD=notsafe
         # repeat the path of the conda environment (must be identical to the path in "volumes")
         - CONDAENV=/home/sturm/anaconda3/envs/R400
   ```

4. Run your project-specific instance of Rstudio-server

   ```bash
   docker-compose up 
   ```

5. Log into Rstudio

 * Open your server at `https://localhost:8889` (or whatever port you specified)
 * Login with the user `rstudio` (when using Docker) or `root` (when using Podman) and the password you specified 
   in the `docker-compose.yml`. If you are using Podman and login with `rstudio` you won't have permissions to 
   access the mounted volumes. 


## Running Locally

With this approach a locally installed Rstudio server is ran such that it uses the conda env. 
A known limitation of this approch is that the Rstudio authentication is bypassed (see #3). 
Therefore, only use this approach in a secure network! 

### Prerequisites
* [rstudio server](https://www.rstudio.com/products/rstudio/download-server/) installed locally
* [conda](https://docs.conda.io/en/latest/miniconda.html) or [mamba](https://github.com/conda-forge/miniforge#mambaforge)

### Usage

1. Clone this repo

   ```
   git clone https://github.com/grst/rstudio-server-conda.git
   ```

2. Run rstudio server in the conda env

   ```
   cd rstudio-server-conda/local
   conda activate my_project
   ./start_rstudio_server.sh 8787  # use any free port number here. 
   ```
   
3. Connect to Rstudio

   You should now be able to connect to rstudio server on the port you specify. 
   **If an R Session has previously been running, you'll need to rstart the Rsession now**. 

   Obviously, if your env does not have a version of `R` installed, this will either not 
   work at all, or fall back to the system-wide R installation. 


### How it works
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


* When using multiple users a unique `secret-cookie-key` has to be generated for each user. The path to the secret cookie key can be passed to `rserver` as a command line parameter.

   ```
   uuid > /tmp/rstudio-server/${USER}_secure-cookie-key
   rserver # ...
     --secure-cookie-key-file /tmp/rstudio-server/${USER}_secure-cookie-key
   ```

