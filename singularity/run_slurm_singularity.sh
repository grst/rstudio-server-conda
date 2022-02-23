#!/bin/bash

#SBATCH --account=jared
#SBATCH --job-name=runRserver
#SBATCH --time=14-0:00
#SBATCH --nodes=1
#SBATCH --mem=200gb
#SBATCH --mail-type=end
#SBATCH --mail-user=jslosbe1@jhu.edu

./run_singularity.sh
