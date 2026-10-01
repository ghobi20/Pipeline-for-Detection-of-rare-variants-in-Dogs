#export NXF_SYNTAX_PARSER=v2

params{
	refGenome: String = 'canFam4'
	annovar_dir: Path = '/home/sgamino/annovar'
	datasheet: Path = '/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/scripts/nextflow/datasheet.csv'
}

process Fastqc_1 {

	input:
	tuple val(meta), path(fwd), path(rvs)  

	output:
	path("P${meta.id}_fastqc.html"), emit: html
	path("P${meta.id}_fastqc.zip"), emit: zip	

	script:
	"""
	module load fastqc/0.12.1

	fastqc ${fwd} ${rvs}  
	"""
}

process Trimming {
	
	input:
	tuple val(meta), path(fwd), path(rvs)

	output:
	tuple val(meta), path("P${meta.id}_*.trim.fastq.gz"), emit: fastp_trim
	path("P${meta.id}_fastp.json"), emit: fastp_json
	path("P${meta.id}_fastp.html"), emit: fastp_html

	script:
	"""
	module load fastp/0.20.0
	
	fastp -i ${fwd} -I ${rvs} \
	-o P${meta.id}_1.trim.fastq.gz -O P${meta.id}_2.trim.fastq.gz \
	--detect_adapter_for_pe \
	-g \
	-j "P${meta.id}_fastp.json" \
	-h "P${meta.id}_fastp.html"

	"""
}

process RefGenomeIndexed {	
	input:
	val(refGenome)

	output:
	tuple path("${refGenome}.fa"), path("${refGenome}.{fa.*,dict}")

	script:
	"""
	module load samtools/1.22.1
	module load bwa/0.7.19

	wget 'ftp://hgdownload.gi.ucsc.edu/goldenPath/${refGenome}/bigZips/${refGenome}.fa.gz'
	gunzip ${refGenome}.fa.gz

	samtools faidx ${refGenome}.fa
	samtools dict ${refGenome}.fa -o ${refGenome}.dict
	bwa index ${refGenome}.fa
	"""
}

process BwaAlignment {
	input:
	tuple path(refGenomeFile), path(refGenomeFile_idx)
	tuple val(meta), path(trim_reads)
	
	output:
	tuple val(meta), path("P${meta.id}.sort.bam"), path("P${meta.id}.sort.bam.bai")

	script:
	"""
	module load bwa/0.7.19
	module load samtools/1.22.1

	#Este script para tomar el read group solo funciona para los identificadores illumina casava 18 
	
	id=\$(zcat ${trim_reads[0]} | head -1 | awk -F: '{print \$3"."\$4}') 
	pu="\${id}-P${meta.id}" 
	#No conozco por ahora la librería con la que se preparo cada muestra. Sientete libre de cambiar esta parte en caso de que tu si lo sepas.
	lb="P${meta.id}_lib1"
	pl="ILLUMINA"
	
	echo "Procesando la muestra P${meta.id}" 
	echo "Read Group:"
	echo "@RG ID:\${id} PU:\${pu} SM:P${meta.id} LB:\${lb} PL:\${pl}"

	bwa mem -M -t 8 -R "@RG\tID:\${id}\tPU:\${pu}\tSM:P${meta.id}\tLB:\${lb}\tPL:\${pl}" \
	${refGenomeFile} \
	${trim_reads[0]} ${trim_reads[1]} | samtools sort -o P${meta.id}.sort.bam
	samtools index P${meta.id}.sort.bam 
	"""
}

process MarkDuplicates {
	input:
	tuple val(meta), path(bam_file), path(bam_idx_file)	

	output:
	tuple val(meta), path("P${meta.id}.markdup.sort.bam"), path("P${meta.id}.markdup.sort.bam.bai"), emit: markdup_bamFiles
	path("P${meta.id}_markdup_metrics.txt"), emit: markdup_bamFiles_metrics

	script:
	"""
	module load gatk/4.6.2.0
	module load samtools/1.22.1

	gatk MarkDuplicates \
	-I ${bam_file} \
	-O P${meta.id}.markdup.sort.bam \
	-M P${meta.id}_markdup_metrics.txt

	samtools index P${meta.id}.markdup.sort.bam 
	"""
}

