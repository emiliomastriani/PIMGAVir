![Screen Shot 2022-04-29 at 11 15 08 AM](https://user-images.githubusercontent.com/65239532/165880242-41eaeff5-dca7-4387-91b6-19e4b2dfdfa5.png)


PIpeline for MetaGenomic Analysis of Viruses

The main goal of the PIMGAVir pipeline is to provide the user with a preliminary taxonomic classification of the data to be analyzed. In literature, three are the more used methods to this scope: reads-based, assembly-based, and clustering-based. PIMGAVir pipeline gives the user the opportunity to analyze the data using one, more, or all the strategies in parallel.

PIMGAVir runs the method of investigation chosen, which will perform the next steps:
1. Read_based will make the taxonomic classification starting from the file obtained by the pre-process/reads_filtering task
2. Ass_based, moving from the file obtained by the pre-process/reads_filtering task, will make the taxonomic classification
3. Clust_based will perform the clustering of the reads gained from the pre-process/reads_filtering task, create the phylogenetic tree and make the taxonomic classification

Note that the user can run the pimgavir.sh script with more than one “strategy” option at the same time. 

For example, the following command
 
  pimgavir.sh R1.fq R2.fq SampleName 24 --read_based --ss_based --filter

will run the pipeline to execute both the strategies, —read_based and —ass_based. 

Refer to [PIMGAVir_Installation_Manual.pdf](https://github.com/emiliomastriani/PIMGAVir/blob/main/PIMGAVir_Installation_Manual.pdf) for a complete guide on configuring and installing PIMGAVir.

Refer to [PIMGAVir_User_Manual.pdf](https://github.com/emiliomastriani/PIMGAVir/files/8588601/PIMGAVir_User_Manual.pdf) for a quick use of PIMGAVir. 

Refer to [PIMGAVir_SYA.pdf](https://github.com/emiliomastriani/PIMGAVir/blob/main/PIMGAVir-Pipeline_V1.1.pdf) for a more detailed description of PIMGAVir infrastracture.

[Table n1.](https://github.com/emiliomastriani/PIMGAVir/blob/main/Table1.png) and [Table n2.](https://github.com/emiliomastriani/PIMGAVir/blob/main/Table2.png) report the list of packages needed to install both PIMGAVir and Vir-MinION.

Refer to [PIMGAVIR-CAMISIM.txt](https://github.com/emiliomastriani/PIMGAVir/files/8736295/PIMGAVIR-CAMISIM.txt) for generating synthetic data using CAMISIM and run PIMGAVir using it. If you prefer to use synthetic data used during the PIMGAVir test, download the following file SyntheticData_PIMGAVir.tgz [https://github.com/emiliomastriani/PIMGAVir/blob/main/SyntheticData_PIMGAVir.tgz]

Refer to [CreateDBs.txt](https://github.com/emiliomastriani/PIMGAVir/files/8736791/CreateDBs.txt) for a step-by-step guide on installing and configuring the DBs need by PIMGAVir

Please, refer to the manuscript "Mastriani E, Bienes KM, Wong G, Berthet N. PIMGAVir and Vir-MinION: Two Viral Metagenomic Pipelines for Complete Baseline Analysis of 2nd and 3rd Generation Data. Viruses. 2022 Jun 10;14(6):1260. doi: 10.3390/v14061260. PMID: 35746732; PMCID: PMC9230805." for more information. 
