# snsutils
Aliases and function to make your life easier on the sns cluster

## Installation
To use it in interactive shells just add this line to your `.bashrc`
```{bash}
source "/projects/bioinformatics/snsutils/snsutils.sh"
```
for example by running
```{bash}
echo 'source "/projects/bioinformatics/snsutils/snsutils.sh"' >> ~/.bashrc
```
in case you want to use it in scripts you will probably have to source the file it in the script too.

## Functions

### fsub
**fsub** creates a PBS script and submits it in one single command:
   - `-p`: Path to save the PBS script.
   - `-n`: Name of the job.
   - `-cd`: Directory from which to run the command.
   - `-nc`: Number of CPUs.
   - `-ng`: Number of GPUs.
   - `-m`: Memory allocation.
   - `-q`: Queue name.
   - `-wt`: Walltime.
   - `-e`: Conda environment.
   - `-c`: Command to run.
   - `-w`: Job IDs to wait for, separated by space, comma, semicolon, or colon.

**Example usage:**

This two bits of code are roughly equivalent:
```{bash}
# Example 1: create job script and submit it automatically with fsub

wgcna_id=$(fsub \
   -p "$wgcna_script" \
   -n "$wgcna_name" \
   -nc "$WGCNA_NCPUS" \
   -m "$WGCNA_MEMORY" \
   -q "$WGCNA_QUEUE" \
   -e "WGCNA" \
   -w "$waiting_list" \
   -c "python wgcna.py --input ${file}")

# Example 2: manually create and submit job script

touch "$wgcna_script"

echo "#!/bin/bash" > "$wgcna_script"
echo "#PBS -l select=1:ncpus=$WGCNA_NCPUS:mem=$WGCNA_MEMORY" >> "$wgcna_script"
echo "#PBS -q $WGCNA_QUEUE" >> "$wgcna_script"
echo "#PBS -N $wgcna_name" >> "$wgcna_script"
echo "" >> "$wgcna_script"
echo 'eval "$(/cluster/shared/software/miniconda3/bin/conda shell.bash hook)"' >> "$wgcna_script"
echo "conda activate WGCNA" >> "$wgcna_script"
echo "python ~/pathway_crosstalk/code/0_WGCNA_CCC/wgcna.py --input "${file}"" >> "${wgcna_script}"
echo "exit 0" >> "$wgcna_script"

if [ -n "$waiting_list" ]; then
    wgcna_id=$(qsub -W depend=afterok$waiting_list "$wgcna_script")
else
    wgcna_id=$(qsub "$wgcna_script")
fi
```
You can easily run a python script specifying the conda environment, number of cpus and memory like this:
```
fsub -nc 2 -m 4gb -e "my_env" -c "python script.py"
```
it will default to the `q02anacreon` queue.

### findjobs

**findjobs** searches for PBS jobs of the current user based on name or queue and optionally deletes them:
   - `-i`: Case-insensitive search.
   - `-q`: Search by queue instead of job name.
   - `--delete`: Delete found jobs using `qdel`.
   - Search string: Job name or queue name to search for.

**Example usage**:

List all jobs with "wgcna" in their name (case-insensitive) on all queues
```
findjobs -i wgcna
```
List jobs running on any of the `ancreon` queues
```
findjobs -q anacreon
```
Delete all jobs on queue `q02gaia`
```
findjobs -q q02gaia --delete
```

## Aliases

1. **lseo**: Lists PBS log files ending in .e and .o files followed by 6 digits.
2. **rmeo**: Removes PBS log files ending in .e and .o files followed by 6 digits.
3. **cddb**: Changes the directory to the bioinformatics database directory located at "/projects/bioinformatics/DB/".
4. **pushdb**: Pushes the database directory onto the directory stack using `pushd`, enabling easy navigation back to this directory.
5. **qdelall**: Deletes all jobs belonging to the current user.
7. **watchjobs**: Watches job status continuously for the current user.
8. **wj**: A shortcut alias for `watchjobs`.
9. **anykilled**: Searches for 'Killed' messages in files in current directory using `grep`. Useful to determine if your jobs were killed due to low memory.
10. **fj**: A shortcut alias for `findjobs`.
