####################################################################################################
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
	tuple path(${refGenome}), path("${refGenome.simpleName}.fa.*")

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
	tuple path(refGenome), path(refGenome_idx)
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
	${refGenome} \
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

process 

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

	MarkDuplicates(BwaAlignment.out)
	
	publish:
	fastqc1_reports = Fastqc_1.out.html, Fastqc_1.out.zip 
	trimming_reports = Trimming.out.fastp_json, Trimming.out.fastp_html
	markdup_BamFiles = MarkDuplicates.out.markdup_bamFiles
	markdup_BamFiles_metrics = MarkDuplicates.out.markdup_bamFiles_metrics
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
