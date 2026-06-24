#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=32G
#SBATCH --array=1-4
#SBATCH --output=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/Add_read_groups_%A_%a.out
#SBATCH --error=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/logs/Add_read_groups_%A_%a.err
#SBATCH --chdir=/mnt/data/cgonzaga/sgamino/Dog_epilepsy_project/output/bam_output

module purge

# Carga tus modulos en la siguiente linea

module load picard/2.6.0
module load samtools/1.22.1

# Your script goes here

Dog_ID="P${SLURM_ARRAY_TASK_ID}"

echo "Procesando la muestra ${Dog_ID} en la tarea ${SLURM_ARRAY_TASK_ID}" 

#Lo pongo ahora porque no sabía que existía la opción -R en bwa -mem. Los read groups son necesarios para introducirlos al pipe de gatk. La info ffue obtenida de las reads crudas.
picard AddOrReplaceReadGroups \
R=/mnt/data/cgonzaga/Data/Dog_genomes/reference/canFam6.fa.gz \
I=${Dog_ID}.alignment.sort.dedup.bam \
O=${Dog_ID}.alignment.sort.dedup.rg.bam \
RGLB=lib1 \
RGPL=illumina \
RGPU=22JCHNLT4.8.${Dog_ID} \
RGSM=${Dog_ID} \
RGID=22JCHNLT4.8

echo "Creando nuevo indice para bam con Read Groups (RG)"

samtools index ${Dog_ID}.alignment.sort.dedup.rg.bam 
