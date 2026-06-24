#!/bin/bash

#SBATCH --job-name=Alignment_mark_duplicates
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=32G
#SBATCH --array=1-4
#SBATCH --output=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/Alignment_mark_duplicates_%A.out
#SBATCH --error=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/Alignment_mark_duplicates_%A.err
#SBATCH --chdir=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/output/bam_output

module purge

# Carga tus modulos en la siguiente linea

module load picard/2.6.0

# Your script goes here

Dog_ID="P${SLURM_ARRAY_TASK_ID}"

echo "Procesando la muestra ${Dog_ID} en la tarea ${SLURM_ARRAY_TASK_ID}" 

MarkDuplicates \
I=/mnt/Timina/cgonzaga/sgamino/Dog_epilepsy_alignment/output/bam_output/${Dog_ID}.alignment.sort.bam \
O=/mnt/Timina/cgonzaga/sgamino/Dog_epilepsy_alignment/output/bam_output/${Dog_ID}.alignment.sort.dup.bam \
METRICS_FILE=/mnt/Timina/cgonzaga/sgamino/Dog_epilepsy_alignment/output/bam_output/${Dog_ID}_marked_dup_metrics.txt \
CREATE_INDEX=true 
