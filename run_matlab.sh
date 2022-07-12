#!/bin/bash
#PBS -q normal
#PBS -l walltime=10:00:00
#PBS -l ncpus=1
#PBS -l mem=64GB
#PBS -l jobfs=32GB
#PBS -l software=matlab_melbourne
#PBS -l wd
#PBS -l storage=gdata/w40

#replace w40 with your own project
#replace matlab_melbourne with your own licence

module load matlab/R2019b
module load matlab_licence/melbourne
matlab -nodisplay -nosplash -singleCompThread < path_to_file/IVT_AR_identification.m > $PBS_JOBID.log

