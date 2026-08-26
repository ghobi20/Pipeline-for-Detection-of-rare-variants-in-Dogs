#!/bin/bash

#SBATCH --job-name=Variant_calling_pipeline_BQRS1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=128G
#SBATCH --array=1-4
#SBATCH --output=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/Variant_calling_pipeline_BQRS_Dog_%A_%a.out
#SBATCH --error=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/Variant_calling_pipeline_BQRS_Dog_%A_%a.err
#SBATCH --chdir=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/output/

module purge

# Carga tus modulos en la siguiente linea

module load gatk/4.6.2.0
module load r/4.4.1
module load picard/2.6.0
module load bcftools

# Your script goes here

Dog_ID="P${SLURM_ARRAY_TASK_ID}"

echo -e "Procesando la muestra ${Dog_ID} en la tarea ${SLURM_ARRAY_TASK_ID}\n"

echo -e "[$(date)] Recolectando información de la calidad del alineamiento\n"

#Recolectar información de la calidad de la alineación
#picard CollectAlignmentSummaryMetrics \
#R=/mnt/data/cgonzaga/Data/Dog_genomes/reference/canFam6.fa \
#I=./bam_output/${Dog_ID}.alignment.sort.dedup.rg.bam \
#O=./bam_output/quality_metrics/${Dog_ID}_alignment_sort_dedup_rg_bam.txt

echo -e "[$(date)] Iniciando recalibración de base (BQSR) con BaseRecalibrator\n"

#gatk BaseRecalibrator \
#-I ./bam_output/${Dog_ID}.alignment.sort.dedup.rg.bam \
#-R /mnt/data/cgonzaga/Data/Dog_genomes/reference/canFam6.fa \
#--known-sites /mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/known_variants/download.big.ac.cn/idog/dogsd/vcf/canfam4/all_SNP.vcf.gz \
#--known-sites /mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/known_variants/download.big.ac.cn/idog/dogsd/vcf/canfam4/indel/AutoAndXPAR.nonSNPs.filter.vcf.gz \
#-O ./bam_output/${Dog_ID}_recal_data.table

echo -e "[$(date)] Recalibración de base completada. Aplicando la recalibración a los BAM con ApplyBQSR\n"

#gatk ApplyBQSR \
#-R /mnt/data/cgonzaga/Data/Dog_genomes/reference/canFam6.fa \
#-I ./bam_output/${Dog_ID}.alignment.sort.dedup.rg.bam \
#--bqsr-recal-file ./bam_output/${Dog_ID}_recal_data.table \
#-O ./bam_output/${Dog_ID}.alignment.sort.dedup.recalreads.bam

echo -e "[$(date)]BAMs recalibrados. Sacando métricas de alineamiento\n"

#Recolectar información de la calidad de la alineación
#picard CollectAlignmentSummaryMetrics \
#R=/mnt/data/cgonzaga/Data/Dog_genomes/reference/canFam6.fa \
#I=./bam_output/${Dog_ID}.alignment.sort.dedup.recalreads.bam \
#O=./bam_output/quality_metrics/${Dog_ID}_alignment_sort_dedup_recalreads_bam.txt

echo -e "[$(date)] Llamando variantes con HaplotypeCaller\n"

#gatk HaplotypeCaller \
#-R /mnt/data/cgonzaga/Data/Dog_genomes/reference/canFam6.fa \
#-I ./bam_output/${Dog_ID}.alignment.sort.dedup.recalreads.bam \
#-O ./vcf_output/${Dog_ID}_raw_variants_bqsr.vcf

echo -e "[$(date)] Identificación de haplotipos completado. Iniciando proceso de selección de tipo de variantes con SelectVariants\n"
echo -e "[$(date)] Seleccionando SNPS\n"

#gatk SelectVariants \
#-R /mnt/data/cgonzaga/Data/Dog_genomes/reference/canFam6.fa \
#-V ./vcf_output/${Dog_ID}_raw_variants_bqsr.vcf \
#--select-type-to-include SNP \
#-O ./vcf_output/${Dog_ID}_raw_SNPs_bqsr.vcf

echo -e "[$(date)] Selección de SNPs completado. Seleccionando Indels\n"

