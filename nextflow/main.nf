####################################################################################################
Aquí va en canal y los parámetros. Aún no se como configurarlos, entonces comenzaré con los procesos.
#####################################################################################################

params{
		
}

process fastqc_1 {
	input:
	val raw_read

	output:
	path '*.html', emit: html
	path '*.zip', emit: zip	

	script:
	"""
	module load fastqc/0.12.1
	fastqc ${raw_read} -o 
	"""
}

workflow {

	main:
	raw_reads = channel.fromPath(rawreads_dir.input)
		raw_reads.map {rawReadsFile ->
			def (patient, replicate) = rawReadsFile.simpleName.tokenize('_')
			[
				[
					id: patient.replace('P', ''),
					replicate: replicate
				],
				rawReadsFile
			]
		}

	first_qc(raw_reads)
	
	publish:
	fastqc_1_output = first_qc.out.html, first_qc.out.zip
}

output {
	fastqc_1_output{
		path 'fastq_data/raw_reads/qc_reports'
		mode 'copy'
	}
}
