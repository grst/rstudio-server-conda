# Rstudio server conda (podman version)

## Usage:

 * copy the docker-compose.yml file into your project directory
 * update the conda env paths and port in docker-compose.yml
 * `podman-compose up`

## Note:
 * when using docker, login with the `rstudio` user as described on the "rocker"
   page. 
 * when using podman, login with the `root` user, as root within the container
   corresponds to your user outside the container. 
