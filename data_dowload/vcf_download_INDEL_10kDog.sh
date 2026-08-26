#!/bin/bash

#SBATCH --job-name=vcf_INDEL_variants_10kDog
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=5G 
#SBATCH --output=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/vcf_INDEL_variants_10kDog_%A_%a.out
#SBATCH --error=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/vcf_INDEL_variants_10kDog_%A_%a.err
#SBATCH --chdir=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/known_variants/canFam4

module purge

# Carga tus modulos en la siguiente linea
wget -c http://download.big.ac.cn/idog/dogsd/vcf/canfam4/indel/AutoAndXPAR.nonSNPs.filter.vcf.gz
wget -c http://download.big.ac.cn/idog/dogsd/vcf/canfam4/indel/AutoAndXPAR.nonSNPs.filter.vcf.gz.tbi
