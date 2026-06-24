#!/bin/bash

#SBATCH --job-name=Alignment
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=32G
#SBATCH --array=1-4
#SBATCH --output=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/Alignment_%A.out
#SBATCH --error=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/Alignment_%A.err
#SBATCH --chdir=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/output/sam_output

module purge

# Carga tus modulos en la siguiente linea

module load bwa/0.7.8

# Your script goes here

Dog_ID="P${SLURM_ARRAY_TASK_ID}"

echo "Procesando la muestra ${Dog_ID} en la tarea ${SLURM_ARRAY_TASK_ID}" 

bwa mem -M -t 2 -R \
/mnt/Timina/cgonzaga/Data/Dog_genomes/reference/canFam6.fa.gz \
/mnt/Timina/cgonzaga/Data/Dog_genomes/Fam_chih_epilepsy/${Dog_ID}_1.fastq.gz \
/mnt/Timina/cgonzaga/Data/Dog_genomes/Fam_chih_epilepsy/${Dog_ID}_2.fastq.gz > /mnt/Timina/cgonzaga/sgamino/Dog_epilepsy_alignment/${Dog_ID}_alignment.sam
