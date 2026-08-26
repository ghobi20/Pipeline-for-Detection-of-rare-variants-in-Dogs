#!/bin/bash

#SBATCH --job-name=Dog_database_download
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=5G
#SBATCH --output=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/Dog_database_download.out
#SBATCH --error=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/Dog_database_download.err
#SBATCH --chdir=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/annovar_dog/dog_ann_db

module purge

# Carga tus modulos en la siguiente linea
wget -r ftp://hgdownload.soe.ucsc.edu/goldenPath/canFam6/database/ncbiRefSeq.txt.gz  
wget -r ftp://hgdownload.soe.ucsc.edu/goldenPath/canFam6/database/ncbiRefSeqLink.txt.gz
