#! /bin/bash

set -euo pipefail

input_csv_file=$1
output_dir=$2

ml fastqc

cd $output_dir

while IFS="," read -r col1 col2
do
    mkdir -p $col1
    cd $col1
    fastqc -t 4 $col2
done < $input_csv_file


