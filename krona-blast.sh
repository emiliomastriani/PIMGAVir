#!/bin/env bash

#Usage krona-blast.sh sequence.fasta KBDir NumbOfCores
#As an example: time ./krona-blast.sh readsNotrRNA_filtered.fq FKDL210225623 24
merged_seq=$1 		#readsNotrRNA_filtered.fasta
KBDir=$2		#Krona-Blast folder
JTrim=$3		#Number of cores to use 

NumOfArgs=3
logfile=$KBDir"/krona-blast.log"
ref_viruses_rep_genomes="/remote-storage/blastdb/ref_viruses_rep_genomes"
blast_out=$KBDir"/blastn.out"
krona_tax_list=$KBDir"/krona_tax.lst"
krona_out=$KBDir"/krona_out.html"
krona_stdout=$KBDir"/krona_stdout"
krona_stderr=$KBDir"/krona_stderr"
krona="/usr/local/bin/ktImportTaxonomy"
merged_seq_aln=$KBDir"/sequences_aln"
merged_seq_aln_tree=$KBDir"/"$merged_seq_aln".tree"

##Checking the number of arguments
if (( $# < $NumOfArgs ))
then
    printf "%b" "Error. Not enough arguments.\n" >&2
    printf "%b" "krona-blast.sh sequences.fasta KBDir NumbOfCores\n" >&2
    exit 1
elif (( $# > $NumOfArgs ))
then
    printf "%b" "Error. Too many arguments.\n" >&2
    printf "%b" "krona-blast.sh sequences.fasta KBDir NumbOfCores c\n" >&2
    exit 2
else
    printf "%b" "Argument count correct. Continuing processing...\n"
fi

#Build Phylo-blast-dir
mkdir $KBDir


echo "Starting process..."

echo "1. Executing blastn operation"
echo -e "$(date) Executing blastn with the following arguments: fasta file is $merged_seq , number of threads is $JTrim" > $logfile 2>&1

blastn -db $ref_viruses_rep_genomes -query $merged_seq -evalue 1e-3 -word_size 11 -outfmt "6 std staxid staxids" -num_threads $JTrim > $blast_out

## Extract NCBI taxon IDs from BLAST output
echo "2. Extract NCBI taxon IDs from BLAST output"
echo -e "$(date) Extract NCBI taxon IDs from BLAST output with the following arguments: blast out file is $blast_out , krona tax list file is $krona_tax_list" >> $logfile 2>&1

awk -F'[;\t]' '!seen[$1,$13]++' ${blast_out} \
| awk '{print $1 "\t" $13}' \
> ${krona_tax_list}

echo "3. Create Krona plot, specifying output filename"
echo -e "$(date) Create Krona plot, specifying output filename with the following arguments: krona out file is $krona_out" >> $logfile 2>&1
## Create Krona plot, specifying output filename
${krona} \
-o ${krona_out} \
${krona_tax_list} \
1> ${krona_stdout} \
2> ${krona_stderr}
