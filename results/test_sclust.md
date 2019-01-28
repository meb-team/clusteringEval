# Test SCLUST 

Sclust is tested with several parameters and several dataset to determine best parameters to use. 

## Data used 

To test Sclust, data for FROGS's evaluation are used (http://frogs.toulouse.inra.fr/). Synthethic data with powerlaw distribution and 1000 strains are used (http://frogs.toulouse.inra.fr/data_to_test_frogs/assessment_datasets/datasets_silva/1000sp/dataset_1/V4V4/powerlaw/). It's 16S sequencing sequencing simulation (V4 region). Different samples contains same strains but abundance levels varies (for example in sample 1 you will have strain1 in very high abundance and strain2 in low abundance and it will be the opposite in sample 2.). Dataset_1 is selected arbitrarily.

## Methods 

All launch commands are given in clusteringEval_EVAL/test_SCLUST/commands.sh 

### Data preparation 
Sequencing simulation from FROGS contains chimeras reads, identified by the presence of two reference in fastq header. This chimera reads are removed with homemade script `exclude_chimeras.py`. 
Then, reads are deduplicated with `vsearch`.  
Taxonomy is treated with homemade script `frogs_taxo.py` which allows to better presentation of taxonomy present in fastq header. 

### Clustering 
Sclust is launch for each sample (1 to 10), with id from 95 to 99 (steps of 1), weak id 2 below id (for example 97 for id 99 and 95 for id 97), and quality from 0 to 1 with steps of 0.25. 
2 modes are tested : default mode, and accurate mode (much slower) with --maxrejects 0 and --maxaccepts 0 leading to comparisons with all database instead of just selected centroids. 

### Clustering evaluation 
Evaluation is made according to 4 criterias :  
* Precision : represents the ability of tool to reconstruct clusters with only 1 strain inside (avoid over-grouping) 
* Recall : represents the ability of tool to reconstruct clusters with all reads from 1 strain (avoid over-splitting) 
* ARI (Adjusted Rand Index) : summarize precision and recall, by taking acount the random chance to group 2 reads from same strains in same cluster. 
Swarm paper definition : *"adjusted Rand index, which summarizes both precision and recall as the proportion of pairs of amplicons that are placed in the same OTU and are from the same species, but adjusting for the expected proportions through random chance"* 
* Singletons percentage : represents the rate of singletons clusters among all clusters. 

Precision, recall and ARI definitions and computation are the same used in vsearch and swarm paper. 
Script `clusteringEval_testSclust.sh` allows to launch all clustering and evaluation for one sample. 

## Results 

All graphics and raw results are in clusteringEval_EVAL/test_SCLUST. Graphics are obtained with R script `testSclust_graphs.R` (.pdf for graphics and .tsv for raw results). 
Evaluation is focused on ARI because it reflects recall and precision at same time. 

![ARI][clusteringEval_EVAL/ari_boxplot.pdf] 
![singletons][clusteringEval_EVAL/singletons.pdf]

* Sclust performs better with 97% threshold, in accurate or default mode. It's the threshold with less variability and with best ARI values, for each quality parameters.
* Sclust is sensible to inputs. Results shows variability, mostly in default mode with quality over 0. 
* In default mode, quality 0 leads always to better ARI. With quality 0, results looks alike for default or accurate mode. For other qualities, pattern changes with less high ARI and more variability. 
* Singletons percentage rises for 99% threshold, which is an expected pattern. More the threshold is high, more the clusters will be split. However, singletons percentage very slightly increases from 95 to 97 % threshold (MEDIAN : X to X for quality 0) 

**Conclusion** : As accurate mode is much slower than default, we chooses to keep default mode with quality 0 and threshold 97 for evaluation against other tools. 



 
