#!/bin/bash
#PBS -N pbs_job
#PBS -l select=1:ncpus=1:ngpus=0:mem=1gb
#PBS -q q02anacreon
mkdir -p /projects/bioinformatics/snsutils
cd /projects/bioinformatics/snsutils
eval "$(/cluster/shared/software/miniconda3/bin/conda shell.bash hook)"
conda activate base
echo 'prova'
exit 0
