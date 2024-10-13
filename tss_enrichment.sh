#!/bin/bash

ml python

# Set variables
ANNOTATION_GTF="gencode.v38.annotation.gtf.gz"          # Path to your GTF file
ATACSEQ_BAM="/hpc/users/divagt01/watanabe/Divagar/takashi_mycn_project_files/H2106/H2106_ATAC.woblacklist.sorted.rmdup.shifted.bam"                 # Path to your ATAC-seq BAM file
TSS_BED="tss_regions.bed"                      # Output file for TSS regions
COVERAGE_BW="/hpc/users/divagt01/watanabe/Divagar/takashi_mycn_project_files/H2106/H2106_ATAC_coverage.bw"        # Output file for coverage
MATRIX_OUTPUT="/hpc/users/divagt01/watanabe/Divagar/takashi_mycn_project_files/H2106/H2106_ATAC_matrix_TSS.gz"                  # Output matrix file
PROFILE_OUTPUT="/hpc/users/divagt01/watanabe/Divagar/takashi_mycn_project_files/H2106/TSS_enrichment_profile.pdf"    # Output profile plot
HEATMAP_OUTPUT="/hpc/users/divagt01/watanabe/Divagar/takashi_mycn_project_files/H2106/TSS_enrichment_heatmap.pdf"    # Output heatmap

# Step 1: Create TSS BED file from GTF
echo "Generating TSS regions from GTF..."
awk '$3 == "gene" {print $1"\t"$4-1000"\t"$4+200"\t"$9}' "$ANNOTATION_GTF" > "$TSS_BED"

# Step 2: Generate coverage from ATAC-seq BAM file
echo "Generating coverage from BAM file..."
bamCoverage -b "$ATACSEQ_BAM" -o "$COVERAGE_BW" --binSize 10 --normalizeUsing RPKM

# Step 3: Compute matrix for TSS regions
echo "Computing matrix for TSS enrichment..."
computeMatrix reference-point \
-S "$COVERAGE_BW" \
-R "$TSS_BED" \
--referencePoint TSS \
-a 1000 -b 200 \
-o "$MATRIX_OUTPUT" \
--skipZeros

# Step 4: Plot TSS enrichment profile
echo "Plotting TSS enrichment profile..."
plotProfile -m "$MATRIX_OUTPUT" -o "$PROFILE_OUTPUT" --perGroup

# Step 5: Plot heatmap
echo "Plotting TSS enrichment heatmap..."
plotHeatmap -m "$MATRIX_OUTPUT" -o "$HEATMAP_OUTPUT"

echo "TSS enrichment analysis completed!"
