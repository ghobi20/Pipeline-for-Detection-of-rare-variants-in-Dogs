#!/bin/bash

#SBATCH --job-name=canFam6_ref_download
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=32G
#SBATCH --output=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/canFam6_ref_download.out
#SBATCH --error=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/canFam6_ref_download.err
#SBATCH --chdir=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/reference/canFam6

module purge

# Carga tus modulos en la siguiente linea

# Your script goes here

wget --timestamping 'ftp://hgdownload.gi.ucsc.edu/goldenPath/canFam6/bigZips/canFam6.fa.gz'
