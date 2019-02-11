# clusteringEval

This repository regroups scripts to compare and evaluate SCLUST 16S RNA clustering tools against 5 others tools : CD-HIT, MESHCLUST, SUMACLUST, SWARM and VSEARCH. 

Tools have been tested with [FROGS](http://frogs.toulouse.inra.fr/) synthetic data sets. 
First, SCLUST has been launched with several parameters to estimate the best. Methods and results are in [results/test_sclust.md](results/test_sclust.md).  
Then, SCLUST has been compared with others tools. Methods and results are in [results/tools_comparison.md](results/tools_comparison.md). 

### Pre-requisites 
You must have clustering tools installed and present in your $PATH. 
* [CD-HIT](http://weizhongli-lab.org/cd-hit/). Alias : `cdhit`
* [MESHCLUST](https://github.com/TulsaBioinformaticsToolsmith/MeShClust). Alias : `meshclust`
* [SCLUST](https://projets.isima.fr/sclust/Expe.html). Alias : `sclust`
* [SUMACLUST](https://git.metabarcoding.org/obitools/sumaclust/wikis/home). Alias : `sumaclust` 
* [SWARM](https://github.com/torognes/swarm). Alias : `swarm`
* [VSEARCH](https://github.com/torognes/vsearch). Alias : `vsearch`

### Pre-treatment 

#### Download dataset 
For this study, one dataset from FROGS has been choosen. 
```
mkdir -p clusteringEval_DATA 

wget http://frogs.toulouse.inra.fr/data_to_test_frogs/assessment_datasets/datasets_silva/1000sp/dataset_1/V4V4/powerlaw/dataset.tar.gz -O clusteringEval_DATA/dataset.tar.gz 

tar -xvf clusteringEval_DATA/dataset.tar.gz -C clusteringEval_DATA
```

#### Delete chimeras, dereplicate and handle taxonomy

```
for i in 01 02 03 04 05 06 07 08 09 10; do 
	gunzip clusteringEval_DATA/sample$i\-1000sp-Powerlaw.fastq.gz 
	bash bin/preprocessing.sh clusteringEval_DATA/sample$i\-1000sp-Powerlaw.fastq
done 

bash bin/combined_files.sh clusteringEval_DATA/sample*-1000sp-*.preprocessing_stats.tsv > clusteringEval_DATA/all_samples-1000sp-Powerlaw.preprocessing_stats.tsv
```

### TEST SCLUST : Clustering and evaluation 

HPC2 running : 
```
for i in 01 02 03 04 05 06 07 08 09 10; do 
	sbatch clusteringEval_testSclust.sh /databis/hilpert/clusteringEval/clusteringEval_DATA/sample$i\-1000sp-Powerlaw.noChimeras.derep.fasta clusteringEval_TEST_SCLUST_s$i
mkdir clusteringEval_TEST_SCLUST 
mkdir clusteringEval_TEST_SCLUST/sclust 
mkdir clusteringEval_TEST_SCLUST/sclust_exact
for type in sclust sclust_exact; do
	mv clusteringEval_TEST_SCLUST_s*/$type/* clusteringEval_TEST_SCLUST/$type 
done	
```

```
mkdir -p clusteringEval_TEST_SCLUST
for i in 01 02 03 04 05 06 07 08 09 10; do 
	bash bin/clusteringEval_testSclust.sh clusteringEval_DATA/sample$i\-1000sp-Powerlaw.noChimeras.derep.fasta clusteringEval_DATA/sample$i\-1000sp-Powerlaw.noChimeras.derep.taxo.tsv clusteringEval_TEST_SCLUST
done 

bash bin/combined_files.sh clusteringEval_TEST_SCLUST/sclust/*1000sp*.tsv > clusteringEval_TEST_SCLUST/sclust/all_samples-1000sp-Powerlaw.noChimeras.derep.eval.tsv 

bash bin/combined_files.sh clusteringEval_TEST_SCLUST/sclust_exact/*1000sp*.tsv> 
clusteringEval_TEST_SCLUST/sclust/all_samples-1000sp-Powerlaw.noChimeras.derep.exact_eval.tsv 

bash bin/combined_files.sh clusteringEval_TEST_SCLUST/sclust/all_samples-1000sp-Powerlaw.noChimeras.derep.eval.tsv clusteringEval_TEST_SCLUST/sclust/all_samples-1000sp-Powerlaw.noChimeras.derep.exact_eval.tsv > clusteringEval_TEST_SCLUST/testSclust.eval.tsv
```

### TEST SCLUST : Graphical representation 
```
mkdir -p clusteringEval_RESULTS 
mkdir -p clusteringEval_RESULTS/test_SCLUST
Rscript bin/clusteringEval_graphs.R
```

### TOOL COMPARISON : Clustering 

To evaluate time and memory, tool comparison has been launched in hpc2 mesocentre. Script are in `/home/cehilper/clustering`. 
```
for i in 01 02 03 04 05 06 07 08 09 10; do 
	sbatch clusteringEval_clustering.sh /databis/hilpert/clusteringEval/clusteringEval_DATA/sample$i\-1000sp-Powerlaw.noChimeras.derep.fasta clusteringEval_TOOL_COMPARISON_s$i 97
done 

mkdir clusteringEval_TOOL_COMPARISON 
for tool in cdhit meshclust sclust sumaclust swarm vsearch; do 
	mkdir clusteringEval_TOOL_COMPARISON/$tool
done 
for tool in cdhit meshclust sclust sumaclust swarm vsearch; do 
	mv clusteringEval_TOOL_COMPARISON_s*/$tool/* clusteringEval_TOOL_COMPARISON/$tool
done 

rm -r clusteringEval_TOOL_COMPARISON_s*
```

It's also possible to run it locally with : 
```
mkdir -p clusteringEval_TOOL_COMPARISON
for i in 01 02 03 04 05 06 07 08 09 10; do 
	bash bin/clusteringEval_clustering.sh clusteringEval_DATA/sample$i\-1000sp-Powerlaw.noChimeras.derep.fasta clusteringEval_TOOL_COMPARISON 97
done 
```


### TOOL COMPARISON : Clustering evaluation 

```
for i in 01 02 03 04 05 06 07 08 09 10; do 
	bash bin/clusteringEval_eval.sh clusteringEval_TOOL_COMPARISON sample$i\-1000sp-Powerlaw.noChimeras.derep clusteringEval_DATA/sample$i\-1000sp-Powerlaw.noChimeras.derep.taxo.tsv 
done 
bash bin/combined_files.sh clusteringEval_TOOL_COMPARISON/sample*-1000sp-Powerlaw.noChimeras.derep.eval.tsv > clusteringEval_TOOL_COMPARISON/all_samples-1000sp-Powerlaw.noChimeras.derep.eval.tsv
bash bin/combined_files.sh clusteringEval_TOOL_COMPARISON/sample*-1000sp-Powerlaw.noChimeras.derep.nosingle.eval.tsv > clusteringEval_TOOL_COMPARISON/all_samples-1000sp-Powerlaw.noChimeras.derep.nosingle.eval.tsv
bash bin/combined_files.sh clusteringEval_TOOL_COMPARISON/sample*-1000sp-Powerlaw.noChimeras.derep.005reads.eval.tsv > clusteringEval_TOOL_COMPARISON/all_samples-1000sp-Powerlaw.noChimeras.derep.005reads.eval.tsv
```

### TOOL COMPARISON : Graphical representation 

```
mkdir -p clusteringEval_RESULTS
mkdir -p clusteringEval_RESULTS/tools_comparison 
Rscript bin/clusteringEval_graphs.R 
Rscript bin/clusteringEval_graphs_type_clusters.R
```

### LAKE DATA 

Clustering has also been done on 16S pyrosequencing data from several lakes. All lakes are pooled in one sample. Data are already cleaned. 

#### Preprocessing : dereplication 

```
vsearch --derep_fulllength FW_newname_30_06_2015.fasta --output clusteringEval_DATA/FW_newname_30_06_2015.derep.fasta --threads 8 --sizeout
```

#### Clustering 

Clustering has been launched in hpc2 mesocentre, with one script per tool to launch clustering in same time. Scripts are in `/home/cehilper/clustering` 
```
for tool in cdhit sclust sumaclust swarm vsearch ; do 
	sbatch clusteringEval_$tool.sh /databis/hilpert/clusteringEval/clusteringEval_DATA/FW_newname_30_06_2015.derep.fasta clusteringEval_LAKE_DATA_$tool 97
done	
```

It's also possible to run it locally with : 
```
bash bin/clusteringEval_clustering.sh clusteringEval_DATA/FW_newname_30_06_2015.derep.fasta clusteringEval_LAKE_DATA 97
```

### References 
* Escudié, F., Auer, L., Bernard, M., Mariadassou, M., Cauquil, L., Vidal, K., ... & Pascal, G. (2017). **FROGS: find, rapidly, OTUs with galaxy solution.** Bioinformatics, 34(8), 1287-1294.
* James, B. T., Luczak, B. B., & Girgis, H. Z. (2018). **MeShClust: an intelligent tool for clustering DNA sequences.** Nucleic acids research.
* Li, W., & Godzik, A. (2006). **Cd-hit: a fast program for clustering and comparing large sets of protein or nucleotide sequences.** Bioinformatics, 22(13), 1658-1659.  
* Mahé, F., Rognes, T., Quince, C., de Vargas, C., & Dunthorn, M. (2014). **Swarm: robust and fast clustering method for amplicon-based studies.** PeerJ, 2, e593.  
* Rognes, T., Flouri, T., Nichols, B., Quince, C., & Mahé, F. (2016). **VSEARCH: a versatile open source tool for metagenomics.** PeerJ, 4, e2584.  
* Zou, Q., Lin, G., Jiang, X., Liu, X., & Zeng, X. (2018). **Sequence clustering in bioinformatics: an empirical study**. Briefings in bioinformatics. 





 
