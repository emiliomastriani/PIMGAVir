#!/usr/bin/bash

file=$1 ##Input file in KrakViral.Krona format [ReadId  TaxId] // TaxId==0 stays for unclassified
tag=$2  ##It can be "f" (family) or "g" (genus)
data_type=$3  ##It specifies the data source (OTU/read/contigs/assemby/etc)

NumOfArgs=3 ##Number of expected arguments
logfile="grouping-reads.log"

##Checking the number of arguments
if (( $# < $NumOfArgs ))
then
    printf "%b" "Error. Not enough arguments.\n" >&2
    printf "%b" "Usage grouping-reads.sh InputFile [--f/--g] \n" >&2
    printf "%b" "InputFile must be in KrakViral.Krona format [ReadId  TaxId] // TaxId==0 stays for unclassified \n" >&2
    printf "%b" "[--f/--g] It can be --f (family) or --g (genus) \n" >&2
    exit 1
elif (( $# > $NumOfArgs ))
then
    printf "%b" "Error. Too many arguments.\n" >&2
    printf "%b" "Usage grouping-reads.sh InputFile [f/g] \n" >&2
    printf "%b" "InputFile must be in KrakViral.Krona format [ReadId  TaxId] // TaxId==0 stays for unclassified \n" >&2
    printf "%b" "[f/g] It can be f (family) or g (genus) \n" >&2
    exit 2
fi

##Check for reads-filtering task
case $tag in
  	("--f")    
  			echo "Grouping the reads belonging to the same family"
			echo -e "$(date) Grouping the reads belonging to the same family \n" >> $logfile 2>&1 ##add or remove ;; when when re-activate or deactivate the filtering step 
			
			if [ ! -d $data_type"/family" ]; 
				then
  					mkdir -p $data_type"/family"
				else
					echo "The folder already exists"
					exit 1
			fi
			
			awk -v var=$data_type '{if ($2 != "0") 
				{
					cmd="echo " $2 " | taxonkit --data-dir /mnt/NTFS/NGS-DBs/RefSeq/ reformat -I 1 -f \"{f}\" "; 
					cmd | getline myinfo ; 
					close(cmd)
					split(myinfo,a," "); 
					#print "1: " a[1], "2: " a[2]; 
					out_file=var"/family/"a[2]
					#print "Output file " out_file
					print $1 " " myinfo >> out_file 
				}
			}' $file ;;
	("--g")    
  			echo "Grouping the reads belonging to the same genus"
			echo -e "$(date) Grouping the reads belonging to the same genus \n" >> $logfile 2>&1 ##add or remove ;; when when re-activate or deactivate the filtering step 
			
			if [ ! -d $data_type"/genus" ]; 
				then
  					mkdir -p $data_type"/genus"
				else
					echo "The folder already exists"
					exit 1
			fi
			
			awk -v var=$data_type '{if ($2 != "0") 
				{
					cmd="echo " $2 " | taxonkit --data-dir /mnt/NTFS/NGS-DBs/RefSeq/ reformat -I 1 -f \"{g}\" "; 
					cmd | getline myinfo ; 
					close(cmd)
					split(myinfo,a," "); 
					#print "1: " a[1], "2: " a[2]; 
					out_file=var"/genus/"a[2]
					#print "Output file " out_file
					print $1 " " myinfo >> out_file 
				}
			}' $file ;;
	
  	(*) 
  			echo "Option not valid";;
esac
 

