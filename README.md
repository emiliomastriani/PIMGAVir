![Screen Shot 2022-04-29 at 11 15 08 AM](https://user-images.githubusercontent.com/65239532/165880242-41eaeff5-dca7-4387-91b6-19e4b2dfdfa5.png)

# PIpeline for MetaGenomic Analysis of Viruses #

![Maintener](<https://badgen.net/badge/Maintener/Emilio Mastriani/blue?scale=0.9>)
![Maintener](<https://badgen.net/badge/Maintener/Loïc Talignani/blue?scale=0.9>)
![MacOSX Intel](<https://badgen.net/badge/icon/Hight Sierra (10.13.6) | Catalina (10.15.7) | Big Sure (11.6.3) | Monterey (12.2.0)/E6055C?icon=apple&label&list=|&scale=0.9>)
![GNU/Linux](<https://badgen.net/badge/icon/Bionic Beaver (18.04) | Focal Fossa (20.04) | Jammy Jellyfish (22.04)/772953?icon=https://www.svgrepo.com/show/25424/ubuntu-logo.svg&label&list=|&scale=0.9>)
![Issues closed](<https://badgen.net/badge/Issues closed/0/green?scale=0.9>)
![Issues opened](<https://badgen.net/badge/Issues opened/0/yellow?scale=0.9>)
![Open Source](<https://badgen.net/badge/icon/Open Source/purple?icon=https://upload.wikimedia.org/wikipedia/commons/4/44/Corazón.svg&label&scale=0.9>)
![GNU AGPL v3](<https://badgen.net/badge/Licence/GNU AGPL v3/grey?scale=0.9>)
![Github](<https://badgen.net/badge/icon/Github/blue?icon=github&label&scale=0.9>)
![Bash](<https://badgen.net/badge/icon/Bash 5.2/black?icon=terminal&label&scale=0.9>)
![Python](<https://badgen.net/badge/icon/Python 3.9.5/black?icon=https://upload.wikimedia.org/wikipedia/commons/0/0a/Python.svg&label&scale=0.9>)
![Conda](<https://badgen.net/badge/icon/Conda 4.10.3/black?icon=codacy&label&scale=0.9>)

## ~ ABOUT ~ ##
The main goal of the PIMGAVir pipeline is to provide the user with a preliminary taxonomic classification of the data to be analyzed. In literature, three are the more used methods to this scope: reads-based, assembly-based, and clustering-based. PIMGAVir pipeline gives the user the opportunity to analyze the data using one, more, or all the strategies in parallel.

## Features ##
PIMGAVir runs the method of investigation chosen, which will perform the next steps:
1. Read_based will make the taxonomic classification starting from the file obtained by the pre-process/reads_filtering task
2. Ass_based, moving from the file obtained by the pre-process/reads_filtering task, will make the taxonomic classification
3. Clust_based will perform the clustering of the reads gained from the pre-process/reads_filtering task, create the phylogenetic tree and make the taxonomic classification

Note that the user can run the pimgavir.sh script with more than one “strategy” option at the same time.

For example, the following command

  pimgavir.sh R1.fq R2.fq SampleName 24 --read_based --ass_based --filter

will run the pipeline to execute both the strategies, —read_based and —ass_based.

## Slurm cluster ##
The main script pimgavir.sh is ready for Slurm cluster. If you need to run this pipeline on a local computer, just remove the SLURM CONFIGURATION PART.

## Documentation ##

Refer to [PIMGAVir_User_Manual.pdf](https://github.com/emiliomastriani/PIMGAVir/files/8736813/PIMGAVir_User_Manual.pdf) for a complete guide on configuring and installing PIMGAVir.

Refer to [PIMGAVir_User_Manual.pdf](https://github.com/emiliomastriani/PIMGAVir/files/8588601/PIMGAVir_User_Manual.pdf) for a quick use of PIMGAVir.

Refer to [PIMGAVIR-CAMISIM.txt](https://github.com/emiliomastriani/PIMGAVir/files/8736295/PIMGAVIR-CAMISIM.txt) for generating synthetic data using CAMISIM and run PIMGAVir using it. If you prefer to use synthetic data used during the PIMGAVir test, download the following file SyntheticData_PIMGAVir.tgz :  [Synthetic data](https://github.com/emiliomastriani/PIMGAVir/blob/main/SyntheticData_PIMGAVir.tgz)

Refer to [CreateDBs.txt](https://github.com/emiliomastriani/PIMGAVir/files/8736791/CreateDBs.txt) for a step-by-step guide on installing and configuring the DBs need by PIMGAVir

## Version ##
*PIMGAVir V.1.1 -- 20.04.2022*