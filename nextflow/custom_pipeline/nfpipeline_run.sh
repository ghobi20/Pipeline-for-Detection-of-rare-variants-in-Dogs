#!/bin/bash

#SBATCH --job-name=nf_pipe
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=5G
#SBATCH --output=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/nf_pipe_%A_%a.out
#SBATCH --error=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/nf_pipe_%A_%a.err
#SBATCH --chdir=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/scripts/nextflow/custom_pipeline

module purge

# Carga tus modulos en la siguiente linea

module load nextflow/25.10.4

# Your script goes here

nextflow run custom_pipeline.nf --annDatabaseDir '/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/annovar_dog/canFam4/dog_ann_db' -with-report report.html -c custom_pipeline.config -resume 378881c8-0295-4b2a-9c60-ffcfc01d5987
