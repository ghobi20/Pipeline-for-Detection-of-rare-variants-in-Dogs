#!/bin/bash

#SBATCH --job-name=Vcf4_to_annovarfile
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --output=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/Vcf4_to_annovarfile%A_%a.out
#SBATCH --error=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/Vcf4_to_annovarfile_%A_%a.err
#SBATCH --chdir=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/output/vcf_output

module purge

# Carga tus modulos en la siguiente linea

# Your script goes here

#/home/sgamino/annovar/convert2annovar.pl -format vcf4 -allsample -withfreq complete_family_norm.vcf.gz > \
#/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/output/annovar_output/avinput/complete_family.avinput

for sample in {1..4}; do
/home/sgamino/annovar/convert2annovar.pl -format vcf4 -allsample -withfreq P${sample}_final.vcf.gz > /mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/output/annovar_output/avinput/P${sample}_final.avinput
done
