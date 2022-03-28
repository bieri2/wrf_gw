#!/bin/bash

# Script to process 4 km WRF data
module load cdo
module load nco

# Define in and out dirs
indir=/glade/campaign/univ/uiuc0017/dominguz/wrfout/
outdir=/glade/campaign/univ/uiuc0017/bieri/wrfextracted/no_gw/SMOIS

# Set variable
var=LH

# Set beginning and end dates
d=$(date -d "00:00 2018-06-01")
enddate=$(date -d "00:00 2019-06-01")

cd ${outdir}

# Begin looping through dates
i=1
while [ "$d" != "$enddate" ]; do

	if [ $i != 1 ]; then
		oldd=$d
                d=$(date -d "$d +1 hour") # Increment date

                # Keep track of month
                oldmon=$(date -d "$oldd" "+%m") 
                newmon=$(date -d "$d" "+%m")

	# Check if month has changed
	# If so, merge files and take monthly mean
		if [ "$oldmon" != "$newmon" ]; then
			echo 'do merge'
			outfile=$(date -d "$oldd" "+wrfout_${var}_%Y%m.nc") 
			echo $outfile 
			cdo -O mergetime temp*.nc ${outfile} # Merge hourly timesteps into one file
			cdo -O monmean ${outfile} ${outfile%.nc}_mm.nc # Take mean of all timesteps to get monthly mean
			echo ${outfile%.nc}_mm.nc
			rm  temp*.nc 
                	i=1
		fi
	fi

	# Check if last date has been reached
	if [ "$d" == "$enddate" ]; then
		break
	# If not, continue extracting variable from each wrfout file
	else
        	file=$(date -d "$d" "+${indir}wrfout_d01_%Y-%m-%d_%H:00:00")
        	echo $file
        	cdo -s -O selname,${var} ${file} temp${i}.nc # Extract var and save in temp file
        	((i++)) # Increment i
        	echo $i
	fi

done

