l####################################################################################################
Aquí va en canal y los parámetros. Aún no se como configurarlos, entonces comenzaré con los procesos.
#####################################################################################################
export NXF_SYNTAX_PARSER=v2

params{
			
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

process refGenomeIndex {	

	input:
	path(refGenome)

	output:
	tuple path(${refGenome}), path("${refGenome.SimpleName}.fa.*")

	script:
	"""
	module load samtools/1.22.1
	module load bwa/0.7.19

	samtools faidx ${refGenome}
	bwa index ${refGenome}
	"""
}

process BwaAlignment {
	input:
	
	
	output:

	script:
	"""
	
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

	RefGenomeIndex(params.refGenomePath)

	BwaAlignment(refGenomeIndex.out, Trimming.out.fastp_trim)
	
	publish:
	fastqc1_reports = Fastqc_1.out.html, Fastqc_1.out.zip 
	trimming_reports = Trimming.out.fastp_json, Trimming.out.fastp_html
}

output {
	fastqc1_reports{
		path 'fastq_data/raw_data/qc_reports'
		mode 'copy'
	}

	trimming_qc1_reports{
		path 'fastq_data/trim_data/qc_reports'
		mode 'copy'
	}

