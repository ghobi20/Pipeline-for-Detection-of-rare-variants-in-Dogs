#!/bin/bash

#SBATCH --job-name=iDOG_depuration.sh
#SBATCH --nodes=5
#SBATCH --ntasks=10
#SBATCH --cpus-per-task=2
#SBATCH --mem=64G
#SBATCH --output=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/iDOG_depuration.out
#SBATCH --error=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/iDOG_depuration.err
#SBATCH --chdir=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/known_variants/canFam4/Dog_10k

module purge

# Carga tus modulos en la siguiente linea

module load bcftools

# Your script goes here

#This script has the function to narrow down our dog variant database to only the vital infromation about each variant, leaving out the genotype of each dog.

bcftools view -G -Oz --threads 16 -o all_SNP.FILTERED.vcf.gz all_SNP.vcf.gz
bcftools view -G -Oz --threads 16 -o AutoAndXPAR.nonSNPs.filter.FILTERED.vcf.gz AutoAndXPAR.nonSNPs.filter.vcf.gz


