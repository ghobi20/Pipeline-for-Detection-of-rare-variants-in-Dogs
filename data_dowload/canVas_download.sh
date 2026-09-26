#!/bin/bash

#SBATCH --job-name=canVas_backbone_download
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=5G
#SBATCH --output=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/canVas_backbone_download.out
#SBATCH --error=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/canVas_backbone_download.err
#SBATCH --chdir=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/known_variants/canFam4/canVAS

module purge

# Carga tus modulos en la siguiente linea
#wget -r --progress=bar "https://zenodo.org/records/21036966/files/canvas_backbone_90pct_v4_canfam4.bed"
#wget -r --progress=bar "https://zenodo.org/records/21036966/files/canvas_backbone_90pct_v4_canfam4.bim"
#wget -r --progress=bar "https://zenodo.org/records/21036966/files/canvas_backbone_90pct_v4_canfam4.fam"

wget -r --progress=bar "https://zenodo.org/records/19186944/files/canvas_imputed_maf0.01.bed"
wget -r --progress=bar "https://zenodo.org/records/19186944/files/canvas_imputed_maf0.01.bim" 
wget -r --progress=bar "https://zenodo.org/records/19186944/files/canvas_imputed_maf0.01.fam"          
         


