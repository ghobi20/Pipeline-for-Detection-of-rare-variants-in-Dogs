####################################################################################################
Aquí va en canal y los parámetros. Aún no se como configurarlos, entonces comenzaré con los procesos.
#####################################################################################################
export NXF_SYNTAX_PARSER=v2

params{
	refGenome = 'canFam4'
}

process fastqc_1 {

	input:
	tuple val(meta), path(fwd), path(rvs)  

	output:
	tuple val(meta), path("*_fastqc.html"), emit: html
	tuple val(meta), path("*_fastqc.zip"), emit: zip	

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

process refGenomeIndexed {	

	input:
	val(refGenome)

	output:
	tuple path(${refGenome}.fa.gz), path("${refGenome}.fa.*")

	script:
	"""
	module load samtools/1.22.1
	module load bwa/0.7.19
	module load htslib/1.16

	wget 'ftp://hgdownload.gi.ucsc.edu/goldenPath/${refGenome}/bigZips/${refGenome}.fa.gz'
	gunzip ${refGenome}.fa.gz

	samtools faidx ${refGenome}
	bwa index ${refGenome}
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
	module load picard/2.6.0
	module load samtools/1.22.1

	MarkDuplicates \
	I=${bam_file} \
	O=P${meta.id}.markdup.sort.bam \
	METRICS_FILE=P${meta.id}_markdup_metrics.txt

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
	module load picard/2.6.0

	#Recolectar información de la calidad de la alineación
	picard CollectAlignmentSummaryMetrics \
	R=${refGenomeFile} \
	I=${bamFile} \
	O=P${meta.id}_alignment_summary_metrics_preBQSR.txt
	"""
}

BQSR_and_ApplyBQSR{
	input:
	tuple path(RefGenomeFile), path(RefGenomeFile_idx)
	tuple val(meta) path(markdup_bamFiles), path(markdupl_bamFiles_idx)

	output:
	tuple val(meta), path("${meta.id}.markdup.sort.recal.bam")

	script:

	def refBuild = RefGenomeFile.simpleName

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
	module load gatk/4.6.2.0

	echo -e "[$(date)] Decargando bases de datos de variantes conocidas (Dog_10k)"
	
	wget --timestamps "${knownSNPs}"
	wget --timestamps "${knownSNPs}.tbi"
	wget --timestamps "${knownINDELs}"
	wget --timestamps "${knownINDELs}.tbi"

	echo -e "[$(date)] Iniciando recalibración de base (BQSR) con BaseRecalibrator\n"	

	gatk BaseRecalibrator \
	-I ${markdup_bamFiles} \
	-R ${RefGenomeFile} \
	--known-sites ${refBuild}_all_SNP_GTFiltered.vcf.gz \
	--known-sites ${refBuild}_AutoAndXPAR.nonSNPs.filter.GTFiltered.vcf.gz \
	-O P${meta.id}_recal_data.table

	echo -e "[$(date)] Recalibración de base completada. Aplicando la recalibración a los BAM con ApplyBQSR\n"

	gatk ApplyBQSR \
	-R ${RefGenomeFile} \
	-I ${markdup_bamFiles} \
	--bqsr-recal-file ${meta.id}_recal_data.table \
	-O ${meta.id}.markdup.sort.recal.bam
	"""	
}

process AlignmentSummaryMetrics2{
        input:
        tuple path(refGenomeFile), path(refGenomeFile_idx)
        tuple val(meta), path(bamFile), path(bamFile_idx)

        output:
        path("P${meta.id}_alignment_summary_metrics_postBQSR.txt")

        script:
        """
        module load picard/2.6.0

        #Recolectar información de la calidad de la alineación
        picard CollectAlignmentSummaryMetrics \
        R=${refGenomeFile} \
        I=${bamFile} \
        O=P${meta.id}_alignment_summary_metrics_postBQSR.txt
        """
}

HaplotypeCaller{
	input:
	tuple path(RefGenomeFile), path(RefGenomeFile_idx)
	tuple val(meta), path(recal_bamFile) 

	output:
	tuple val(meta), path("P${meta.id}_raw.vcf")

	script:
	"""
	echo -e "[$(date)] Llamando variantes con HaplotypeCaller\n"

	gatk HaplotypeCaller \
	-R ${RefGenomeFile} \
	-I ${recal_bamFile} \
	-O P${meta.id}_raw.vcf
	"""
}

workflow {

	main:
	sampleMetadata_ch = channel.fromPath(params.datasheet)
		.splitCsv(header: true)
		.map { row ->
			tuple(
				[id: row.id, status: row.status], 
				file(row.fwd),
				file(row.rvs)
			)	
		}

	Fastqc_1(sampleMetadata_ch)

	Trimming(sampleMetadata_ch)

	RefGenomeIndexed(val(params.refGenome))

	BwaAlignment(RefGenomeIndexed.out, Trimming.out.fastp_trim)

	MarkDuplicates(BwaAlignment.out)
	
	#Here, the variant calling processes start.

	AlignmentSummaryMetrics1(RefGenomeIndexed.out, MarkDuplicates.out.markdup_bamFiles)

	BQSR_and_ApplyBQSR(RefGenomeIndexed.out, MarkDuplicates.out.markdupl_bamFiles)	

	AlignmentSummaryMetrics2(RefGenomeIndexed.out, BQSR_and_ApplyBQSR.out)

	HaplotypeCaller(RefGenomeIndexed.out, BQSR_and_ApplyBQSR.out)

	publish:
	fastqc1_reports = Fastqc_1.out.html, Fastqc_1.out.zip 
	trimming_reports = Trimming.out.fastp_json, Trimming.out.fastp_html
	markdup_BamFiles = MarkDuplicates.out.markdup_bamFiles
	markdup_BamFiles_metrics = MarkDuplicates.out.markdup_bamFiles_metrics
	alignment_summary_metrics1 = AlignmentSummaryMetrics1.out
	alignment_summary_metrics2 = AlignmentSummaryMetrics2.out
}

output {
	fastqc1_reports{
		path 'input/fastq_data/raw_data/qc_reports'
		mode 'copy'
	}

	trimming_qc1_reports{
		path 'input/fastq_data/trim_data/qc_reports'
		mode 'copy'
	}
	
	markdup_BamFiles{
		path 'output/bam_data/'
		mode 'copy'
	}

	markdup_BamFiles{
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
