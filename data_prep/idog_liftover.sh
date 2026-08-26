#!/bin/bash

#SBATCH --job-name=iDOG_vcf_liftover.sh
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=5
#SBATCH --mem=128G
#SBATCH --output=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/iDOG_vcf_liftover.out
#SBATCH --error=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/iDOG_vcf_liftover.err
#SBATCH --chdir=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/known_variants/canFam4/Dog_10k

module purge

# Carga tus modulos en la siguiente linea

module load oracle-java/8u371

# Your script goes here

echo "JAVA:"
which java
java -version
java -XshowSettings:vm -Xmx110g -version

echo "MEMORIA DEL JOB:"
free -g
ulimit -a

echo "Haciendo LiftOver de los SNPs de iDOG..."
#java -Xmx110g -jar /opt/apps/picard/2.6.0/bin/picard.jar LiftoverVcf \
#  I=all_SNP.FILTERED.vcf.gz \
#  O=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/known_variants/canFam6/all_SNP.filtered.liftover.vcf.gz \
#  CHAIN=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/liftOver_info/chainmap/canFam4ToCanFam6.over.chain.gz \
#  REJECT=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/known_variants/canFam6/all_SNP_.filtered.rejected.vcf.gz \
#  R=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/reference/canFam6/canFam6.fa \
#  MAX_RECORDS_IN_RAM=500000 \
#  TMP_DIR=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/tmp

echo "Haciendo LiftOver de los INDELs de iDOG..."
java -Xmx110g -jar /opt/apps/picard/2.6.0/bin/picard.jar LiftoverVcf \
  I=AutoAndXPAR.nonSNPs.filter.FILTERED.vcf.gz \
  O=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/known_variants/canFam6/AutoAndXPAR.nonSNPs.filtered.liftover.vcf.gz \
  CHAIN=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/liftOver_info/chainmap/canFam4ToCanFam6.over.chain.gz \
  REJECT=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/known_variants/canFam6/AutoAndXPAR.nonSNPs.filtered.rejected.vcf.gz \
  R=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/reference/canFam6/canFam6.fa \
  MAX_RECORDS_IN_RAM=500000 \
  TMP_DIR=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/tmp
