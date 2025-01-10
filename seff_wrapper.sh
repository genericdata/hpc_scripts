#!/bin/bash

# Usage: ./seff_wrapper.sh [user]

# Default values
USER=${1:-$(whoami)}
if ! id "$USER" &>/dev/null; then
  echo "User $USER does not exist."
  exit 1
fi

# Function to print job efficiency in a pretty format
#!/bin/bash

print_job_efficiency() {
    local job_id=$1
    local job_name=$2
    local start_time=$3
    local end_time=$4

    # Get job efficiency details from seff
    seff_output=$(seff "$job_id")

    # Extract relevant fields from seff output
    state=$(echo "$seff_output" | grep "State:" | awk '{print $2}')
    ncpus=$(echo "$seff_output" | grep "Cores:" | awk '{print $2}')
    cpu_efficiency=$(echo "$seff_output" | grep "CPU Efficiency:" | awk '{print $3}' | tr -d '%')
    ave_rss=$(echo "$seff_output" | grep "Memory Utilized:" | awk '{print $3 $4}')
    memory_efficiency=$(echo "$seff_output" | grep "Memory Efficiency:" | awk '{print $3}' | tr -d '%')

    # Calculate elapsed time
    elapsed_time=$(sacct -j "$job_id" --format=Elapsed --noheader | awk '{print $1}')

    # Print job efficiency details
    printf "%s,%s,%s,%d,%.2f%%,%s,%.2f%%,%s,%s\n" "$job_id" "$job_name" "$state" "$ncpus" "$cpu_efficiency" "$ave_rss" "$memory_efficiency" "$start_time" "$elapsed_time"
}

# Get job IDs based on the provided arguments
job_ids=$(sacct -X -u $USER --format=JobID,JobName,Start,End --noheader | awk '{print $1, $2, $3, $4}')

# Print table headers
echo "JOBID,JOBNAME,STATE,CORES,CPU EFFICIENCY,MEMORY,MEMORY EFFICIENCY,START TIME,ELAPSED"

# Loop through each job ID and print job efficiency
while read -r job_id job_name start_time end_time; do
  print_job_efficiency $job_id $job_name $start_time $end_time
done <<< "$job_ids" | column -t -s ','

