# You have to be in clusteringEval directory 

# 1. Download data and preprocessing 

mkdir -p clusteringEval_DATA

wget http://frogs.toulouse.inra.fr/data_to_test_frogs/assessment_datasets/datasets_silva/1000sp/dataset_1/V4V4/powerlaw/dataset.tar.gz -O clusteringEval_DATA/dataset.tar.gz 

tar -xvf dataset.tar.gz  

for i in 01 02 03 04 05 06 07 08 09 10; do 
	gunzip clusteringEval_DATA/sample$i\-1000sp-Powerlaw.fastq.gz 
	bash bin/preprocessing.sh clusteringEval_DATA/sample$i\-1000sp-Powerlaw.fastq
done 

bash bin/combined_files.sh clusteringEval_DATA/*-1000sp-*.preprocessing_stats.tsv > clusteringEval_DATA/all_samples-1000sp-Powerlaw.preprocessing_stats.tsv

# 2. Clustering 
mkdir -p clusteringEval_TOOL_COMPARISON
for i in 01 02 03 04 05 06 07 08 09 10; do 
	bash bin/clusteringEval_clustering.sh clusteringEval_DATA/sample$i\-1000sp-Powerlaw.noChimeras.derep.fasta clusteringEval_TOOL_COMPARISON
done 

# 3. Evaluation 
for i in 01 02 03 04 05 06 07 08 09 10; do 
	bash bin/clusteringEval_eval.sh clusteringEval_TOOL_COMPARISON sample$i\-1000sp-Powerlaw.noChimeras.derep clusteringEval_DATA/sample$i\-1000sp-Powerlaw.noChimeras.derep.taxo.tsv 
done 
bash bin/combined_files.sh clusteringEval_TOOL_COMPARISON/sample*-1000sp-*.tsv > clusteringEval_TOOL_COMPARISON/all_samples-1000sp-Powerlaw.noChimeras.derep.eval.tsv

#4. Graphical représentation 
mkdir -p clusteringEval_RESULTS
mkdir -p clusteringEval_RESULTS/tools_comparison 
Rscript bin/clusteringEval_graphs.R 
