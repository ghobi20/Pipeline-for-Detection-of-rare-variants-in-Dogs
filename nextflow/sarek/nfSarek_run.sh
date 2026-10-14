#!/bin/bash

#SBATCH --job-name=nfSarek_pipe
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=5G
#SBATCH --output=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/nfSarek_pipe_%A_%a.out
#SBATCH --error=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/nfSarek_pipe_%A_%a.err
#SBATCH --chdir=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/scripts/nextflow

module purge

# Carga tus modulos en la siguiente linea

module load nextflow/25.10.4
module load singularity/3.7.0


# Your script goes here

export SINGULARITY_CACHEDIR="/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/scripts/nextflow/singularity_cache/cache"
export SINGULARITY_TMPDIR="/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/scripts/nextflow/singularity_cache/tmp"
export NXF_SINGULARITY_CACHEDIR="/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/scripts/nextflow/singularity_cache/nfx_cache"

nextflow run nf-core/sarek -r 3.10.0 -profile singularity -params-file sarek_paramFile.json -c sarek.config -with-report -resume eb7a1e2c-a917-4a2d-876a-af436a08857c
