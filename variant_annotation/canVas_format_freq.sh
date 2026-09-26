#!/bin/bash

#SBATCH --job-name=canVas_fromat_freq.sh
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=5
#SBATCH --mem=32G
#SBATCH --output=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/canVas_format_freq.out
#SBATCH --error=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/canVas_format_freq.err
#SBATCH --chdir=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/known_variants/canFam4/canVAS

module purge

# Carga tus modulos en la siguiente linea

module load htslib/1.9

# Your script goes here

echo -e "Creando base de datos genérica para la frecuencia alélica a partir de SNPs del backbone de canVas"

# Primero definimos si la variante alternativa es el alelo menor o no. Esa es la info que va a tener la primera base de datos.

backbone_file="plink_backbone/canvas_backbone_90pct_v4_canfam4_AlleleCounts.gcount"

awk '
NR == 1 { next }

{
	CHR=$1
	split($2, pos, ":")
	POS=pos[2]
	REF=$3
	ALT=$4
	ref_counts=($6+($7/2))
	alt_counts=($8+($7/2))

	if (ref_counts >= alt_counts){
		minor_allele="ALT"
	}else{
		minor_allele="REF"
	}

	print CHR "\t" POS "\t" POS "\t" REF "\t" ALT "\t" minor_allele
}
' ${backbone_file} > /mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/annovar_dog/canFam4/dog_ann_db/canFam4_canVAS_backbone_minorAllele.txt

awk '
NR == 1 { next }

{
        CHR=$1
	split($2, pos, ":")
        POS=pos[2]
        REF=$3
        ALT=$4
        ref_counts=($6+($7/2))
        alt_counts=($8+($7/2))

        if (ref_counts >= alt_counts) {
		MAF=alt_counts/(alt_counts+ref_counts)
        }else{
                MAF=ref_counts/(alt_counts+ref_counts)
        }

        print CHR "\t" POS "\t" POS "\t" REF "\t" ALT "\t" MAF
}
' ${backbone_file} > /mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/annovar_dog/canFam4/dog_ann_db/canFam4_canVAS_backbone_MAF.txt

echo -e "Creando base de datos genérica para la frecuencia alélica a partir de SNPs de la base de datos de variantes imputadas de canVas"

imputation_file="plink_imputed_maf0.01/canvas_imputed_maf0.01_AlleleCounts.gcount"

awk '
NR == 1 { next }

{
        CHR=$1
	split($2, pos, ":")
        POS=pos[2]
        REF=$3
        ALT=$4
        ref_counts=($5+($6/2))
        alt_counts=($7+($6/2))

        if (ref_counts >= alt_counts){
                minor_allele="ALT"
        }else{
                minor_allele="REF"
        }

        print CHR "\t" POS "\t" POS "\t" REF "\t" ALT "\t" minor_allele
}
' ${imputation_file} > /mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/annovar_dog/canFam4/dog_ann_db/canFam4_canVAS_IMP_minorAllele.txt

awk '
NR == 1 { next }

{
        CHR=$1
	split($2, pos, ":")
        POS=pos[2]
        REF=$3
        ALT=$4
        ref_counts=($5+($6/2))
        alt_counts=($7+($6/2))

        if (ref_counts >= alt_counts) {
                MAF=alt_counts/(alt_counts+ref_counts)
        }else{
                MAF=ref_counts/(alt_counts+ref_counts)
        }

        print CHR "\t" POS "\t" POS "\t" REF "\t" ALT "\t" MAF
}
' ${imputation_file} > /mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/resources/annovar_dog/canFam4/dog_ann_db/canFam4_canVAS_IMP_MAF.txt
