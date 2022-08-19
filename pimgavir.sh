#!/bin/bash

###################configuration slurm##############################
# PIMGAVir
#SBATCH --job-name=PIMGAVir
#SBATCH --output=pimgavir.%A.out
#SBATCH --error=pimgavir.%A.err
#SBATCH --time=5-23:00:00
#SBATCH --partition=highmemplus
#SBATCH --nodes=1
#SBATCH --mem=128GB
#SBATCH -c 22
# Define email for script execution
#SBATCH --mail-user=XXXXXX@XXX.XXX
# Define type notifications (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-type=ALL
###################################################################

#Usage sbatch pimgavir.sh R1.fastq.gz R2.fastq.gz SampleName NumbOfCores ALL|[--read_based --ass_based --clust_based] [--filter]
#As an example: time pimgavir.sh Pool-3-1_FKDL210225623-1a-AK25938-AK25939_1.clean.fq.gz Pool-3-1_FKDL210225623-1a-AK25938-AK25939_2.clean.fq.gz FKDL210225623 48 --read_based --filter

# Define and create a unique scratch directory for this job
SCRATCH_DIRECTORY=/scratch/${USER}_${SLURM_JOB_ID}

mkdir -p ${SCRATCH_DIRECTORY}/
cd ${SCRATCH_DIRECTORY}/

# Save directory
PATH_TO_SAVE="nas3:/data3/projects/evomics/pimgavir-output"

# Copy to the scratch directory
scp -r nas3:/data3/projects/evomics/pimgavir/ ${SCRATCH_DIRECTORY}

# purge and load the programs
module purge

module load bioinfo/diamond/2.0.11
module load bioinfo/TrimGalore/0.6.5
module load bioinfo/sortmerna/4.3.4
module load bioinfo/kronatools/2.8.1
module load bioinfo/taxonkit/0.9.0 # 0.10.1 in article
module load bioinfo/seqtk/1.3-r106
module load bioinfo/MEGAHIT/1.2.9
module load bioinfo/quast/5.0.2
module load bioinfo/SPAdes/3.15.3 # 3.13.1 in article
module load bioinfo/bowtie2/2.3.4.1 # 2.4.4 in article
module load bioinfo/samtools/1.10
module load bioinfo/pilon/1.23
module load bioinfo/prokka/1.14.6
module load bioinfo/kraken2/2.1.1 # 2.1.2 in article
module load bioinfo/kaiju/1.8.0 # 1.8.2 in article
# module load bioinfo/blast/2.10.0+ # 2.9.0+ in article, blast 2.8.1+ already called by diamond 2.0.11
module load bioinfo/seqkit/2.1.0 # 2.0.0 in article
module load bioinfo/vsearch/2.21.1 # 2.18.0 in article

# Activate conda environment
unset PYTHONPATH
source ${HOME}/miniconda3/etc/profile.d/conda.sh
conda activate pimgavir_env

# Run analysis
cd pimgavir/scripts/

