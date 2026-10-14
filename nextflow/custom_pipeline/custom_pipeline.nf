process AnnDatabaseDownload{
	input:
	val(RefGenome)

	output:
	path("dog_ann_db")

	when:
	parms.annDir = null

	script:	
	def Dog10k_AF
	def ncbiRefSeqLink
	def refGene
	def refGeneMrna
	def refSeq
	def canVAS_backbone_MAF
	def canVAS_backbone_minorAllele
	def canVAS_IMP_MAF
	def canVAS_IMP_minorAllele
	def key 

        key = "--header='Authorization: Bearer *'"

	if (RefGenome == "canFam4"){
		Dog10k_AF = "${key} 'https://zenodo.org/api/records/23021088/draft/files/canFam4_Dog10k_AF.txt/content'"
		ncbiRefSeqLink = "${key} 'https://zenodo.org/api/records/23021088/draft/files/canFam4_ncbiRefSeqLink.txt/content'"
		refGene = "${key} 'https://zenodo.org/api/records/23021088/draft/files/canFam4_refGene.txt/content'"
		refGeneMrna = "${key} 'https://zenodo.org/api/records/23021088/draft/files/canFam4_refGeneMrna.fa/content'"
		refSeq = "${key} 'https://zenodo.org/api/records/23021088/draft/files/canFam4.fa/content'"
		canVAS_backbone_MAF = "${key} 'https://zenodo.org/api/records/23021088/draft/files/canFam4_canVAS_backbone_MAF.txt/content'"
		canVAS_backbone_minorAllele = "${key} 'https://zenodo.org/api/records/23021088/draft/files/canFam4_canVAS_backbone_minorAllele.txt/content'"
		canVAS_IMP_MAF = "${key} 'https://zenodo.org/api/records/23021088/draft/files/canFam4_canVAS_IMP_MAF.txt/content'"
		canVAS_IMP_minorAllele = "${key} 'https://zenodo.org/api/records/23021088/draft/files/canFam4_canVAS_IMP_minorAllele.txt/content'"	

	} else if (RefGenome == "canFam6"){
                Dog10k_AF = "${key} 'https://zenodo.org/api/records/23021088/draft/files/canFam6_Dog10k_AF.txt/content'"
                ncbiRefSeqLink = "${key} 'https://zenodo.org/api/records/23021088/draft/files/canFam6_ncbiRefSeqLink.txt/content'"
                refGene = "${key} 'https://zenodo.org/api/records/23021088/draft/files/canFam6_refGene.txt/content'"
                refGeneMrna = "${key} 'https://zenodo.org/api/records/23021088/draft/files/canFam6_refGeneMrna.fa/content'"
                refSeq = "${key} 'https://zenodo.org/api/records/23021088/draft/files/canFam6.fa/content'" 
	}	

	"""
	mkdir -p dog_ann_db/${RefGenome}_seq

	wget -O ${RefGenome}_Dog10k_AF.txt ${Dog10k_AF}
	mv ${RefGenome}_Dog10k_AF.txt dog_ann_db
        wget -O ${RefGenome}_ncbiRefSeqLink.txt ${ncbiRefSeqLink} 
	mv ${RefGenome}_ncbiRefSeqLink.txt dog_ann_db
        wget -O ${RefGenome}_refGene.txt ${refGene} 
	mv ${RefGenome}_refGene.txt dog_ann_db
        wget -O ${RefGenome}_refGeneMrna.fa ${refGeneMrna} 
	mv ${RefGenome}_refGeneMrna.fa dog_ann_db
        wget -O ${RefGenome}.fa ${refSeq} 
	mv ${RefGenome}.fa dog_ann_db/${RefGenome}_seq

	if [[ "${RefGenome}" == "canFam4" ]]; then
		wget -O ${RefGenome}_canVAS_backbone_MAF.txt ${canVAS_backbone_MAF} 
		mv ${RefGenome}_canVAS_backbone_MAF.txt dog_ann_db
		wget -O ${RefGenome}_canVAS_backbone_minorAllele.txt ${canVAS_backbone_minorAllele} 
		mv ${RefGenome}_canVAS_backbone_minorAllele.txt dog_ann_db
                wget -O ${RefGenome}_canVAS_IMP_MAF.txt ${canVAS_IMP_MAF} 
		mv ${RefGenome}_canVAS_IMP_MAF.txt dog_ann_db
                wget -O ${RefGenome}_canVAS_IMP_minorAllele.txt ${canVAS_IMP_minorAllele} 
		mv ${RefGenome}_canVAS_IMP_minorAllele.txt dog_ann_db                   
	fi
	"""
}

