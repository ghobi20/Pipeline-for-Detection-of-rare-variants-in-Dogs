#!/bin/bash

#SBATCH --job-name=Dog_Alignment
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --array=1-4
#SBATCH --output=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/Alignment_%A_%a.out
#SBATCH --error=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/Alignment_%A_%a.err
#SBATCH --chdir=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/fastq_data/trim_data

module purge

# Carga tus modulos en la siguiente linea

module load bwa/0.7.19

# Your script goes here

Dog_ID="P${SLURM_ARRAY_TASK_ID}"

#Este script para tomar el read group solo funciona para los identificadores illumina casava 18 

id= $(zcat ${Dog_ID}_1.fastq.gz | head -1 | awk -F: '{print $3"."$4}') 
pu="${id}-${Dog_ID}" 
#No conozco por ahora la librería con la que se preparo cada muestra. Sientete libre de cambiar esta parte en caso de que tu si lo sepas.
lb="${Dog_ID}_lib1"
pl="ILLUMINA"

echo "Procesando la muestra ${Dog_ID} en la tarea ${SLURM_ARRAY_TASK_ID}" 
echo "Read Group:"
echo "@RG ID:${id} PU:${pu} SM:${Dog_ID} LB:${lb} PL:${pl}"

bwa mem -M -t 8 \
-R "@RG\tID:${id}\tPU:${pu}\tSM:${Dog_ID}\tLB:${lb}\tPL:${pl}") \
/mnt/Timina/cgonzaga/Data/Dog_genomes/reference/canFam6.fa.gz \
${Dog_ID}_1.trim.fastq.gz ${Dog_ID}_2.trim.fastq.gz > /mnt/Timina/cgonzaga/sgamino/Dog_epilepsy_alignment/output/sam_output/${Dog_ID}_alignment.sam.gz

