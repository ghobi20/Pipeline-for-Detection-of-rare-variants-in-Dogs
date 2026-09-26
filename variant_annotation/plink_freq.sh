#!/bin/bash

#SBATCH --job-name=plink_freq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=32G
#SBATCH --output=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/plink_freq_%A_%a.out
#SBATCH --error=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/plink_freq_%A_%a.err
#SBATCH --chdir=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/known_variants/canFam4/canVAS

module purge

# Carga tus modulos en la siguiente linea

module load plink/2.0

# Your script goes herep

#plink2 --bfile plink_backbone/canvas_backbone_90pct_v4_canfam4 \
#	--fa /mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/reference/canFam4/canFam4.fa \
#	--ref-from-fa --chr-set 38 --make-pgen \
#	--out plink_backbone/canvas_backbone_90pct_v4_canfam4_ref
#plink2 --bfile plink_imputed_maf0.01/canvas_imputed_maf0.01 \
#	--fa /mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/reference/canFam4/canFam4.fa \
#	--ref-from-fa --chr-set 38 --make-pgen \
#	--out plink_imputed_maf0.01/canvas_imputed_maf0.01_canFam4_ref

#plink2 --pfile plink_backbone/canvas_backbone_90pct_v4_canfam4_ref --chr-set 38 --geno-counts --out plink_backbone/canvas_backbone_90pct_v4_canfam4_AlleleCounts
#plink2 --pfile plink_imputed_maf0.01/canvas_imputed_maf0.01_canFam4_ref --chr-set 38 --geno-counts --out plink_imputed_maf0.01/canvas_imputed_maf0.01_AlleleCounts
