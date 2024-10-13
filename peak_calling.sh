#!/bin/bash

set -euo pipefail

ml macs/2.1.0
ml openssl

input_csv=$1

#col1 directory of files col2-bam col3-input bam col4-name for peaks file
while IFS="," read -r col1 col2 col3 col4 
do
    cd $col1
    mkdir -p ./peak_calling
    macs2 callpeak -t $col2 -c $col3 -g hs -n $col4 -f BAMPE -B --keep-dup "all" --nomodel --extsize 100 --shift 50
    mv "${col4}"* ./peak_calling/
    cd
done <$input_csv