#!/bin/bash

output=$1

if [ -f ./${output}.sbatch ]; then
    echo "File \"${output}.sbatch\" already exists"
    exit 1
fi

echo """#!/bin/bash -e

# More Information: https://slurm.schedmd.com/sbatch.html
#SBATCH --job-name=${output}
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --output=slurm_${output}_%j.log
#SBATCH --time=00-01:00:00       # Run time (dd-hh:mm:ss)
#SBATCH --mail-type=END,FAIL     # Mail events: NONE, BEGIN, END, FAIL, ALL
# #SBATCH --account=users        # Uncomment and change if necessary

# [GPU]
# #SBATCH --gres=gpu:1
# #SBATCH --constraint=rtx8000|a100

# [Array]
# #SBATCH --array=1-5              # Use \$SLURM_ARRAY_TASK_ID

module purge
#module load [PACKAGE/VERSION] [PACKAGE/VERSION]
""" > ./${output}.sbatch

echo "${output}.sbatch created"