process AlignmentSummaryMetrics1{
	input:
	tuple path(refGenomeFile), path(refGenomeFile_idx)
	tuple val(meta), path(bamFile), path(bamFile_idx)

	output:
	path("P${meta.id}_alignment_summary_metrics_preBQSR.txt")

	script:
	"""
	module load gatk/4.6.2.0

	# Recolectar información de la calidad de la alineación
	gatk CollectAlignmentSummaryMetrics \
	-R ${refGenomeFile} \
	-I ${bamFile} \
	-O P${meta.id}_alignment_summary_metrics_preBQSR.txt
	"""
}

process KnownVariantsDownload {
	input:
	val(refBuild)

	output:
	tuple path("${refBuild}_all_SNP_GTFiltered.vcf.gz"), path("${refBuild}_all_SNP_GTFiltered.vcf.gz.tbi"), path("${refBuild}_AutoAndXPAR.nonSNPs.filter.GTFiltered.vcf.gz"), path("${refBuild}_AutoAndXPAR.nonSNPs.filter.GTFiltered.vcf.gz.tbi")

	script:
        def knownSNPs
        def knownINDELs

        if (refBuild == "canFam4") {
                knownSNPs = "https://zenodo.org/records/(?)/files/canFam4_all_SNP_GTFiltered.vcf.gz"
                knownINDELs = "https://zenodo.org/records/(?)/files/canFam4_AutoAndXPAR.nonSNPs.filter.GTFiltered.vcf.gz"
        } else if (refBuild == "canFam6") {
                knownSNPs = "https://zenodo.org/records/(?)/files/canFam6_all_SNP_GTFiltered.vcf.gz"
                knownINDELs = "https://zenodo.org/records/(?)/files/canFam6_AutoAndXPAR.nonSNPs.filter.GTFiltered.vcf.gz"       
        }

	"""
	echo -e "[\$(date)] Decargando bases de datos de variantes conocidas (Dog_10k)"

        wget "${knownSNPs}"
        wget "${knownSNPs}.tbi"
        wget "${knownINDELs}"
        wget "${knownINDELs}.tbi"
	"""
}

process BQSR {
	input:
	tuple path(RefGenomeFile), path(RefGenomeFile_idx)
	tuple val(meta), path(markdup_bamFiles), path(markdup_bamFiles_idx)
	tuple path(KnownSNPs), path(KnownSNPs_idx), path(KnownINDELs), path(KnownINDELs_idx)

	output:
	tuple val(meta), path("P${meta.id}_recal_data.table"), path(markdup_bamFiles), path(markdup_bamFiles_idx) 

	script:
	"""
	module load gatk/4.6.2.0

	echo -e "[\$(date)] Iniciando recalibración de base (BQSR) con BaseRecalibrator\n"      

        gatk BaseRecalibrator \
        -I ${markdup_bamFiles} \
        -R ${RefGenomeFile} \
        --known-sites ${KnownSNPs} \
        --known-sites ${KnownINDELs} \
        -O P${meta.id}_recal_data.table
	"""
}

process ApplyBQSR {
	input:
	tuple path(RefGenomeFile), path(RefGenomeFile_idx)	
	tuple val(meta), path(recalData_table), path(markdup_bamFiles), path(markdup_bamFiles_idx)

	output:
	tuple val(meta), path("${meta.id}.markdup.sort.recal.bam"), path("${meta.id}.markdup.sort.recal.bam.bai")

	script:
	"""
	module load gatk/4.6.2.0

        echo -e "[\$(date)] Recalibración de base completada. Aplicando la recalibración a los BAM con ApplyBQSR\n"

        gatk ApplyBQSR \
        -R ${RefGenomeFile} \
        -I ${markdup_bamFiles} \
        --bqsr-recal-file ${recalData_table} \
        -O ${meta.id}.markdup.sort.recal.bam
	"""
}

