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

## Documentation

### Functions

1. **fsub**: Creates and submits a PBS job. It generates a PBS script based on provided parameters:
   - `-p`: Path to save the PBS script.
   - `-n`: Name of the job.
   - `-cd`: Directory to change to before running the command.
   - `-nc`: Number of CPUs.
   - `-ng`: Number of GPUs.
   - `-m`: Memory allocation.
   - `-q`: Queue name.
   - `-wt`: Walltime.
   - `-e`: Conda environment.
   - `-c`: Command to run.
   - `-w`: Job IDs to wait for, separated by space, comma, semicolon, or colon.

2. **findjobs**: Searches for PBS jobs based on provided criteria:
   - `-i`: Case-insensitive search.
   - `-q`: Search by queue instead of job name.
   - `--delete`: Delete found jobs using `qdel`.
   - Search string: Job name or queue name to search for.

### Aliases

1. **lseo**: Lists PBS log files (.e and .o files) with 6 digits after them. It uses the `find` command to search for files with names matching the pattern "*.e[0-9]{6}" or "*.o[0-9]{6}".

2. **rmeo**: Removes PBS log files (.e and .o files) with 6 digits after them. It employs `find` with the `-delete` option to remove files matching the pattern "*.e[0-9]{6}" or "*.o[0-9]{6}".

3. **cddb**: Changes the directory to the bioinformatics database directory located at "/projects/bioinformatics/DB/".

4. **pushdb**: Pushes the database directory onto the directory stack using `pushd`, enabling easy navigation back to this directory.

5. **qdelall**: Deletes all jobs belonging to the current user. It selects and deletes all jobs owned by the user using `qselect` and `qdel`.

6. **watchjobs**: Watches job status continuously for the current user. It periodically executes `qstat -fu $USER` to monitor job statuses.

7. **wj**: A shortcut alias for `watchjobs`.

8. **anykilled**: Searches for 'Killed' messages in files in current directory using `grep`. Useful to determine if your jobs were killed due to low memory.

9. **fj**: A shortcut for `findjobs`, simplifying the command for searching PBS jobs.

These aliases and functions provide convenient shortcuts and automation for common tasks in managing PBS jobs and navigating directories in a bioinformatics environment.
