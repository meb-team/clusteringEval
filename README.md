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

### References 
* Escudié, F., Auer, L., Bernard, M., Mariadassou, M., Cauquil, L., Vidal, K., ... & Pascal, G. (2017). *FROGS: find, rapidly, OTUs with galaxy solution.* Bioinformatics, 34(8), 1287-1294.
* James, B. T., Luczak, B. B., & Girgis, H. Z. (2018). *MeShClust: an intelligent tool for clustering DNA sequences.* Nucleic acids research.
* Li, W., & Godzik, A. (2006). *Cd-hit: a fast program for clustering and comparing large sets of protein or nucleotide sequences.* Bioinformatics, 22(13), 1658-1659.  
* Mahé, F., Rognes, T., Quince, C., de Vargas, C., & Dunthorn, M. (2014). *Swarm: robust and fast clustering method for amplicon-based studies.* PeerJ, 2, e593.  
* Rognes, T., Flouri, T., Nichols, B., Quince, C., & Mahé, F. (2016). *VSEARCH: a versatile open source tool for metagenomics.* PeerJ, 4, e2584.  
* Zou, Q., Lin, G., Jiang, X., Liu, X., & Zeng, X. (2018). *Sequence clustering in bioinformatics: an empirical study*. Briefings in bioinformatics. 





 
