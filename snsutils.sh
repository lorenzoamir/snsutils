
# List pbs log files .e and .o files with 6 digits after them
<<<<<<< HEAD
alias lseo="find . -maxdepth 1 -type f -regextype posix-extended -regex '.*\.[eo][0-9]{6}$'"
=======
alias lseo="find . -type f -regextype posix-extended -regex '.*\.[eo][0-9]{6}$'"
>>>>>>> 9824b087fcf8e42607eaa12cd351c3a188804325

# Remove pbs log files .e and .o files with 6 digits after them
alias rmeo="find . -maxdepth 1 -type f -regextype posix-extended -regex '.*\.[eo][0-9]{6}$' -delete"

# Change directory to bioinformatics database directory
alias cddb="cd /projects/bioinformatics/DB/"

# Push database directory
alias pushdb="pushd /projects/bioinformatics/DB/"

# Delete all jobs belonging to the current user
alias qdelall="qselect -u $USER | xargs qdel"

# Watch job status continuously for the current user
alias watchjobs="watch -n 1 qstat -fu $USER"
alias wj="watch -n 1 qstat -fu $USER"  # Shortcut alias

# Search for 'Killed' messages in files
<<<<<<< HEAD
alias anykilled="grep -l 'Killed' ./*"
=======
alias anykilled="grep -rl 'Killed' ./*"
>>>>>>> 9824b087fcf8e42607eaa12cd351c3a188804325

# Function to create and submit a PBS job
fsub() {
    local script_path="./pbs_job.sh"  # Path to save the PBS script
    local job_name="pbs_job"     # Default name of the job
    local cddir="."     # cd to this directory before running the command
    local num_cpus="1"     # Default number of CPUs
    local num_gpus="0"     # Default number of GPUs
    local memory="1gb"       # Default memory allocation
    local queue="q02anacreon"        # Default queue name
    local walltime=""     # Default walltime
    local environment="base"     # Default conda environment
    local command="echo \"No command was provided!\""      # Command to run
    local waitinglist=""     # Job IDs to wait for, accepted sepataors: space, comma, semicolon, colon

    # Parse command line options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -p) script_path="$2"; shift 2;;
            -n) job_name="$2"; shift 2;;
            -cd) cddir="$2"; shift 2;;
            -nc) num_cpus="$2"; shift 2;;
            -ng) num_gpus="$2"; shift 2;;
            -m) memory="$2"; shift 2;;
            -q) queue="$2"; shift 2;;
            -wt) walltime="$2"; shift 2;;
            -e) environment="$2"; shift 2;;
            -c) command="$2"; shift 2;;
            -w) waitinglist="$2"; shift 2;;
            -h|--help) echo "Usage: fastsub [-p script_path] [-n job_name] [-cd cddir] [-nc num_cpus] [-ng num_gpus] [-m memory] [-q queue] [-wt walltime] [-e environment] [-c command] [-w waitinglist]"; return 0;;
            *) echo "Unknown option: $1"; return 1;;
        esac
    done

    # If both job_name and script_path are default, try to infer them from the command
    if [[ "$job_name" == "pbs_job" && "$script_path" == "./pbs_job.sh" ]]; then 
        # check if command is python or R script
        if [[ "$command" == *"python"* ]]; then
            # find word ending with .py and replace .py with .sh
            script_path=$(echo "$command" | grep -o '\w*\.py' | sed 's/\.py/.sh/')
            job_name=$(basename "$script_path")
            job_name="${job_name%.*}"
        elif [[ "$command" == *"Rscript"* ]]; then
            # find word ending with .R and replace .R with .sh
            script_path=$(echo "$command" | grep -o '\w*\.R' | sed 's/\.R/.sh/')
            job_name=$(basename "$script_path")
            job_name="${job_name%.*}"
        else
            echo "Error: Both job_name and script_path are empty!"
            return 1
        fi
    fi


    # If job_path does not end with .sh, append .sh to it
    if [[ ! "$script_path" == *.sh ]]; then
        script_path="$script_path.sh"
    fi

    # If job_name is default, but script_path is not, use the script name as job_name
    if [[ "$job_name" == "pbs_job" && "$script_path" != "./pbs_job.sh" ]]; then
        job_name=$(basename "$script_path")
        job_name="${job_name%.*}"
    fi

    # If ngpus in not 0 and queue is default, change queue to q02gaia
    if [[ "$num_gpus" -gt 0 && "$queue" == "q02anacreon" ]]; then
        queue="q02gaia"
    fi

    # get absolute path of cddir
    cddir=$(realpath "$cddir")

    # Create the PBS script
    touch "$script_path"
    echo "#!/bin/bash" > "$script_path"
    echo "#PBS -N $job_name" >> "$script_path"
    echo "#PBS -l select=1:ncpus=$num_cpus:ngpus=$num_gpus:mem=$memory" >> "$script_path"
    echo "#PBS -q $queue" >> "$script_path"
    if [[ -n "$walltime" ]]; then
        echo "#PBS -l walltime=$walltime" >> "$script_path"
    fi

    # Change directory to cddir, create it if it does not exist
    echo "mkdir -p $cddir" >> "$script_path"
    echo "cd $cddir" >> "$script_path"

    # Activate conda environment
    echo 'eval "$(/cluster/shared/software/miniconda3/bin/conda shell.bash hook)"' >> "$script_path"
    echo "conda activate $environment" >> "$script_path"

    # Add command to script
    echo "$command" >> "$script_path"

    echo "exit 0" >> "$script_path"
    
    # If waiting list is not a set of strings separated by colons,
    # then substitute all spaces, commas, and semicolons with colons 
    # and substitute all multiple colons with a single colon
    if [[ -n "$waitinglist" ]]; then
        waitinglist=$(echo "$waitinglist" | tr ' ,;' ':')
        waitinglist=$(echo "$waitinglist" | tr -s ':')
        waitinglist=$(echo "$waitinglist" | sed 's/^:\(.*\)$/\1/')
        echo "Waiting list: $waitinglist"
    fi

    # Submit the job
    if [[ -n "$waitinglist" ]]; then
        job_id=$(qsub -W depend=afterok:"$waitinglist" "$script_path")
    else
        job_id=$(qsub "$script_path")
    fi

    echo $job_id
}

