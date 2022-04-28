##Taxonomy classification
FilteredReads=$1 ##Path to the reads
OutDir=$2	 ##folder to store results
JTrim=$3	 ##Number of threads
Assembler=$4	 ##Assembler name where the contings come from
logfile="taxonomy.log"

NumOfArgs=4

##Checking the number of arguments
##Checking the number of arguments
if (( $# < $NumOfArgs ))
then
    printf "%b" "Error. Not enough arguments.\n" >&2
    printf "%b" "Usage taxonomy.sh reads_to_classify.fasta Out_Folder NumbOfCores assembler_name \n" >&2
    exit 1
elif (( $# > $NumOfArgs ))
then
    printf "%b" "Error. Too many arguments.\n" >&2
    printf "%b" "Usage taxonomy.sh reads_to_classify.fasta Out_Folder NumbOfCores assembler_name \n" >&2
    exit 2
else
    printf "%b" "Argument count correct. Continuing processing...\n"
fi

##Making folder for storing results
mkdir $OutDir


##Taxonomy classification with KRAKEN and SILVA db
#KrakenSilvaDB="/mnt/NTFS/NGS-DBs/KrakenDB"
#krakenSilvaOut=$OutDir"/krakSilva.out"$Assembler
#krakenSilvaClassified=$OutDir"/krakSilva_class.out"$Assembler
#krakenSilvaUnClassified=$OutDir"/krakSilva_unclass.out"$Assembler
#krakenSilvaReport=$OutDir"/krakSilva_report.out"$Assembler

#echo -e "$(date) Run taxonomy classification (Kraken/SILVA) with the following parameters: \n" >> $logfile 2>&1
#echo -e "$(date) $KrakenSilvaDB $FilteredReads $krakenSilvaOut $krakenSilvaClassified $krakenSilvaUnClassified \n" >> $logfile 2>&1
#kraken2 --use-names --db $KrakenSilvaDB $FilteredReads --output $krakenSilvaOut --classified-out $krakenSilvaClassified --unclassified-out $krakenSilvaUnClassified --report $krakenSilvaReport

##Taxonomy classification with KRAKEN and RefSeq viral db
#KrakenViralDB="/mnt/NTFS/NGS-DBs/MiniKraken/minikraken_8GB_20200312" ##Using minikraken 8G, 5%
KrakenViralDB="/DBs/KrakenViral"
krakenViralOut=$OutDir"/krakViral.out"$Assembler
krakenViralClassified=$OutDir"/krakViral_class.out"$Assembler
krakenViralUnClassified=$OutDir"/krakViral_unclass.out"$Assembler
krakenViralReport=$OutDir"/krakViral_report.out"$Assembler

echo -e "$(date) Run taxonomy classification (Kraken/Viral RefSeq) with the following parameters: \n" >> $logfile 2>&1
echo -e "$(date) $KrakenViralDB $FilteredReads $krakenViralOut $krakenViralClassified $krakenViralUnClassified \n" >> $logfile 2>&1
kraken2 --db $KrakenViralDB $FilteredReads --output $krakenViralOut --classified-out $krakenViralClassified --unclassified-out $krakenViralUnClassified --report $krakenViralReport

echo -e "$(date) Create Krona reports in html format: \n" >> $logfile 2>&1
cat $krakenViralOut | cut -f 2,3 > $OutDir"/krakViral.krona"$Assembler
ktImportTaxonomy $OutDir"/krakViral.krona"$Assembler -o $OutDir"/krakViral.krona.html"$Assembler

#cat $OutDir"/krakSilva.out" | cut -f 2,3 > $OutDir"/krakSilva.krona"$Assembler
#ktImportTaxonomy $OutDir"/krakSilva.krona"$Assembler -o $OutDir"/krakSilva.krona.html"$Assembler

echo -e "$(date) Create BRAKEN reports in tab format: \n" >> $logfile 2>&1
#krakenViralBracken="krakenViral_Bracken.out"
#bracken -d $KrakenViralDB -i $krakenViralReport -o $krakenViralBracken

##Taxonomy classification with Kaiju and VIRUSES db
kaijuNodes="/usr/share/NANOPORE-PKGs/kaiju/kaijudb/nodes.dmp"
kaijuNames="/usr/share/NANOPORE-PKGs/kaiju/kaijudb/names.dmp"
kaijuDB="/usr/share/NANOPORE-PKGs/kaiju/kaijudb/viruses/kaiju_db_viruses.fmi"
kaijuOut=$OutDir"/readskaiju.out"$Assembler
kronaOut=$OutDir"/reads_kaiju.krona"$Assembler
kronaHTMLout=$OutDir"/reads_kaiju.kron.html"$Assembler

echo -e "$(date) Run taxonomy classification (Kaiju/Viruses) with the following parameters: \n" >> $logfile 2>&1
echo -e "$(date) $kaijuNodes $kaijuNames $kaijuDB $FilteredReads $kaijuOut $kronaOut $kronaHTMLout \n" >> $logfile 2>&1
kaiju -t $kaijuNodes -f $kaijuDB -i $FilteredReads -o $kaijuOut

echo -e "$(date) Run KaijuToKrona task \n" >> $logfile 2>&1
kaiju2krona -t $kaijuNodes -n $kaijuNames -i $kaijuOut -o $kronaOut -u -v
ktImportText -o $kronaHTMLout $kronaOut
