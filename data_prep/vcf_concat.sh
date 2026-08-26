#!/bin/bash

#SBATCH --job-name=vcf_concat.sh
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --array=1-4
#SBATCH --output=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/vcf_concat%A_%a.out
#SBATCH --error=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/vcf_concat%A_%a.err
#SBATCH --chdir=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/output/vcf_output

module purge

# Carga tus modulos en la siguiente linea

module load bcftools

# Your script goes here

Dog_ID="P${SLURM_ARRAY_TASK_ID}" 
bcftools sort "${Dog_ID}"_INDELs_filtered_bqsr.vcf -o "${Dog_ID}"_INDELs_final.vcf.gz -Oz
bcftools sort "${Dog_ID}"_SNPs_filtered_bqsr.vcf -o "${Dog_ID}"_SNPs_final.vcf.gz -Oz
bcftools index "${Dog_ID}"_INDELs_final.vcf.gz 
bcftools index "${Dog_ID}"_SNPs_final.vcf.gz 
bcftools concat -a ./"${Dog_ID}"_INDELs_final.vcf.gz ./"${Dog_ID}"_SNPs_final.vcf.gz -Oz -o "${Dog_ID}"_final.vcf.gz -Oz
bcftools index ./"${Dog_ID}"_final.vcf.gz