process AlignmentSummaryMetrics2 {
        input:
        tuple path(refGenomeFile), path(refGenomeFile_idx)
        tuple val(meta), path(bamFile), path(bamFile_idx)

        output:
        path("P${meta.id}_alignment_summary_metrics_postBQSR.txt")

        script:
        """
        module load gatk/4.6.2.0

        gatk CollectAlignmentSummaryMetrics \
        -R ${refGenomeFile} \
        -I ${bamFile} \
        -O P${meta.id}_alignment_summary_metrics_postBQSR.txt
        """
}

process HaplotypeCaller {
	input:
	tuple path(RefGenomeFile), path(RefGenomeFile_idx)
	tuple val(meta), path(recal_bamFile) 

	output:
	tuple val(meta), path("P${meta.id}_raw.vcf")

	script:
	"""
	module load gatk/4.6.2.0 

	echo -e "[$(date)] Llamando variantes con HaplotypeCaller\n"

	gatk HaplotypeCaller \
	-R ${RefGenomeFile} \
	-I ${recal_bamFile} \
	-O P${meta.id}_raw.vcf
	"""
}

process VariantSelection {
	input:
	tuple path(RefGenomeFile), path(RefGenomeFile_idx)
	tuple val(meta), path(raw_vcf)

	output:
	tuple val(meta), path("P${meta.id}_raw_SNPs.vcf"), path("P${meta.id}_raw_INDELs.vcf")

	script:
	"""
	module load gatk/4.6.2.0

	echo -e "[\$(date)] Identificación de haplotipos completado. Iniciando proceso de selección de tipo de variantes con SelectVariants\n"
	echo -e "[\$(date)] Seleccionando SNPS\n"

	gatk SelectVariants \
	-R ${RefGenomeFile} \
	-V ${raw_vcf} \
	--select-type-to-include SNP \
	-O P${meta.id}_raw_SNPs.vcf

	echo -e "[\$(date)] Selección de SNPs completado. Seleccionando Indels\n"

	gatk SelectVariants \
	-R ${RefGenomeFile} \
	-V ${raw_vcf} \
	--select-type-to-include INDEL \
	-O P${meta.id}_raw_INDELs.vcf
	"""
}

process HardVariantFiltration {
	input:
	tuple path(RefGenomeFile), path(RefGenomeFile_idx)
	tuple val(meta), path(raw_SNPs_vcf), path(raw_INDELs_vcf)

	output:
	tuple val(meta), path("P${meta.id}_SNPs_filtered.vcf"), path("P${meta.id}_INDELs_filtered.vcf")

	script:
	"""
	module load gatk/4.6.2.0

	echo -e "[\$(date)] Selección de tipo de variantes completado. Inciando filtrado de variantes con VariantFiltration. SUJETO A CAMBIOS\n"
	echo -e "[\$(date)] Filtrando SNPs\n"

	gatk VariantFiltration \
	-R ${RefGenomeFile} \
	-V ${raw_SNPs_vcf} \
	-O P${meta.id}_SNPs_filtered.vcf \
	--filter-name "QD_filter" \
	--filter-expression "QD < 2.0" \
	--filter-name "FS_filter" \
	--filter-expression "FS > 60.0" \
	--filter-name "SOR_filter" \
	--filter-expression "SOR > 4.0" \
	--filter-name "MQ_filter" \
	--filter-expression "MQ < 40.0" \
	--filter-name "MQRankSum_filter" \
	--filter-expression "MQRankSum < -12.5" \
	--filter-name "ReadPosRankSum_filter" \
	--filter-expression "ReadPosRankSum < -8.5"

	echo -e "[\$(date)] Filtrado de SNPs completado. Iniciando Filtrado de INDELs\n"

	gatk VariantFiltration \
	-R ${RefGenomeFile} \
	-V ${raw_INDELs_vcf} \
	-O P${meta.id}_INDELs_filtered.vcf \
	--filter-name "QD_filter" \
	--filter-expression "QD < 2.0" \
	--filter-name "FS_filter" \
	--filter-expression "FS > 200.0" \
	--filter-name "SOR_filter" \
	--filter-expression "SOR > 10.0"

	echo -e "[\$(date)] FIltrado de Indels completado\n"

	"""
}

