#!/bin/bash

#SBATCH --job-name=nf_pipe
#SBATCH --nodes=2
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --array=1-4
#SBATCH --output=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/nf_pipe_%A_%a.out
#SBATCH --error=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/nf_pipe_%A_%a.err
#SBATCH --chdir=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/scripts/nextflow

module purge

# Carga tus modulos en la siguiente linea

module load nextflow/25.10.4

# Your script goes here

nexflow run main.nf -with-report report.html
