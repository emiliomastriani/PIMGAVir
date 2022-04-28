#!/bin/bash

#Usage reads-filtering.sh R1.fastq.gz R2.fastq.gz SampleName NumbOfCores
#As an example: time ./pre-process.sh Pool-3-1_FKDL210225623-1a-AK25938-AK25939_1.clean.fq.gz Pool-3-1_FKDL210225623-1a-AK25938-AK25939_2.clean.fq.gz FKDL210225623 24
DiamondDB=$1 		#Path to diamond Db
JTrim=$2 		#Number of threads
InputDB=$3		#fastq file containing notrRNA reads
OutDiamondDB=$4		#fastq file output from blasting diamond
PathToRefSeq=$5		#Path to RefSeq Db
UnWanted=$6		#Name of text file containg UNWANTED kingdonm

logfile="reads-filtering.log"

##Run Diamond blastx for the fastq files against the RefSeq protein DB
echo -e "$(date) Run Diamond blastx for the fastq files against the RefSeq protein DB with the folloing parameters: $DiamondDB $JTrim $InputDB $OutDiamondDB $PathToRefSeq $UnWanted\n"
echo -e "$(date) Run Diamond blastx for the fastq files against the RefSeq protein DB \n" >> $logfile 2>&1
#DiamondDB="/mnt/NTFS/NGS-DBs/Diamond-RefSeqProt/refseq_protein_nonredund_diamond.dmnd"
#OutDiamondDB="blastx_diamond.m8"
TMPDIR="/tmp"
#InputDB=$NotrRNAReads".fq"
diamond blastx \
                    -d $DiamondDB \
                    -p $JTrim \
                    -q $InputDB \
   		    -f 6 qseqid staxids bitscore sseqid pident length mismatch gapopen qstart qend sstart send evalue \
                    -o $OutDiamondDB \
                    -t $TMPDIR \
                    -c 4 \
		    -b 0.77 \
                    -k 1 \
                    -v \
                    --log

##Run Misaele_Filter_Param.sh with the following parameters: blastxDiamondDB PathToRefSeq UnWanted.txt readsNotrRNA.fq
#blastxDiamondDB="blastx_diamond.m8"
#PathToRefSeq="/mnt/NTFS/NGS-DBs/RefSeq"
#UnWanted="unwanted.txt"
#readsNotrRNA=$InputDB
echo -e "$(date) Run Misaele_Filter_Param.sh with the following parameters: \n" >> $logfile 2>&1
echo -e "$(date) $OutDiamondDB $PathToRefSeq $readsNotrRNA \n" >> $logfile 2>&1
Misaele_Filter_Param.sh $OutDiamondDB $PathToRefSeq $UnWanted $InputDB
