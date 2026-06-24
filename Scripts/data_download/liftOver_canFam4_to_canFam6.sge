#!/bin/bash

#SBATCH --job-name=liftOver_canFam4_to_canFam6_map
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=5G
#SBATCH --output=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/canfam4_to_canfam6_%A_%a.out
#SBATCH --error=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/canfam4_to_canfam6_%A_%a.err
#SBATCH --chdir=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/liftOver_maps/

module purge

# Carga tus modulos en la siguiente linea
wget -r ftp://hgdownload.gi.ucsc.edu/goldenPath/canFam4/liftOver/canFam4ToCanFam6.over.chain.gz
