####################################################################################################
Aquí va en canal y los parámetros. Aún no se como configurarlos, entonces comenzaré con los procesos.
#####################################################################################################

process first_qc {
	input:

	output:
	

	"""
	
	"""
}

workflow {

	fastqs = channel.fromPath('/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/fastq_data/raw_data/P*')

	first_qc(fastqs)
}
