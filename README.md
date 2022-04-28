![PIMGAVir-Logo](https://user-images.githubusercontent.com/65239532/165729696-852827ba-85a8-4006-8d02-0ad305c23889.png)

PIpeline for MetaGenomic Analysis of Viruses

The main goal of the PIMGAVir pipeline is to provide the user with a preliminary taxonomic classification of the data to be analyzed. In literature, three are the more used methods to this scope: reads-based, assembly-based, and clustering-based. PIMGAVir pipeline gives the user the opportunity to analyze the data using one, more, or all the strategies in parallel.

PIMGAVir runs the method of investigation chosen, which will perform the next steps:
•	Read_based will make the taxonomic classification starting from the file obtained by the pre-process/reads_filtering task
•	Ass_based, moving from the file obtained by the pre-process/reads_filtering task, will make the taxonomic classification
•	Clust_based will perform the clustering of the reads gained from the pre-process/reads_filtering task, create the phylogenetic tree and make the taxonomic classification
Note that the user can run the pimgavir.sh script with more than one “strategy” option at the same time. For example, the command
 
pimgavir.sh R1.fq R2.fq SampleName 24 —read_based —ass_based —filter 

will run the pipeline to execute both the strategies, —read_based and —ass_based. Coming sections describe in detail every module of PIMGAVir.

Refer to [PIMGAVir_Installation_Manual.docx](https://github.com/emiliomastriani/PIMGAVir/files/8581766/PIMGAVir_Installation_Manual.docx) for a complete guide on configuring and install PIMGAVir.

Refer to [PIMGAVir_User_Manual.docx](https://github.com/emiliomastriani/PIMGAVir/files/8581774/PIMGAVir_User_Manual.docx) for a quick use of PIMGAVir