process VcfJoin_and_Normalization {
	input:
	tuple path(RefGenomeFile), path(RefGenomeFile_idx)
	tuple val(meta), path(filtered_SNPs_vcf), path(filtered_INDELs_vcf)	

	output:
	tuple val(meta), path("P${meta.id}_norm.vcf.gz"), path("P${meta.id}_norm.vcf.gz.csi")
	
	script:
	"""
	module load bcftools/1.22	
	
	echo -e "[\$(date)] El llamado de variantes ha sido exitoso. Uniendo y normalizando vcfs de INDELs y SNPs\n"

	bcftools sort ${filtered_INDELs_vcf} -o P${meta.id}_INDELs_filtered_sort.vcf.gz -Oz
	bcftools sort ${filtered_SNPs_vcf} -o P${meta.id}_SNPs_filtered_sort.vcf.gz -Oz
	bcftools index P${meta.id}_INDELs_filtered_sort.vcf.gz 
	bcftools index P${meta.id}_SNPs_filtered_sort.vcf.gz
	bcftools norm -m -any -f ${RefGenomeFile} P${meta.id}_INDELs_filtered_sort.vcf.gz -o P${meta.id}_INDELs_filtered_norm.vcf.gz -Oz
	bcftools norm -m -any -f ${RefGenomeFile} P${meta.id}_SNPs_filtered_sort.vcf.gz -o P${meta.id}_SNPs_filtered_norm.vcf.gz -Oz
	bcftools index P${meta.id}_INDELs_filtered_norm.vcf.gz
        bcftools index P${meta.id}_SNPs_filtered_norm.vcf.gz
	bcftools concat -a P${meta.id}_INDELs_filtered_norm.vcf.gz P${meta.id}_SNPs_filtered_norm.vcf.gz -o P${meta.id}_norm.vcf.gz -Oz
	bcftools index P${meta.id}_norm.vcf.gz
	"""
}

process SoftVariantFiltration {
	input:
	tuple val(meta), path(norm_vcf), path(norm_vcf_idx)

	output:
	tuple val(meta), path("P${meta.id}_final.vcf.gz"), path("P${meta.id}_final.vcf.gz.csi")

	script:
	"""
        module load bcftools/1.22       

	echo -e "[\$(date)] Filtrando variantes de baja calidad\n"

	bcftools view -i "QUAL>30 && FORMAT/GQ>30 && FORMAT/DP>10 && (GT=='1/1' || GT=='0/0' || (GT=='0/1' && (FORMAT/AD[0:1])/(FORMAT/AD[0:0]+FORMAT/AD[0:1])>0.18))" ${norm_vcf} \
	-o P${meta.id}_final.vcf.gz 
	bcftools index P${meta.id}_final.vcf.gz
	echo "Listo :3"

	"""
}

process VcfMerge {
	input:
	path(final_vcfs) 
	path(final_vcfs_idx)

	output:
	tuple path("complete_family.vcf.gz"), path("complete_family.vcf.gz.csi"), emit: complete_out
	path("complete_family.vcf.gz"), emit: vcf_only

	script:
	"""
	module load bcftools/1.22

	echo -e "[\$(date) Uniendo todos los vcfs...]"

	bcftools merge ${final_vcfs} -Oz -o complete_family.vcf.gz
	bcftools index complete_family.vcf.gz
	"""
}

