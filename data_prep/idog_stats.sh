#!/bin/bash

#SBATCH --job-name=iDOG_stats.sh
#SBATCH --nodes=1
#SBATCH --ntasks=2
#SBATCH --cpus-per-task=2
#SBATCH --mem=64G
#SBATCH --output=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/iDOG_stats.out
#SBATCH --error=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/iDOG_stats.err
#SBATCH --chdir=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/known_variants/

module purge

# Carga tus modulos en la siguiente linea

module load bcftools
module load anaconda3/2025.06

# Your script goes here

#This script has the function to retrieve stats from the variants in our vcf files, and then plot them. It will also compare how 
#man variants where able to be mapped in the canFam6 reference genome. 

#First, lets retrieve the stats of each vcf file.

#bcftools stats ./canFam4/Dog_10k/all_SNP.FILTERED.vcf.gz > ./canFam4/Dog10k/all_SNP.FILTERED.stats
#bcftools stats ./canFam4/Dog_10k/AutoAndXPAR.nonSNPs.filter.FILTERED.vcf.gz > ./canFam4/Dog10k/AutoAndXPAR.nonSNPs.filter.FILTERED.stats

bcftools stats ./canFam6/AutoAndXPAR.nonSNPs.filtered.liftover.vcf.gz > ./canFam6/AutoAndXPAR.nonSNPs.filtered.liftover.stats
bcftools stats ./canFam6/AutoAndXPAR.nonSNPs.filtered.rejected.vcf.gz > ./canFam6/AutoAndXPAR.nonSNPs.filtered.rejected.stats
bcftools stats ./canFam6/all_SNP.filtered.liftover.vcf.gz > ./canFam6/all_SNP.filtered.liftover.stats
bcftools stats ./canFam6/all_SNP.filtered.rejected.vcf.gz > ./canFam6/all_SNP.filtered.rejected.stats

bcftools stats ./canFam4/Dog_10k/all_SNP.FILTERED.vcf.gz ./canFam6/all_SNP.filtered.liftover.vcf.gz > ./canFam6/all_SNP.comparison.stats
bcftools stats ./canFam4/Dog_10k/all_SNP.FILTERED.vcf.gz ./canFam6/AutoAndXPAR.nonSNPs.filtered.liftover.vcf.gz > ./canFam6/AutoAndXPAR.nonSNPs.comparison.stats

#Now we plot them!

plot-vcfstats -p ./canFam6/qc_plots ./canFam6/all_SNP.comparison.stats
plot-vcfstats -p ./canFam6/qc_plots ./canFam6/AutoAndXPAR.nonSNPs.comparison.stats