#gatk SelectVariants \
#-R /mnt/data/cgonzaga/Data/Dog_genomes/reference/canFam6.fa \
#-V ./vcf_output/${Dog_ID}_raw_variants_bqsr.vcf \
#--select-type-to-include INDEL \
#-O ./vcf_output/${Dog_ID}_raw_INDELs_bqsr.vcf

echo -e "[$(date)] Selección de tipo de variantes completado. Inciando filtrado de variantes con VariantFiltration. SUJETO A CAMBIOS\n"
echo -e "[$(date)] Filtrando SNPs\n"

#gatk VariantFiltration \
#-R /mnt/data/cgonzaga/Data/Dog_genomes/reference/canFam6.fa \
#-V ./vcf_output/${Dog_ID}_raw_SNPs_bqsr.vcf \
#-O ./vcf_output/${Dog_ID}_SNPs_filtered_bqsr.vcf \
#--filter-name "QD_filter" \
#--filter-expression "QD < 2.0" \
#--filter-name "FS_filter" \
#--filter-expression "FS > 60.0" \
#--filter-name "SOR_filter" \
#--filter-expression "SOR > 4.0" \
#--filter-name "MQ_filter" \
#--filter-expression "MQ < 40.0" \
#--filter-name "MQRankSum_filter" \
#--filter-expression "MQRankSum < -12.15" \
#--filter-name "ReadPosRankSum_filter" \
#--filter-expression "ReadPosRankSum < -8.5"

echo -e "[$(date)] Filtrado de SNPs completado. Iniciando Filtrado de INDELs\n"

#gatk VariantFiltration \
#-R /mnt/data/cgonzaga/Data/Dog_genomes/reference/canFam6.fa \
#-V ./vcf_output/${Dog_ID}_raw_INDELs_bqsr.vcf \
#-O ./vcf_output/${Dog_ID}_INDELs_filtered_bqsr.vcf \
#--filter-name "QD_filter" \
#--filter-expression "QD < 2.0" \
#--filter-name "FS_filter" \
#--filter-expression "FS > 200.0" \
#--filter-name "SOR_filter" \
#--filter-expression "SOR > 10.0"

echo -e "[$(date)] FIltrado de Indels completado\n"

echo -e "[$(date)] El llamado de variantes ha sido exitoso. Uniendo vcfs de INDELs y SNPs\n"

#bcftools sort ./vcf_output/${Dog_ID}_INDELs_filtered_bqsr.vcf -o ./vcf_output/${Dog_ID}_INDELs_final_raw.vcf.gz -Oz
#bcftools sort ./vcf_output/${Dog_ID}_SNPs_filtered_bqsr.vcf -o ./vcf_output/${Dog_ID}_SNPs_final_raw.vcf.gz -Oz
#bcftools index ./vcf_output/${Dog_ID}_INDELs_final_raw.vcf.gz 
#bcftools index ./vcf_output/${Dog_ID}_SNPs_final_raw.vcf.gz
bcftools norm -m -any -f /mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/reference/canFam6/canFam6.fa ./vcf_output/${Dog_ID}_INDELs_final_raw.vcf.gz -o ./vcf_output/${Dog_ID}_INDELs_final_raw_norm.vcf.gz -Oz
bcftools index ./vcf_output/${Dog_ID}_INDELs_final_raw_norm.vcf.gz
bcftools concat -a ./vcf_output/${Dog_ID}_INDELs_final_raw_norm.vcf.gz ./vcf_output/${Dog_ID}_SNPs_final_raw.vcf.gz -Oz -o ./vcf_output/${Dog_ID}_final_raw.vcf.gz -Oz
bcftools index ./vcf_output/${Dog_ID}_final_raw.vcf.gz

echo -e "[$(date)] Filtrando variantes de baja calidad\n"

bcftools view -i "QUAL>30 && FORMAT/GQ>30 && FORMAT/DP>10 && (GT=='1/1' || GT=='0/0' || (GT=='0/1' && (FORMAT/AD[0:1])/(FORMAT/AD[0:0]+FORMAT/AD[0:1])>0.18))" \
./vcf_output/${Dog_ID}_final_raw.vcf.gz \
-o ./vcf_output/${Dog_ID}_final.vcf.gz 
bcftools index ./vcf_output/${Dog_ID}_final.vcf.gz
echo "Listo :3"
