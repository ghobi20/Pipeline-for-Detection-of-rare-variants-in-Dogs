#!/bin/bash
# Use current working directory
#$ -cwd
#
# Join stdout and stderr
#$ -j y
#
# Run job through bash shell
#$ -S /bin/bash
#
#You can edit the script since this line
#
# Your job name
#$ -N dog_vcf_download
#$ -l vf=32G
# Send an email after the job has finished
#$ -m e
#$ -o /mnt/Timina/cgonzaga/sgamino/Dog_epilepsy_alignment/logs/bam_alignment/
#$ -e /mnt/Timina/cgonzaga/sgamino/Dog_epilepsy_alignment/logs/bam_alignment/
#$ -M ghobibohg@gmail.com
#
# If modules are needed, source modules environment (Do not delete the next line):
. /etc/profile.d/modules.sh
#
# Add any modules you might require:
#
# Write your commands in the next line
wget -r ftp://download.big.ac.cn/idog/dogsd/vcf/SRZ189891_722g.990.SNP.INDEL.chrAll.vcf.gz
