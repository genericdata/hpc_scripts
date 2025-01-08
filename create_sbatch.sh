#!/bin/bash

# Initialize our own variables:
output_file=""
gpu=0

while getopts "h?vg" opt; do
  case "$opt" in
    h|\?)
      echo "Usage: $0 [-g] filename" 
      echo "Create a basic SBATCH template"
      echo "    -g              GPU - add line to request GPUs"
      exit 0
      ;;
    g)  gpu=1
      ;;
  esac
done

shift $((OPTIND-1))
output=${@}.sbatch

echo """#!/bin/bash -e

# SBATCH OPTIONS (https://slurm.schedmd.com/sbatch.html)
#SBATCH --job-name=${1}
#SBATCH --mail-type=END,FAIL     # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --time=00-01:00:00       # Time limit days-hours:minutes:seconds
#SBATCH --output=slurm_%j.log""" > ./$output


if [ "$gpu" == 1 ]; then
  echo "#SBATCH --gres=gpu:1            # Format gpu[[:TYPE]:count]. TYPE is an optional classification for the resource (e.g. a100)">> ./$output
fi

echo """
# #SBATCH --account=users         # Uncomment and change if necessary
""" > ./$output

echo """
module purge
#module load [PACKAGE/VERSION] [PACKAGE/VERSION]
""" >> ./$output
