#!/bin/bash

#SBATCH --job-name=variant_ann
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --output=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/Variant_annotation.out
#SBATCH --error=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/Variant_annotation.err
#SBATCH --chdir=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/output/annovar_output/

module purge

# Carga tus modulos en la siguiente linea

# Your script goes here

#echo -e "Anotando archivo avinput de la familia completa"

#/home/sgamino/annovar/table_annovar.pl ./avinput/complete_family.avinput /mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/annovar_dog/dog_ann_db \
#-buildver canFam6 \
#-out complete_family_ann \
#-remove \
#-protocol refGene,Dog10k_AF \
#-operation g,f \
#-nastring . \
#-csvout

for sample in {1..4}; do
/home/sgamino/annovar/table_annovar.pl ./avinput/P${sample}_final.avinput /mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/annovar_dog/dog_ann_db \
-buildver canFam6 \
-out P${sample}_ann \
-remove \
-protocol refGene,Dog10k_AF \
-operation g,f \
-nastring . \
-csvout
done
