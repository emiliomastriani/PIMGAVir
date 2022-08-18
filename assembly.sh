#!/bin/env bash

#Usage clustering.sh merged_sequences.fastq SampleName NumbOfCores
#As an example: time ./assembly.sh readsNotrRNA_filtered.fq FKDL210225623 24

merged_seq=$1 		#readsNotrRNA_filtered.fq
AssDir=$2		#Assembly folder
JTrim=$3		#Number of cores to use
ConcScript="concatenate_reads.py" #"/usr/share/NGS-PKGs/Concatenate/concatenate_reads.py"

##Versioning
version="PIMGAVir V.1.1 -- 07.03.2022"

NumOfArgs=3
logfile="assembly-based.log"
wd=$merged_seq".split"
megahit_out=$AssDir"/megahit_data"
megahit_quast=$AssDir"/megahit_quast"
spades_out=$AssDir"/spades_data"
spades_quast=$AssDir"/spades_quast"

idx_bowtie=$AssDir"/IDXs"
megahit_contigs_idx="megahit_contigs_idx"
megahit_contigs_bam=$AssDir"/megahit_contigs.bam"
spades_contigs_idx="spades_contigs_idx"
spades_contigs_bam=$AssDir"/spades_contigs.bam"
megahit_contigs_sorted_bam=$AssDir"/megahit_contigs.sorted.bam"
spades_contigs_sorted_bam=$AssDir"/spades_contigs.sorted.bam"
megahit_contigs_improved=$AssDir"/megahit_contigs_improved"
spades_contigs_improved=$AssDir"/spades_contigs_improved"
spades_prokka=$AssDir"/spades_prokka"
megahit_prokka=$AssDir"/megahit_prokka"


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

#Build assembly-dir
mkdir $AssDir

##Checking the number of arguments
if (( $# < $NumOfArgs ))
then
    printf "%b" "Error. Not enough arguments.\n" >&2
    printf "%b" "assembly.sh merged_sequences.fastq SampleName NumbOfCores\n" >&2
    exit 1
elif (( $# > $NumOfArgs ))
then
    printf "%b" "Error. Too many arguments.\n" >&2
    printf "%b" "assembly.sh merged_sequences.fastq SampleName NumbOfCores c\n" >&2
    exit 2
else
    printf "%b" "Argument count correct. Continuing processing...\n"
fi

echo "Starting process..."

echo "1. Executing de-novo Assembly (megahit)"
echo -e "$(date) Executing de-novo assembly by megahit with the following arguments: merged fastq file is $merged_seq" > $logfile 2>&1

#Command to execute
#Assembly using Megahit
megahit -t $JTrim --read $merged_seq --k-list 21,41,61,81,99 --no-mercy --min-count 2 --out-dir $megahit_out

echo "2. Executing de-novo Assembly (spades)"
echo -e "$(date) Executing de-novo assembly by spades with the following arguments: merged fastq file is $merged_seq" >> $logfile 2>&1
#Command to execute
#Assembly using Spades
seqkit split2 -p2 $merged_seq --force
cd $wd
mv *.part_001.* Forward.fq
mv *.part_002.* Reverse.fq

metaspades.py -t $JTrim -1 Forward.fq -2 Reverse.fq  -o ../$spades_out
cd ..

echo "3. Fixing misassemblies (bowtie/samtools/pilon)"
echo "Parameters: $megahit_out/final.contigs.fa $idx_bowtie/$megahit_contigs_idx"
echo -e "$(date) Fixing misassemblies (bowtie/samtools/pilon)" >> $logfile 2>&1
#Command to execute

#Create index files from contigs
mkdir $idx_bowtie
echo -e "$(date) Create index files from contigs [bowtie2-build] from megahit assembly" >> $logfile 2>&1
bowtie2-build $megahit_out/final.contigs.fa $idx_bowtie/$megahit_contigs_idx
echo -e "$(date) Create index files from contigs [bowtie2-build] from spades assembly" >> $logfile 2>&1
bowtie2-build $spades_out/contigs.fasta $idx_bowtie/$spades_contigs_idx

#Create BAM file
echo -e "$(date) Create bam file [bowtie2 -x] from megahit assembly" >> $logfile 2>&1
bowtie2 -x $idx_bowtie/$megahit_contigs_idx -1 $wd/Forward.fq -2 $wd/Reverse.fq -p $JTrim | samtools view -bS -o $megahit_contigs_bam -@ $JTrim
echo -e "$(date) Create bam file [bowtie2 -x] from spades assembly" >> $logfile 2>&1
bowtie2 -x $idx_bowtie/$spades_contigs_idx -1 $wd/Forward.fq -2 $wd/Reverse.fq -p $JTrim | samtools view -bS -o $spades_contigs_bam -@ $JTrim

#Sort bam files
echo -e "$(date) Sort bam file [samtools sort] from megahit assembly" >> $logfile 2>&1
samtools sort $megahit_contigs_bam -o $megahit_contigs_sorted_bam -@ $JTrim
echo -e "$(date) Sort bam file [samtools sort] from spades assembly" >> $logfile 2>&1
samtools sort $spades_contigs_bam -o $spades_contigs_sorted_bam -@ $JTrim

#Index bam files
#NB: in case of ERROR --> maybe files created with $JTrim cause troubles
echo -e "$(date) Indexing bam file [samtools index] from megahit assembly" >> $logfile 2>&1
samtools index $megahit_contigs_sorted_bam -@ $JTrim
echo -e "$(date) Indexing bam file [samtools index] from spades assembly" >> $logfile 2>&1
samtools index $spades_contigs_sorted_bam -@ $JTrim

#Improve contigs.fasta
echo -e "$(date) Improve contigs file [pilon] from megahit contigs" >> $logfile 2>&1
pilon --genome $megahit_out/final.contigs.fa --frags $megahit_contigs_sorted_bam --output $megahit_contigs_improved --threads $JTrim
echo -e "$(date) Improve contigs file [pilon] from spades contigs" >> $logfile 2>&1
pilon --genome $spades_out/contigs.fasta --frags $spades_contigs_sorted_bam --output $spades_contigs_improved --threads $JTrim

echo "4. Executing contigs analysis (quast)"
echo -e "$(date) Executing de-novo assembly by spades with the following arguments: merged fastq file is $merged_seq" >> $logfile 2>&1
#Command to execute
#Using QUAST
quast.py -o $megahit_quast $megahit_contigs_improved".fasta"
quast.py -o $spades_quast $spades_contigs_improved".fasta"

echo "5. Gene annotation using PROKKA"
echo -e "$(date) Gene annotation using PROKKA" >> $logfile 2>&1

#Gene annotation
#Using PROKKA, Viruses genus on Contigs from spades
echo -e "$(date) Gene annotation: Using PROKKA, Viruses genus on Contigs from spades" >> $logfile 2>&1
prokka $spades_contigs_improved".fasta" --usegenus Viruses --out $spades_prokka --centre X --compliant --prefix spades_prokka --force --cpus $JTrim

#Using PROKKA, Viruses genus on Contigs from megahit
echo -e "$(date) Gene annotation: Using PROKKA, Viruses genus on Contigs from megahit" >> $logfile 2>&1
prokka $megahit_contigs_improved".fasta" --usegenus Viruses --out $megahit_prokka --prefix megahit_prokka --force --cpus $JTrim

#Use artemis to visualize the Gene annotation
##For example art $megahit_prokka.gbk
