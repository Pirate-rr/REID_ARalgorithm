#!/bin/bash
#PBS -q hugemem
#PBS -l walltime=24:00:00
#PBS -l ncpus=1
#PBS -l mem=64GB
#PBS -l jobfs=32GB
#PBS -l wd
#PBS -l storage=gdata/rt52+gdata/w40

#ERA5 used as example. Need to run it on hugemem for ERA5 but can use normal queue for smaller datasets
#Change "w40" to your own project
module load cdo

for year in {1980..2019} # select the years and months you want
do

        for month in "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12"
        do
               cdo sellonlatbox,<lon_start>,<lon_end>,<lat_start>,<lat_end> -seltimestep,<time_index_start>/<time_index_end>/<time_increment> /g/data/rt52/era5/single-levels/reanalysis/viwve/$year/viwve_era5_oper_sfc_${year}${month}*.nc ivte${year}${month}.nc
       done
done
#Delete these files once you have finished identifying ARs
#yes, I'm aware there is probably a more efficient way of doing it. You can fix it if you want, but I probably  won't
