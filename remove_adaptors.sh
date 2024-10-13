#!/bin/bash

set -euo pipefail

ml cutadapt
ml fastqc

input_csv=$1

#col1-input mate 1 col2-input mate 2 col3-output mate 1 col4-output mate 2 col5-fwd adapter col6-rev adapter
# Read each line from the input file
while IFS="," read -r col1 col2 col3 col4 col5 col6; do
    echo "Processing: $col1, $col2"
    
    # Run cutadapt to trim adapters
    cutadapt -a "${col5}" -A "${col6}" -o "${col3}" -p "${col4}" "${col1}" "${col2}" --minimum-length=25 --cores=30
    
    # Run FastQC on the trimmed output
    fastqc -t 10 "${col3}"
    fastqc -t 10 "${col4}"
done < "$input_csv"



