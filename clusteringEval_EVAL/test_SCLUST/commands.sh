# You have to be in clusteringEval directory 

# 1. Download data and preprocessing 

wget http://frogs.toulouse.inra.fr/data_to_test_frogs/assessment_datasets/datasets_silva/1000sp/dataset_1/V4V4/powerlaw/dataset.tar.gz -O clusteringEval_DATA/dataset.tar.gz 

tar -xvf dataset.tar.gz  

for i in 01 02 03 04 05 06 07 08 09 10; do 
	gunzip clusteringEval_DATA/sample$i\-1000sp-Powerlaw.fastq.gz 
	bash bin/preprocessing.sh clusteringEval_DATA/sample$i\-1000sp-Powerlaw.fastq
done 

bash bin/combined_files.sh clusteringEval_DATA/*-1000sp-*.preprocessing_stats.tsv > clusteringEval_DATA/all_samples-1000sp-Powerlaw.preprocessing_stats.tsv

#2. Clustering and evaluation 

for i in 01 02 03 04 05 06 07 08 09 10; do 
	bash bin/clusteringEval_testSclust.sh clusteringEval_DATA/sample$i\-1000sp-Powerlaw.noChimeras.derep.fasta clusteringEval_DATA/sample$i\-1000sp-Powerlaw.noChimeras.derep.taxo.tsv clusteringEval_TEST_SCLUST
done 

bash bin/combined_files.sh clusteringEval_TEST_SCLUST/sclust/*1000sp*.tsv > clusteringEval_TEST_SCLUST/sclust/all_samples-1000sp-Powerlaw.noChimeras.derep.eval.tsv 
bash bin/combined_files.sh clusteringEval_TEST_SCLUST/sclust_exact/*1000sp*.tsv> clusteringEval_TEST_SCLUST/sclust/all_samples-1000sp-Powerlaw.noChimeras.derep.exact_eval.tsv 
bash bin/combined_files.sh clusteringEval_TEST_SCLUST/sclust/all_samples-1000sp-Powerlaw.noChimeras.derep.eval.tsv clusteringEval_TEST_SCLUST/sclust/all_samples-1000sp-Powerlaw.noChimeras.derep.exact_eval.tsv > testSclust.eval.tsv

#3. Graphical representation 

Rscript bin/clusteringEval_graphs.R