process VariantAnnotation_Complete {
	input:
	path(annovar_dir)
	val(refBuild)
	path(dog_ann_db)
	path(complete_avinput)

	output:
	path("complete_family.${refBuild}_multianno.csv")

	script:
	"""
	if [[ "${refBuild}" == "canFam4" ]]; then
		${annovar_dir}/table_annovar.pl ${complete_avinput} ${dog_ann_db} \
		-buildver "${refBuild}" \
		-out complete_family \
		-remove \
		-protocol refGene,Dog10k_AF,canVAS_backbone_minorAllele,canVAS_backbone_MAF,canVAS_IMP_minorAllele,canVAS_IMP_MAF \
		-operation g,f,f,f,f,f \
		-nastring . \
		-csvout
	elif [[ "${refBuild}" == "canFam6" ]]; then
	        ${annovar_dir}/table_annovar.pl ${complete_avinput} ${dog_ann_db} \
		-buildver "${refBuild}" \
                -out complete_family \
                -remove \
                -protocol refGene,Dog10k_AF \
                -operation g,f \
                -nastring . \
                -csvout
	fi
	"""
}

process VariantAnnotation_Individual {
        input:
        path(annovar_dir)
        val(refBuild)
        path(dog_ann_db)
        path(individual_avinput)

        output:
        path("${individual_avinput.baseName}.${refBuild}_multianno.csv")

        script:
        """
        if [[ "${refBuild}" == "canFam4" ]]; then
                ${annovar_dir}/table_annovar.pl ${individual_avinput} ${dog_ann_db} \
                -buildver "${refBuild}" \
                -out "${individual_avinput.baseName}" \
                -remove \
                -protocol refGene,Dog10k_AF,canVAS_backbone_minorAllele,canVAS_backbone_MAF,canVAS_IMP_minorAllele,canVAS_IMP_MAF \
                -operation g,f,f,f,f,f \
                -nastring . \
                -csvout
        elif [[ "${refBuild}" == "canFam6" ]]; then
                ${annovar_dir}/table_annovar.pl ${individual_avinput} ${dog_ann_db} \
                -buildver "${refBuild}" \
                -out "${individual_avinput.baseName}" \
                -remove \
                -protocol refGene,Dog10k_AF \
                -operation g,f \
                -nastring . \
                -csvout
        fi
        """
}

process Bcftools_Normalization {
	input:
	path(RefGenomeFile)
	path(RefGenomeFile_idx)
	path(joined_GVcf)
	path(joined_GVcf_idx)	

	output:
	tuple path("${joined_GVcf.simpleName}_norm.vcf.gz"), path("${joined_GVcf.simpleName}_norm.vcf.gz.csi")
	
	script:
	"""
	module load bcftools/1.22	
	
	echo -e "[\$(date)] El llamado de variantes ha sido exitoso. Normalizando GVcf"

	bcftools norm -m -any -f ${RefGenomeFile} ${joined_GVcf} -o ${joined_GVcf.simpleName}_norm.vcf.gz -Oz
	bcftools index ${joined_GVcf.simpleName}_norm.vcf.gz
	"""
}

process Bcftools_Filtration {
	input:
	tuple path(norm_GVcf), path(norm_GVcf_idx)

	output:
	tuple path("${norm_GVcf.simpleName}_filtered.vcf.gz"), path("${norm_GVcf.simpleName}_filtered.vcf.gz.csi")

	script:
	"""
        module load bcftools/1.22       

	echo -e "[\$(date)] Filtrando variantes de baja calidad\n"

	bcftools view -i "QUAL>30 && FORMAT/GQ>30 && FORMAT/DP>10 && (GT=='1/1' || GT=='0/0' || (GT=='0/1' && (FORMAT/AD[0:1])/(FORMAT/AD[0:0]+FORMAT/AD[0:1])>0.18))" ${norm_GVcf} \
	-o ${norm_GVcf.simpleName}_filtered.vcf.gz 
	bcftools index ${norm_GVcf.simpleName}_filtered.vcf.gz

	"""
}

process Bcftools_FinalStats {
	input:
	tuple path(norm_filtered_GVcf), path(norm_filtered_GVcf_idx)

	output:
	path("${norm_filtered_GVcf.simpleName}.metrics.txt")

	script:
	"""
	module load bcftools/1.22

	bcftools stats ${norm_filtered_GVcf} > ${norm_filtered_GVcf.simpleName}.metrics.txt
	"""
}

process Vcf4_to_Avinput_Complete {
	input:
	path(annovar_dir)
	tuple path(norm_filtered_GVcf), path(norm_filtered_GVcf_idx)

	output:
	path("${norm_filtered_GVcf.simpleName}.avinput")

	script:
	"""
	${annovar_dir}/convert2annovar.pl -format vcf4 -withzyg ${norm_filtered_GVcf} > ${norm_filtered_GVcf.simpleName}.avinput 
	"""
}

process Vcf4_to_Avinput_Individual {
        input:
        path(annovar_dir)
        tuple path(norm_filtered_GVcf), path(norm_filtered_GVcf_idx)

        output:
        path("*.avinput")                        

        script:
        """
        ${annovar_dir}/convert2annovar.pl -format vcf4 -allsample -withzyg -outfile family1 ${norm_filtered_GVcf}
        """
}


