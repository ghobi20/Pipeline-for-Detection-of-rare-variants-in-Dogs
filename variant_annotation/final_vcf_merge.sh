#!/bin/bash

#SBATCH --job-name=final_vcf_merge.sh
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=12G
#SBATCH --output=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/final_vcf_merge.out
#SBATCH --error=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/final_vcf_merge.err
#SBATCH --chdir=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/output/vcf_output

module purge

# Carga tus modulos en la siguiente linea

module load bcftools

# Escribe comandos en la siguiente linea

#bcftools merge ./P[0-9]_final.vcf.gz -Oz -o complete_family.vcf.gz
#bcftools index complete_family.vcf.gz

bcftools norm -m -any -f /mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/reference/canFam6/canFam6.fa complete_family.vcf.gz -Oz -o complete_family_norm.vcf.gz
bcftools index complete_family_norm.vcf.gz