# Purge sortmeRNA_wd kvdb directory
rm -rf sortmeRNA_wd/kvdb/*

##Versioning
version="PIMGAVir V.1.1 -- 20.04.2022"

##Pre-processing parameters
R1=$1 				#R1.fastq.gz
R2=$2 				#R2.fastq.gz
SampleName=$3	#Name associated to the sample
JTrim=$4			#Number of cores to use

##Reads-filtering parameters
filter=${@: -1}	#Filter option (boolean: if specified the filter step will be done, otherwise not)
DiamondDB="../DBs/Diamond-RefSeqProt/refseq_protein_nonredund_diamond.dmnd"
OutDiamondDB="blastx_diamond.m8"
InputDB=$SampleName"_not_rRNA.fq"
PathToRefSeq="../DBs/NCBIRefSeq" # Changed RefSeq in NCBIRefSeq
UnWanted="unwanted.txt"

##Assembly parameters
megahit_contigs_improved="assembly-based/megahit_contigs_improved.fasta"
spades_contigs_improved="assembly-based/spades_contigs_improved.fasta"

##Clustering parameters
OTUDB="clustering-based/otus.fasta"

PassedArgs=$#   							#Number of passed arguments
NumOfArgs=4										#At least 4 parameters are needed
Trimgalore="trim-galore.log"
logfile="pimgavir.log"

#echo "Number of passed args is " $PassedArgs

##Checking for Version option
if (($# == 1))
then
	if [ "$1" == "--version" ]
	then
		echo $version
	else
		echo "Option not valid"
	fi
	exit
fi

##Checking the number of arguments
if (( $# < $NumOfArgs ))
then
    printf "%b" "Error. Not enough arguments.\n" >&2
    printf "%b" "Usage pimgavir.sh R1.fastq.gz R2.fastq.gz SampleName NumbOfCores ALL|[--read_based --ass_based --clust_based] [--filter] \n" >&2
    exit 1
elif (( $# > $NumOfArgs+4 ))
then
    printf "%b" "Error. Too many arguments.\n" >&2
    printf "%b" "Usage pimgavir.sh R1.fastq.gz R2.fastq.gz SampleName NumbOfCores ALL|[--read_based --ass_based --clust_based] [--filter] \n" >&2
    exit 2
else
    if [ -n "$JTrim" ] && [ "$JTrim" -eq "$JTrim" ] 2>/dev/null; then
  	echo "Going to use $JTrim threads"
    	printf "%b" "Argument count correct. Continuing processing..."
    	case $filter in
  		("--filter")    echo "Filtering activated ";;
  		(*) echo "Filtering not activated ";;
  	esac
    else
  	echo "$JTrim is not a valid number of threads. Please insert an integer value"
  	exit 2
    fi
fi

##Checking validity of arguments
#1. Check that input files exist
if [ ! -f "$R1" ] || [ ! -f "$R2" ]; then
	echo "$R1 or $R2 don't exist. Exiting"
	echo -e "$(date) $R1 or $R2 don't exist. Exiting \n" >> $logfile 2>&1
	exit
fi

#2. Check the NumberOfCores is a valid number
if [[ ! $JTrim -gt 00 ]]; then
        echo "Invalid number of cores. Exiting"
	echo -e "$(date) Invalid number of cores. Exiting \n" >> $logfile 2>&1
	exit
fi


#3. Check the methods are valid
args=("$@")

if [ ${args[4]} != "ALL" ];
then
	if [ ${args[$PassedArgs-1]} = "--filter" ];
	then
		count=$((PassedArgs-1))
		#echo "filter yes --> " $count
	else
		count=$PassedArgs
		#echo "filter not --> " $count
	fi
	for ((j=4; j<count; j++))
		do
			case ${args[$j]} in
			("--read_based")
		   		printf "Read-based, valid method found \n"
		   		echo -e "$(date) Read-based, valid method found \n" >> $logfile 2>&1 ;;
		   	("--ass_based")
		   		printf "Assembly-based, valid method found \n"
		   		echo -e "$(date) Assembly-based, valid method found \n" >> $logfile 2>&1 ;;
		   	("--clust_based")
		   		printf "Clustering-based, valid method found \n"
		    		echo -e "$(date) Clustering-based, valid method found \n" >> $logfile 2>&1 ;;
		   	(*)
		   		printf "One of the methods is not valid, please check the correct spelling \n"
		   		echo "One of the following option must be specified: ALL|[--read_based --ass_based --clust_based] "
		   		exit;;
	   		esac
	   	done
else
	printf "ALL option, valid method found \n"
	echo -e "$(date) ALL option, valid method found \n" >> $logfile 2>&1
fi

assembly_func(){
	printf "Calling Assemby-based taxonomy task\n and using $JTrim threads"
	echo -e "$(date) Calling Assembly-based taxonomy task\n" >> $logfile 2>&1
		./assembly.sh $sequence_data assembly-based $JTrim &&
		{
			./taxonomy.sh $megahit_contigs_improved assembly-based-taxonomy $JTrim _MEGAHIT &&
	   		./krona-blast.sh $spades_contigs_improved assembly-based-SPADES-KRONA-BLAST $JTrim
	   		./taxonomy.sh $spades_contigs_improved assembly-based-taxonomy $JTrim  _SPADES &&
	   		./krona-blast.sh $megahit_contigs_improved assembly-based-MEGAHIT-KRONA-BLAST $JTrim
	   	}

}

clustering_func(){
	printf "Calling Clustering-based taxonomy task\n and using $JTrim threads"
	echo -e "$(date) Calling Clustering-based taxonomy task\n" >> $logfile 2>&1
		./clustering.sh $sequence_data clustering-based $JTrim &&
		./taxonomy.sh $OTUDB clustering-based-taxonomy $JTrim _OTU &&
		./krona-blast.sh $OTUDB clustering-based-KRONA-BLAST $JTrim
}

echo "Starting process..."

##Calling pre-process task
NotrRNAReads=$SampleName"_not_rRNA.fq"
#If a not_rRNA.fq file exists from the same sample name, the pre-process task is skipped
if [ -f "$NotrRNAReads" ];
	then
	    	printf 'File %s already exists, skipping pre-process step \n' "$NotrRNAReads"
	    	printf 'File %s already exists, skipping pre-process step \n' "$NotrRNAReads" >> $logfile 2>&1
    	else
	  	echo "Calling pre-process task"
		echo -e "$(date) Calling pre-process task\n" >> $logfile 2>&1
		./pre-process.sh $R1 $R2 $SampleName $JTrim
fi

##Check for reads-filtering task
case $filter in
  	("--filter")
  			if [ -f "$UnWanted" ]; then
				echo -e "$UnWanted file found, moving ahead \n" >> $logfile 2>&1
				echo -e "$UnWanted file found, moving ahead \n"
	  			max=$(($#-1)) ##Setting the current number of arguments
	  			sequence_data="readsNotrRNA_filtered.fq" ##Setting the sequence name to be analyzed
	  			if [ ! -f "$sequence_data" ]; then
		  			echo "Calling reads-filtering task"
					echo -e "$(date) Calling reads-filtering task\n" >> $logfile 2>&1 ##;; ##add or remove ;; when when re-activate or deactivate the filtering step
					./reads-filtering.sh $DiamondDB $JTrim $InputDB $OutDiamondDB $PathToRefSeq $UnWanted
				else
					printf 'File %s already exists, skipping reads-filtering step \n' "$sequence_data"
    					printf 'File %s already exists, skipping reads-filtering step \n' "$sequence_data" >> $logfile 2>&1
    				fi
			else
    				echo -e "$UnWanted file does not exist...terminated \n" >> $logfile 2>&1
    				echo -e "$UnWanted file does not exist...terminated \n"
    				exit 1
 			fi
 			;;
  	(*)
  			max=$# ##Setting the current number of arguments
  			sequence_data=$SampleName"_not_rRNA.fq"
  			echo "Filtering not activated, moving to next task";;
esac

##Start read-based taxonomy
##Statement of arguments
if [ $5 == 'ALL' ];
	then
		JTrim=$((JTrim/3))
		printf "Executing ALL (read-based, assembly-based and clustering-based) taxonomy processes \n"
		echo -e "$(date) Calling ALL (read-based, assembly-based and clustering-based) taxonomy tasks \n" >> $logfile #2>&

		##Call read-based taxonomy classification
		printf "Calling Read-based taxonomy task and using $JTrim threads"
		echo -e "$(date) Calling Read-based taxonomy task \n" >> $logfile 2>&1
		./taxonomy.sh $sequence_data read-based-taxonomy $JTrim _READ & ##It will run in bg mode

		##Call assembly-based taxonomy classification
		assembly_func & ##It will run in bg mode

		##Call clustering-based taxonomy classification
		clustering_func & ##It will run in bg mode

	else
		i=1
		while (( $i < $max-3 ))
		do
			case $5 in
		  	("--read_based")
		    		printf "Executing Read-based taxonomy process \n"
		    		echo -e "$(date) Calling Read-based taxonomy task\n" >> $logfile 2>&1
		    		./taxonomy.sh $sequence_data read-based-taxonomy $JTrim _READ
		    		seqkit fq2fa $sequence_data > readsToblastn.fasta
		    		./krona-blast.sh readsToblastn.fasta read-based-KRONA-BLAST $JTrim
		    		i=$((i + 1 ))
		    		shift 1;;
		    	("--ass_based")
		    		printf "Calling the Assembly-based function \n"
		    		echo -e "$(date) Calling the Assembly-based function \n" >> $logfile 2>&1
		    		assembly_func
		    		i=$((i + 1 ))
		    		shift 1;;
		    	("--clust_based")
		    		printf "Calling the Clustering-based function \n"
		    		echo -e "$(date) Calling the Clustering-based function \n" >> $logfile 2>&1
		    		clustering_func
		    		i=$((i + 1 ))
		    		shift 1;;
		    	(*)
		    		echo "One of the following option must be specified: ALL|[--read_based --ass_based --clust_based] "
		    		i=$((i + 1 ))
		    		shift 1;;
		    	esac
		done
fi

# Delete input files and save work

rm -rf $R1
rm -rf $R2
rm *.sh
rm taxonomy.tab
rm concatenate_reads.py
rm README.md
rm ktImportTaxonomy
rm ktImportText
rm -rf KronaTools
rm KronaTools.pm

cd ..

scp -r scripts/ $PATH_TO_SAVE

# Delete scratch

cd /scratch

seff $SLURM_JOB_ID

rm -rf talignani_$SLURM_JOB_ID