process GT_Assignment_to_AnnVariants {
	input:
	path(complete_family_annotated)
	tuple path(norm_filtered_GVcf), path(norm_filtered_GVcf_idx)

	output:
	path("complete_family_ann_withGT.canFam6_multianno.csv")

	script:
	"""
	module load bcftools/1.22
	module load htslib/1.9

	echo -e "Creando base de datos de genotipos"
	bcftools query -f "%CHROM,%POS,%END,%REF,%ALT[,%SAMPLE=%GT]\n" ${norm_filtered_GVcf} > complete_family_genotypes.txt
	
	awk -F',' -v OFS=',' ' 
	NR==FNR {
	   chr=\$1
	   pos=\$2
	   ref=\$4
	   alt=\$5
	   
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
	      split(\$i, a, "=")
	      sample[i-5] = a[1]
	      gt[key,i-5] = a[2]
	   }
	
	   n = NF-5
	   next
	}
	
	FNR==1 {
	   printf "%s", \$0
	
	   for (i=1; i<=n; i++){
	      printf ",%s_GT", sample[i]
	   }
	   print ""
	   next
	}
	
	{
	   chr = \$1
	   pos = \$2
	   ref = \$4
	   alt = \$5

	   key = chr"_"pos"_"ref"_"alt
	
	   printf "%s", \$0
	
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
	' complete_family_genotypes.txt ${complete_family_annotated} > complete_family_ann_withGT.canFam6_multianno.csv
	"""
}

/*

process VariantQC_and_Filtering {
	input:
	path(Family_metadata)
	path(Annotated_variants)

	output:
	path("nonsyn_MAF_filtered_variants.csv"), emit: Second_filter_variants
	path(")
	tuple path("AllvariantType_hist.png"), path("Exonic_Variants_hist.png"), emit: VariantType_Distribution_hists 

	script:
	"""
	
	"""
}

process SegregationAnalysis {
	input:
	path(Family_Metadata)
	path(SecondFilteringVariants)

	output:

	script:
	"""

	"""
}

*/

workflow {

	// Variant annotation starts here

        Bcftools_Normalization(channel.fromPath(params.refGenomePath), channel.fromPath(params.refGenomeIdxPath), channel.fromPath(params.GVcf_joint_path), channel.fromPath(params.GVcf_joint_idx_path))   

        Bcftools_Filtration(Bcftools_Normalization.out)

	Bcftools_FinalStats(Bcftools_Filtration.out)

	Vcf4_to_Avinput_Complete(channel.fromPath(params.annovar_dir), Bcftools_Filtration.out)

        Vcf4_to_Avinput_Individual(channel.fromPath(params.annovar_dir), Bcftools_Filtration.out)

	if (params.annDatabaseDir == null){
	        AnnDatabaseDownload(channel.value(params.refGenomeBuild))
		VariantAnnotation_Complete(channel.fromPath(params.annovar_dir), channel.value(params.refGenomeBuild), AnnDatabaseDownload.out, Vcf4_to_Avinput_Complete.out)
                VariantAnnotation_Individual(channel.fromPath(params.annovar_dir), channel.value(params.refGenomeBuild), AnnDatabaseDownload.out, Vcf4_to_Avinput_Individual.out.flatten())
	} else {
		Ann_database_dir_ch = channel.value(file(params.annDatabaseDir))
	        VariantAnnotation_Complete(channel.fromPath(params.annovar_dir), channel.value(params.refGenomeBuild), Ann_database_dir_ch, Vcf4_to_Avinput_Complete.out)
                VariantAnnotation_Individual(channel.fromPath(params.annovar_dir), channel.value(params.refGenomeBuild), Ann_database_dir_ch, Vcf4_to_Avinput_Individual.out.flatten())
	}

        GT_Assignment_to_AnnVariants(VariantAnnotation_Complete.out, Bcftools_Filtration.out)

	/*	

	VariantQC_and_Filtering(channel.fromPath(params.datasheet), VariantAnnotation.out)

	SegregationAnalysis(channel.fromPath(params.datasheet), VariantQC_and_Filtering.Second_filter_variants)

	*/

	publish:	
	bcftools_normalization_out = Bcftools_Normalization.out
	bcftools_filtration_out = Bcftools_Filtration.out
	bcftools_finalstats_out = Bcftools_FinalStats.out
	vcf4_to_avinput_complete = Vcf4_to_Avinput_Complete.out
	vcf4_to_avinput_individual = Vcf4_to_Avinput_Individual.out
        variant_annotation_complete = VariantAnnotation_Complete.out
	variant_annotation_individual = VariantAnnotation_Individual.out
	gt_assignment_to_annvariants_out = GT_Assignment_to_AnnVariants.out
}

output {

	bcftools_normalization_out {
		path 'VariantCalling/Normalized/'
	}

	bcftools_filtration_out {
		path 'VariantCalling/Filtered/'
	}

	bcftools_finalstats_out {
		path 'VariantCalling/Filtered/Metrics'
	}

	vcf4_to_avinput_complete {
		path 'Annotation/Vcf4_2_Avinput/Complete'
	}

        vcf4_to_avinput_individual {
                path 'Annotation/Vcf4_2_Avinput/Individual'
        }

        variant_annotation_complete {
                path 'Annotation/Complete'
        }

        variant_annotation_individual {
                path 'Annotation/Individual'
        }

        gt_assignment_to_annvariants_out {
                path 'Annotation/with_GT'
        }

}
