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
	val(refGenome)

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

	fastqc_1(sampleMetadata_ch)

	trimming(sampleMetadata_ch)

	refGenomeIndex(params.refGenomePath)
	
	publish:
	fastqc1_reports = fastqc_1.out.html, fastqc_1.out.zip
	trimmed_reads = trimming.out.fastp_trim 
	trimming_reports = trimming.out.fastp_json, trimming.out.fastp_html
}

output {
	fastqc1_reports{
		path 'fastq_data/raw_data/qc_reports'
		mode 'copy'
	}

	trimming_reads{
		path 'fastq_data/trim_data'
		mode 'copy'
	}

	trimming_qc1_reports{
		path 'fastq_data/trim_data/qc_reports'
		mode 'copy'
	}
}