process AnnDatabaseDownload{
	input:
	val(RefGenome)

	output:
	path("dog_ann_db")

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

	if (RefGenome == "canFam4"){
		Dog10k_AF = "https://zenodo.org/records/(?)/files/canFam4_Dog10k_AF.txt"
		ncbiRefSeqLink = "https://zenodo.org/records/(?)/files/canFam4_ncbiRefSeqLink.txt"
		refGene = "https://zenodo.org/records/(?)/files/canFam4_refGene.txt"
		refGeneMrna = "https://zenodo.org/records/(?)/files/canFam4_refGeneMrna.fa"
		refSeq = "https://zenodo.org/records/(?)/files/canFam4.fa"
		canVAS_backbone_MAF = "https://zenodo.org/records/(?)/files/canFam4_canVAS_backbone_MAF.txt"
		canVAS_backbone_minorAllele = "https://zenodo.org/records/(?)/files/canFam4_canVAS_backbone_minorAllele.txt"
		canVAS_IMP_MAF = "https://zenodo.org/records/(?)/files/canFam4_canVAS_IMP_MAF.txt"
		canVAS_IMP_minorAllele = "https://zenodo.org/records/(?)/files/canFam4_canVAS_IMP_minorAllele.txt"	

	} else if (RefGenome == "canFam6"){
                Dog10k_AF = "https://zenodo.org/records/(?)/files/canFam6_Dog10k_AF.txt"
                ncbiRefSeqLink = "https://zenodo.org/records/(?)/files/canFam6_ncbiRefSeqLink.txt"
                refGene = "https://zenodo.org/records/(?)/files/canFam6_refGene.txt"
                refGeneMrna = "https://zenodo.org/records/(?)/files/canFam6_refGeneMrna.fa"
                refSeq = "https://zenodo.org/records/(?)/files/canFam6.fa" 
	}	

	"""
	mkdir -p dog_ann_db/${RefGenome}_seq

	wget --timestamping ${Dog10k_AF} -O dog_ann_db/${RefGenome}_Dog10k_AF.txt
        wget --timestamping ${ncbiRefSeqLink} -O dog_ann_db/${RefGenome}_ncbiRefSeqLink.txt
        wget --timestamping ${refGene} -O dog_ann_db/${RefGenome}_refGene.txt
        wget --timestamping ${refGeneMrna} -O dog_ann_db/${RefGenome}_refGeneMrna.fa
        wget --timestamping ${refSeq} -O dog_ann_db/${RefGenome}_seq/${RefGenome}.fa

	if ["${RefGenome}" == "canFam4"]; then
		wget --timestamping ${canVAS_backbone_MAF} -O dog_ann_db/${RefGenome}_canVAS_backbone_MAF.txt
		wget --timestamping ${canVAS_backbone_minorAllele} -O dog_ann_db/${RefGenome}_canVAS_backbone_minorAllele.txt
                wget --timestamping ${canVAS_IMP_MAF} -O dog_ann_db/${RefGenome}_canVAS_IMP_MAF.txt
                wget --timestamping ${canVAS_IMP_minorAllele} -O dog_ann_db/${RefGenome}_canVAS_IMP_minorAllele.txt                      
	fi
	"""
}

