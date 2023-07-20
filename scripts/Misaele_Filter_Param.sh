#!/bin/bash

#Usage Misaele_Filter_Param.sh blastxDiamondDB PathToRefSeq UnWanted.txt readsNotrRNA.fq
#blastxDiamondDB, name of the database in m8 format obtained from the diamond blastx task [blastx_diamond.m8]
#PathToRefSeq, path to the location where nodes.dmp and names.dmp [RefSeq] files are saved [/storage/RefSeq]
#UnWanted.txt, name/path of the text file in one column format containing the list of UNWANTED organisms. One organism for every line [Archaea // Bacteria etc]
#readsNotrRNA.fq, name of the database in fq format obtained from the SortMeRNA task containing the NOT RNA sequences [reads_not_rRNA.fq]
#Example: ./Misaele_Filter_Param.sh blastx_diamond.m8 /storage/RefSeq unwanted.txt reads_not_rRNA.fq

blastxDiamondDB=$1 			#blastx_diamond.m8
PathToRefSeq=$2					#/storage/RefSeq
UnWanted=$3							#unwanted.txt
readsNotrRNA=$4					#reads_not_rRNA.fq

logfile="Misaele_Filter_Param.log"

echo -e "$(date) Run Misaele_Filter_Param script: \n" > $logfile 2>&1
##Remove duplicates regarding the 1st (qseqid) column
echo -e "$(date) Remove duplicates regarding the 1st (qseqid) column \n" >> $logfile 2>&1
awk '!a[$1]++ {print $1 "\t" $2}' $blastxDiamondDB > blastx_diamond_NoDup.m8

##Create Krona diagram for statistics
echo -e "$(date) Create Krona diagram for statistics -- No duplicated reads \n" >> $logfile 2>&1
ktImportTaxonomy blastx_diamond_NoDup.m8 -o NoDup.taxonomy.krona.html || exit 76

##Associate the taxonomy name to every line
echo -e "$(date) Associate the taxonomy name to every line \n" >> $logfile 2>&1
echo -e "$(date) Path to RefSeq files: $PathToRefSeq \n" >> $logfile 2>&1
taxonkit --data-dir $PathToRefSeq lineage -i 2 blastx_diamond_NoDup.m8 > blastx_diamond_NoDup_withTaxa.m8 || exit 50

##Filter out against the unwanted list of organisms
echo -e "$(date) Filter out against the unwanted list of organisms \n" >> $logfile 2>&1
echo -e "$(date) Unwanted text file name: $UnWanted \n" >> $logfile 2>&1
if [ -f "$UnWanted" ]; then
	echo -e "$UnWanted file found, moving to grep \n" >> $logfile 2>&1
	grep -v -f $UnWanted blastx_diamond_NoDup_withTaxa.m8 | awk '{print $1}' > blastx_diamond_NoDup_wanted.m8
	grep -v -f $UnWanted blastx_diamond_NoDup_withTaxa.m8 | awk '{print $1 ,"\t", $2}' > blastx_diamond_NoDup_withTaxa_wanted.m8
else
    	echo -e "$UnWanted file does not exist...terminated \n" >> $logfile 2>&1
    	echo -e "$UnWanted file does not exist...terminated \n"
	exit 1
fi

##Create Krona diagram for statistics
echo -e "$(date) Create Krona diagram for statistics -- Only wanted reads \n" >> $logfile 2>&1
ktImportTaxonomy blastx_diamond_NoDup_wanted.m8 -o WantedReads.taxonomy.krona.html || exit 76

##Extract from the fastq file only the reads we will interested to, according to their name/ID
echo -e "$(date) Extract from the fastq file only the reads we will interested to, according to their name/ID \n" >> $logfile 2>&1
echo -e "$(date) Reads NOT rRNA file name: $readsNotrRNA \n" >> $logfile 2>&1
seqtk subseq $readsNotrRNA blastx_diamond_NoDup_withTaxa_wanted.m8 > readsNotrRNA_filtered.fq || exit 40
