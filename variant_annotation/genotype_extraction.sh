#!/bin/bash

#SBATCH --job-name=genotype_extraction.sh
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --output=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/genotype_extraction.out
#SBATCH --error=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/genotype_extraction.err
#SBATCH --chdir=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/output/vcf_output

module purge

# Carga tus modulos en la siguiente linea

module load bcftools
module load htslib/1.9

# Your script goes here

echo -e "Creando base de datos de genotipos"
bcftools query -f "%CHROM,%POS,%END,%REF,%ALT[,%SAMPLE=%GT]\n" complete_family_norm.vcf.gz > ../annovar_output/complete_family_genotypes.txt

awk -F',' -v OFS=',' ' 
NR==FNR {
   chr=$1
   pos=$2
   ref=$4
   alt=$5
   
   #SNPs
   if (length(ref)==1 && length(alt)==1){
      key=chr"_"pos"_"ref"_"alt
   }

   #Deleción
   else if (length(ref) > length(alt)){
      del_len = length(ref)-length(alt)
      del_seq = substr(ref, 2, del_len)
      key = chr"_"(pos+1)"_"del_seq"_-"
   }

   #Inserción
   else if (length(ref) < length(alt)){
      in_len = length(alt)-length(ref)
      in_seq = substr(alt, 2, in_len)
      key = chr"_"pos"_-_"in_seq
   }

   #Loop para guardar el genotipo de cada perro
   for (i=6; i<=NF; i++){
      split($i, a, "=")
      sample[i-5] = a[1]
      gt[key,i-5] = a[2]
   }

   n = NF-5
   next
}

FNR==1 {
   printf "%s", $0

   for (i=1; i<=n; i++){
      printf ",%s_GT", sample[i]
   }
   print ""
   next
}

{
   chr = $1
   pos = $2
   ref = $4
   alt = $5

   key = chr"_"pos"_"ref"_"alt

   printf "%s", $0

   for (i=1; i<=n; i++){
      if ((key,i) in gt){
         printf ",%s", gt[key,i]
      }
      else {
         printf ",."
      }
   }
   print ""
}
' ../annovar_output/complete_family_genotypes.txt \
../annovar_output/complete_family_ann.canFam6_multianno.csv > ../annovar_output/complete_family_with_gt.csv
