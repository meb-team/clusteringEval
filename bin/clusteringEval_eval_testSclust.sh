set -e 

function usage(){
	echo "usage : bash clusteringEval_eval.sh <input dir> <input prefix> <.taxo.tsv reads file>"
	echo "<input dir> is directory where results from clusteringEval_clustering.sh are stored
	<input prefix> is results prefix from clusteringEval_clustering.sh results.
	<.taxo fastq header> is reads taxonomy provide by frogs_taxo.py" 
}	

function args_gestion(){
	echo -e "\n -- CHECK ARGUMENTS --" 
	verif_dir $indir "[INPUT] Input directory not found /!\ " "[INPUT] Input directory found" 
	verif_file $taxo "[INPUT] Fastq header file $taxo not found /!\ " "[INPUT] Fastq header file $taxo found" 
	for tool in sclust sclust_exact; do 
		verif_dir $indir/$tool "[INPUT] $tool directory not found. Relaunch clusteringEval_clustering.sh or create clusters manually /!\ " "[INPUT] $tool directory found."  
	done 	
}

function compute_evaluation(){
	matrix_file=$1
	echo "* Recall, precision, ARI and distance for $matrix_file..."
	evaluation_param=$($BIN/CValidate.pl --cfile $matrix_file)
	recall=$(echo $evaluation_param | cut -f 1 -d ",") 
	precision=$(echo $evaluation_param | cut -f 2 -d ",") 
	ari=$(echo $evaluation_param | cut -f 5 -d ",")   	
	distance=$matrix_file.distance 
	mean_max=$(awk -F "\t" '{S+=$2}END{print S/NR}' $distance)
	mean_mean=$(awk -F "\t" '{S+=$3}END{print S/NR}' $distance)
}	

function cluster_eval(){
	echo -e "\n-- COMPUTE EVALUATION --" 
	cd $indir/sclust
	for id in 95 96 97 98 99 ; do 
		wid=$(($id - 2))
		for qual in 0 0.25 0.5 0.75 1 ; do
			echo -e "\n** sclust clustering id=$id, weak id=$wid, qual=$qual ..." 
			fuzzyout_file=$prefix.sclust.id$id.wid$wid.qual$qual.fuzzyout 
			time_file=$prefix.sclust.id$id.wid$wid.qual$qual.time.txt
			echo "* Number of clusters..."
			total_clusters=$(cut -f 2 $fuzzyout_file | cut -f 1 -d " " | sort -u | wc -l)
			clusters1=$(cut -f 2 $fuzzyout_file | cut -f 1 -d " " | sort | uniq -c | awk '{if ($1>1) print}' | wc -l)
			clusters005=$(cut -f 2 $fuzzyout_file | cut -f 1 -d " " | sort | uniq -c | awk '{if ($1>='$clusters_size_threshold') print}' | wc -l)
			echo "* Time & Memory..." 
			memory=$(grep "Memory" $time_file | cut -f 2 -d " ")
			time=$(grep "Time" $time_file | cut -f 2 -d " ")
			echo "* Compute matrix..." 
			matrix=$prefix.sclust.id$id.wid$wid.qual$qual.otumatrix 
			python3 $BIN/cluster2matrix.py $fuzzyout_file $taxo $clusters_size_threshold
			python3 $BIN/matrix2distance.py $matrix $taxo > $matrix.distance
			compute_evaluation $matrix
			echo -e "sclust\t$prefix\tdefault\t$id\t$qual\t$total_clusters\t$clusters1\t$clusters005\t$recall\t$precision\t$ari\t$time\t$memory\t$mean_mean\t$mean_max" >> $output_file
		done 
	done 
	
	cd $indir/sclust_exact
	for id in 95 96 97 98 99 ; do 
		wid=$(($id - 2))
		for qual in 0 0.25 0.5 0.75 1 ; do
			echo -e "\n** sclust exact clustering id=$id, weak id=$wid, qual=$qual ..." 
			fuzzyout_file=$prefix.sclust.id$id.wid$wid.qual$qual.fuzzyout 
			time_file=$prefix.sclust.id$id.wid$wid.qual$qual.time.txt
			echo "* Number of clusters..."
			total_clusters=$(cut -f 2 $fuzzyout_file | cut -f 1 -d " " | sort -u | wc -l)
			clusters1=$(cut -f 2 $fuzzyout_file | cut -f 1 -d " " | sort | uniq -c | awk '{if ($1>1) print}' | wc -l)
			clusters005=$(cut -f 2 $fuzzyout_file | cut -f 1 -d " " | sort | uniq -c | awk '{if ($1>='$clusters_size_threshold') print}' | wc -l)
			echo "* Time & Memory..." 
			memory=$(grep "Memory" $time_file | cut -f 2 -d " ")
			time=$(grep "Time" $time_file | cut -f 2 -d " ")
			echo "* Compute matrix..." 
			matrix=$prefix.sclust.id$id.wid$wid.qual$qual.otumatrix 
			python3 $BIN/cluster2matrix.py $fuzzyout_file $taxo $clusters_size_threshold
			python3 $BIN/matrix2distance.py $matrix $taxo > $matrix.distance
			compute_evaluation $matrix
			echo -e "sclust\t$prefix\taccurate\t$id\t$qual\t$total_clusters\t$clusters1\t$clusters005\t$recall\t$precision\t$ari\t$time\t$memory\t$mean_mean\t$mean_max" >> $output_file
		done 
	done
}

if [[ $# -ne 3 ]]; then 
	usage 
	exit 1 
fi 

indir=$(readlink -f $1) 
prefix=$2 
taxo=$(readlink -f $3)
BIN=$(echo $0 | rev | cut -f 2- -d "/" | rev)
if [[ $BIN == $0 ]]; then 
	BIN=. 
fi 
BIN=$(readlink -f $BIN) 
source $BIN/common_functions.sh 

args_gestion

output_file=$indir/$prefix.eval.tsv
#output_file_nosingle=$indir/$prefix.nosingle.eval.tsv 
#output_file_005reads=$indir/$prefix.005reads.eval.tsv 
echo -e "tool\tsample\talgo\tthreshold/d\tquality\ttotal_clusters\tclusters size > 1\tclusters_>_0.05%reads\trecall\tprecision\tARI\tTime(s)\tMemory(kb)\tMean mean distance\tMean max distance" > $output_file 
nb_reads=$(($(wc -l $taxo | cut -f 1 -d " ") - 1)) 
clusters_size_threshold=$(echo $nb_reads | awk '{printf("%.0f",($1*0.05)/100)}') 
cluster_eval
