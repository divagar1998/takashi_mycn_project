#!/bin/bash

set -euo pipefail

input_csv=$1
# file path of the reference genome
REF="/hpc/users/divagt01/watanabe/ref/grch38_1kgmaj"
# file path of the blacklisted genes
REF_blacklist="/hpc/users/divagt01/watanabe/ref/JDB_blacklist_plus_chrM.hg38.bed"

ml bowtie2
ml openssl
ml samtools
ml bedtools
ml java
ml picard

#col1-atac mate 1 col2-atac mate 2 col3-input mate 1 col4-input mate 2 col5-atac output path col6-input output path
while IFS="," read -r col1 col2 col3 col4 col5 col6
do
    if [[ -f "${col5}.sam" ]]; then
        echo "${col5}.sam exists"
    else
        #create sam alignment file
        bowtie2 -p 30 -x $REF -1 $col1 -2 $col2  -S "${col5}.sam"
        bowtie2 -p 30 -x $REF -1 $col3 -2 $col4  -S "${col6}.sam"
    fi

    # convert sam to bam
	# only take reads that have quality score above 30
	samtools view -q 31 -b "${col5}.sam" | samtools sort -@ 30 -T "temp.bam" -o "${col5}.sorted.bam"
    samtools view -q 31 -b "${col6}.sam" | samtools sort -@ 30 -T "temp_input.bam" -o "${col6}.sorted.bam"
	# index bam file
	samtools index "${col5}.sorted.bam"
    samtools index "${col6}.sorted.bam"

    # remove blacklisted regions
    bedtools intersect -abam "${col5}.sorted.bam" -b $REF_blacklist -v | samtools sort -@ 30 -o "${col5}.woblacklist.sorted.bam" 
    bedtools intersect -abam "${col6}.sorted.bam" -b $REF_blacklist -v | samtools sort -@ 30 -o "${col6}.woblacklist.sorted.bam" 

    # move the sam file to archives
    mv "${col5}.sam" /sc/arion/scratch/divagt01
    mv "${col6}.sam" /sc/arion/scratch/divagt01

    #remove duplicate reads
    sorted_bam_file_names=([1]=${col5} [2]=${col6})

    for i in "${sorted_bam_file_names[@]}"
        do 
            java \
            -jar $PICARD \
            MarkDuplicates \
            INPUT="${i}.woblacklist.sorted.bam" \
            OUTPUT="${i}.woblacklist.sorted.rmdup.bam" \
            METRICS_FILE="${i}.woblacklist.sorted.bam.rmdup.txt" \
            REMOVE_DUPLICATES=true 
        done
done < $input_csv

