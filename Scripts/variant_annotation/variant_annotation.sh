#!/bin/bash

#SBATCH --job-name=Vcf4_to_annovarfile
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --array=1-4
#SBATCH --output=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/Variant_annotation%A_%a.out
#SBATCH --error=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/Variant_annotation%A_%a.err
#SBATCH --chdir=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/output/vcf_output/annovar_variants

module purge

# Carga tus modulos en la siguiente linea

# Your script goes here

Dog_ID="P${SLURM_ARRAY_TASK_ID}"
/home/sgamino/annovar/table_annovar.pl ${Dog_ID}_SNPs_filtered_bqsr.avinput /mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/annovar_dog/dog_ann_db \
-buildver canFam6 \
-out ${Dog_ID}_SNPs \
-remove \
-protocol refGene \
-operation g \
-nastring .

/home/sgamino/annovar/table_annovar.pl ${Dog_ID}_INDELs_filtered_bqsr.avinput /mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/annovar_dog/dog_ann_db \
-buildver canFam6 \
-out ${Dog_ID}_INDELs \
-remove \
-protocol refGene \
-operation g \
-nastring .