process VariantAnnotation {
	input:
	path(annovar_dir)
	val(refBuild)
	tuple path(complete_vcf), path(complete_vcf_idx)
	path(dog_ann_db)

	output:
	path("complete_family.${RefGenomeFile.simpleName}_multianno.csv")

	script:
	"""
	if ["${RefGenomeFile.simpleName}" == "canFam4"]; then
		${annovar_dir}/table_annovar.pl ${complete_vcf} ${dog_ann_db} \
		-buildver "${refBuild}" \
		-out complete_family \
		-remove \
		-protocol refGene,Dog10k_AF,canVAS_backbone_minorAllele,canVAS_backbone_MAF,canVAS_IMP_minorAllele,canVAS_IMP_MAF \
		-operation g,f,f,f,f,f \
		-nastring . \
		-csvout
	elif ["${RefGenomeFile.simpleName}" == "canFam6"]; then
	        ${annovar_dir}/table_annovar.pl ${complete_vcf} ${dog_ann_db} \
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

workflow {

	main:
	sampleMetadata_ch = channel.fromPath(params.datasheet)
		.splitCsv(header: true)
		.map { row ->
			tuple(
				[id: row.id, pedigree_status: row.pedigree_status, condition: row.condition], 
				file(row.fwd),
				file(row.rvs)
			)	
		}

	Fastqc_1(sampleMetadata_ch)

	Trimming(sampleMetadata_ch)

	RefGenomeIndexed(channel.value(params.refGenome))

	BwaAlignment(RefGenomeIndexed.out, Trimming.out.fastp_trim)

	MarkDuplicates(BwaAlignment.out)
	
	// Variant calling starts here.

	AlignmentSummaryMetrics1(RefGenomeIndexed.out, MarkDuplicates.out.markdup_bamFiles)

	KnownVariantsDownload(channel.value(params.refGenome))

	BQSR(RefGenomeIndexed.out, MarkDuplicates.out.markdup_bamFiles, KnownVariantsDownload.out)

	ApplyBQSR(RefGenomeIndexed.out, BQSR.out)	

	AlignmentSummaryMetrics2(RefGenomeIndexed.out, BQSR_and_ApplyBQSR.out)

	HaplotypeCaller(RefGenomeIndexed.out, BQSR_and_ApplyBQSR.out)

	VariantSelection(RefGenomeIndexed.out, HaplotypeCaller.out)

	HardVariantFiltration(RefGenomeIndexed.out, VariantSelection.out)

	VcfJoin_and_Normalization(RefGenomeIndexed.out, HardVariantFiltration.out)	

	SoftVariantFiltration(VcfJoin_and_Normalization.out)

	VcfMerge(SoftVariantFiltration.out
					.toSortedList {a,b -> a[0].id <=> b[0].id}
					.map {rows -> [rows.collect{row -> row[1]}, rows.collect{row -> row[2]}]}
	)

	// Variant annotation starts here

	AnnDatabaseDownload(channel.value(params.refGenome))

	VariantAnnotation(channel.fromPath(params.annovar_dir), channel.value(params.refGenome), VcfMerge.out.complete_out, AnnDatabaseDownload.out)

	publish:
	fastqc1_reports = Fastqc_1.out.html.mix(Fastqc_1.out.zip) 
	trimming_reports = Trimming.out.fastp_json.mix(Trimming.out.fastp_html)
	markdup_BamFiles = MarkDuplicates.out.markdup_bamFiles
	markdup_BamFiles_metrics = MarkDuplicates.out.markdup_bamFiles_metrics
	alignment_summary_metrics1 = AlignmentSummaryMetrics1.out
	alignment_summary_metrics2 = AlignmentSummaryMetrics2.out
	complete_family_vcf = VcfMerge.out.vcf_only
	complete_family_avinput = Vcf4_2_avInput.out	
	complete_family_annotated = VariantAnnotation.out
}

output {
	fastqc1_reports{
		path 'input/fastq_data/raw_data/qc_reports'
		mode 'copy'
	}

	trimming_reports{
		path 'input/fastq_data/trim_data/qc_reports'
		mode 'copy'
	}
	
	markdup_BamFiles{
		path 'output/bam_data/'
		mode 'copy'
	}

	markdup_BamFiles_metrics{
		path 'output/bam_data/qc_metrics'
		mode 'copy'
	}
	
	alignment_summary_metrics1{
		path 'output/bam_data/qc_metrics'
		mode 'copy'
	}

	alignment_summary_metrics2{
		path 'output/bam_data/qc_metrics'
		mode 'copy'
	}

	complete_family_vcf{
		path 'output/vcf_data/'
		mode 'copy'
	}

	complete_family_avinput{
		path 'output/avinput_data/'
		mode 'copy'
	}

	complete_family_annotated{
		path 'output/annotated_csv/'
		mode 'copy'
	}
}
