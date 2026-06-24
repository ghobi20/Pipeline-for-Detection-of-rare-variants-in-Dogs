#!/bin/bash

#SBATCH --job-name=Variant_filtration
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=32G
#SBATCH --array=1-4
#SBATCH --output=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/Variant_filtration_%A_%a.out
#SBATCH --error=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/Variant_filtrartion_%A_%a.err
#SBATCH --chdir=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/output/vcf_output/

module purge

# Carga tus modulos en la siguiente linea

module load bcftools

# Your script goes here

Dog_ID="P${SLURM_ARRAY_TASK_ID}"

bcftools filter --include 'QUAL>30 && FORMAT/GQ>30' \
${Dog_ID}_INDELs_filtered_annotated.vcf -O v -o ${Dog_ID}_INDELs_filtered_annotated_1.vcf
bcftools filter --include 'QUAL>30 && FORMAT/GQ>30' \
${Dog_ID}_SNPs_filtered_annotated.vcf -O v -o ${Dog_ID}_SNPs_filtered_annotated_1.vcf

bcftools filter --exclude 'CSQ~"synonymous_variant"' \
${Dog_ID}_INDELs_filtered_annotated_1.vcf -O v -o ${Dog_ID}_INDELs_filtered_annotated_final.vcf
bcftools filter --exclude 'CSQ~"synonymous_variant"' \
${Dog_ID}_SNPs_filtered_annotated_1.vcf -O v -o ${Dog_ID}_SNPs_filtered_annotated_final.vcf
