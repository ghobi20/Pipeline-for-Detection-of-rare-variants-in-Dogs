#!/bin/bash

#SBATCH --job-name=trimming.sh
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=32G
#SBATCH --array=1
#SBATCH --output=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/Trimming_%A_%a.out
#SBATCH --error=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/Trimming_%A_%a.err
#SBATCH --chdir=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/fastq_data/trim_data

module purge

# Carga tus modulos en la siguiente linea

module load fastp/0.20.0

# Your script goes here

Dog_ID="P${SLURM_ARRAY_TASK_ID}"

echo "Procesando la muestra ${Dog_ID} en la tarea ${SLURM_ARRAY_TASK_ID}" 

fastp -i ../raw_data/${Dog_ID}_1.fastq.gz -I ../raw_data/${Dog_ID}_2.fastq.gz \
-o ${Dog_ID}_1.trim.fastq.gz -O ${Dog_ID}_2.trim.fastq.gz \
--detect_adapter_for_pe \
-g \

