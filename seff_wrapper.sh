#!/bin/bash

# Usage: ./seff_wrapper.sh [user]

# Default values
USER=${1:-$(whoami)}
#TODO: Verify user is a valid user. Otherwise, exit 1

# Function to print job efficiency in a pretty format
print_job_efficiency() {
  local job_id=$1
  local job_name=$2
  local start_time=$3
  local end_time=$4
  local efficiency=$(seff $job_id | grep -E 'Job ID|Job Name|State|Cores|CPU Utilized|CPU Efficiency|Memory Utilized|Memory Efficiency')

  echo "Job ID: $job_id"
  echo "Job Name: $job_name"
  echo "Start Time: $start_time"
  echo "End Time: $end_time"
  echo "$efficiency"
  echo "----------------------------------------"
}

# Get job IDs based on the provided arguments
job_ids=$(sacct -X -u $USER --format=JobID,JobName,Start,End --noheader | awk '{print $1, $2, $3, $4}')

# Print table headers
echo "JOBID,JOBNAME,STATE,CORES,CPU EFFICIENCY,MEMORY, MEMORY EFFICIENCY, START TIME, ELAPSED"

# Loop through each job ID and print job efficiency
while read -r job_id job_name start_time end_time; do
  print_job_efficiency $job_id $job_name $start_time $end_time
done <<< "$job_ids" 
#TODO: the output should go through `columns` to print pretty.