findjobs() {
    local search_string=""
    local case_insensitive=false
    local search_queue=false
    local delete=false

    # Parse options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -i)
                case_insensitive=true
                shift
                ;;
            -q)
                search_queue=true
                shift
                ;;
            --delete)
                delete=true
                shift
                ;;
            *)
                search_string="$1"
                shift
                ;;
        esac
    done

    # Extract job IDs based on the search string in job names or queue
    if [ -z "$search_string" ]; then
        # If no search string provided, return all jobs
        if [ "$search_queue" = true ]; then
            local job_ids=$(qstat -u $USER | awk 'NR>5 {print $1}')
        else
            local job_ids=$(qstat -u $USER | awk 'NR>5 {print $1}')
        fi
    else
        # Search for job IDs based on the provided search string
        if [ "$case_insensitive" = true ]; then
            if [ "$search_queue" = true ]; then
                local job_ids=$(qstat -u $USER | awk -v search="$(echo "$search_string" | tr '[:upper:]' '[:lower:]')" 'NR>5 && tolower($3) ~ search {print $1}')
            else
                local job_ids=$(qstat -u $USER | awk -v search="$(echo "$search_string" | tr '[:upper:]' '[:lower:]')" 'NR>5 && tolower($4) ~ search {print $1}')
            fi
        else
            if [ "$search_queue" = true ]; then
                local job_ids=$(qstat -u $USER | awk -v search="$search_string" 'NR>5 && $3 ~ search {print $1}')
            else
                local job_ids=$(qstat -u $USER | awk -v search="$search_string" 'NR>5 && $4 ~ search {print $1}')
            fi
        fi
    fi
    
    # Check if any jobs found
    if [ -z "$job_ids" ]; then
        return 1
    fi

    # Delete the jobs if --delete option is provided
    if [ "$delete" = true ]; then
        echo "Deleting jobs with the search string '$search_string':"
        echo "$job_ids" | xargs qdel
    else
        echo "$job_ids"
    fi
}


# Alias for findjobs
alias fj="findjobs"
