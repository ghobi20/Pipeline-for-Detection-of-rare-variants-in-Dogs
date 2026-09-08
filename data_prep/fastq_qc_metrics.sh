#!/bin/bash

#SBATCH --job-name=fastq_qc_metrics
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=64G
#SBATCH --array=1-1
#SBATCH --output=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/fastq_qc_metrics.out
#SBATCH --error=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/fastq_qc_metrics.err
#SBATCH --chdir=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/fastq_data/raw_data

module purge

# Carga tus modulos en la siguiente linea

module load fastqc/0.12.1

# Your script goes here
Dog_ID="P${SLURM_ARRAY_TASK_ID}"

fastqc ${Dog_ID}_1.fastq.gz ${Dog_ID}_2.fastq.gz -o ./qc_reports/
