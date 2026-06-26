#!/bin/bash

#SBATCH --job-name=MAF_calculation.sh
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=64G
#SBATCH --output=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/MAF_calculation.out
#SBATCH --error=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/MAF_calculation.err
#SBATCH --chdir=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/known_variants/canFam6

module purge

# Carga tus modulos en la siguiente linea

module load picard/2.6.0

# Your script goes here

