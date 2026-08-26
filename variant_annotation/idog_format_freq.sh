#!/bin/bash

#SBATCH --job-name=iDOG_fromat_freq.sh
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=5
#SBATCH --mem=32G
#SBATCH --output=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/iDOG_format_freq.out
#SBATCH --error=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/iDOG_format_freq.err
#SBATCH --chdir=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/annovar_dog/dog_ann_db

module purge

# Carga tus modulos en la siguiente linea

module load bcftools 
module load htslib/1.9

# Your script goes here

echo -e "Creando base de datos genérica para la frecuencia alélica a partir de SNPs de Dog10k\n"
bcftools query -f "%CHROM\t%POS\t%END\t%REF\t%ALT\t%H\n" /mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/known_variants/canFam6/all_SNP.filtered.liftover.vcf.gz | sed "s/^chr//" > Dog10k_SNPs_AF.txt

echo -e "Creando base de datos genérica para la frecuencia alélica a partir de INDELs de Dog10k\n"
bcftools query -f "%CHROM\t%POS\t%END\t%REF\t%ALT\t%INFO/AF\n" /mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/known_variants/canFam6/AutoAndXPAR.nonSNPs.filtered.liftover.vcf.gz | sed "s/^chr//" > Dog10k_INDELs_AF.txt

echo -e "Uniendo archivos de SNPs y INDELs"
cat Dog10k_SNPs_AF.txt Dog10k_INDELs_AF.txt > canFam6_Dog10k_AF.txt
