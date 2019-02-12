set -e 

function usage(){
	echo "usage : bash clusteringEval_eval.sh <input dir> <input prefix> <nb reads>"
	echo "<input dir> is directory where results from clusteringEval_clustering.sh are stored
	<input prefix> is results prefix from clusteringEval_clustering.sh results.
	<nb reads> is the number of reads before clustering" 
}	

function args_gestion(){
	echo -e "\n -- CHECK ARGUMENTS --" 
	verif_dir $indir "[INPUT] Input directory not found /!\ " "[INPUT] Input directory found" 
	for tool in cdhit meshclust sclust sumaclust swarm vsearch; do 
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
	id=95
	d=5
	for tool in cdhit meshclust; do  
		echo -e "\n** $tool clustering id=$id..." 
		cd $indir/$tool 
		clstr_file=$prefix.$tool.id$id.clstr 
		time_file=$prefix.$tool.id$id.time.txt
		if [[ -f $clstr_file ]]; then 
			echo "* Number of clusters..."
			treatment=$(python3 $BIN/treat_clstr.py $clstr_file $clusters_size_threshold) 
			total_clusters=$(echo $treatment | cut -f 1 -d " ") 
			singletons=$(echo $treatment | cut -f 2 -d " ") 
			clusters1=$(($total_clusters - $singletons)) 
			clusters005=$(echo $treatment | cut -f 4 -d " ") 
			echo "* Time & Memory..." 
			memory=$(grep "Memory" $time_file | cut -f 2 -d " ")
			time=$(grep "Time" $time_file | cut -f 2 -d " ")
			echo -e "$tool\t$prefix\t$id\t$total_clusters\t$clusters1\t$clusters005\t$time\t$memory" >>$output_file
		else
			echo "[WARNING] $clstr_file doesn't exists."  
		fi 
	done
	
	cd $indir/sclust
	wid=93
	qual=0
	echo -e "\n** sclust clustering id=$id, weak id=$wid, qual=$qual ..." 
	fuzzyout_file=$prefix.sclust.id$id.wid$wid.qual$qual.fuzzyout 
	time_file=$prefix.sclust.id$id.wid$wid.qual$qual.time.txt
	if [[ -f $fuzzyout_file ]]; then 
		echo "* Number of clusters..."
		total_clusters=$(cut -f 2 $fuzzyout_file | cut -f 1 -d " " | sort -u | wc -l)
		clusters1=$(cut -f 2 $fuzzyout_file | cut -f 1 -d " " | sort | uniq -c | awk '{if ($1>1) print}' | wc -l)
		clusters005=$(cut -f 2 $fuzzyout_file | cut -f 1 -d " " | sort | uniq -c | awk '{if ($1>='$clusters_size_threshold') print}' | wc -l)
		echo "* Time & Memory..." 
		memory=$(grep "Memory" $time_file | cut -f 2 -d " ")
		time=$(grep "Time" $time_file | cut -f 2 -d " ")
		echo -e "sclust\t$prefix\t$id\t$total_clusters\t$clusters1\t$clusters005\t$time\t$memory" >>$output_file
	else
		echo "[WARNING] $fuzzyout_file doesn't exists" 
	fi	
			
	cd $indir/sumaclust 
	echo -e "\n** sumaclust clustering id=$id..." 
	otumap_file=$prefix.sumaclust.id$id.otumap 
	otumap_acc_file=$prefix.sumaclust.accurate.id$id.otumap 
	time_file=$prefix.sumaclust.id$id.time.txt 
	if [[ -f $otumap_file ]]; then 
		echo "* Number of clusters..."
		treatment=$(python3 $BIN/treat_otumap.py $otumap_file $clusters_size_threshold) 
		total_clusters=$(echo $treatment | cut -f 1 -d " ") 
		clusters1=$(($total_clusters - $singletons)) 
		clusters005=$(echo $treatment | cut -f 4 -d " ") 
		echo "* Time & Memory..." 
		memory=$(grep "Memory" $time_file | cut -f 2 -d " ")
		time=$(grep "Time" $time_file | cut -f 2 -d " ")
		echo -e "sumaclust\t$prefix\t$id\t$total_clusters\t$clusters1\t$clusters005\t$time\t$memory" >>$output_file
	else 
		echo "[WARNING] $otumap_file doesn't exists" 
	fi
	
	cd $indir/swarm 
	echo -e "\n** swarm clustering d=$d..." 
	uc_file=$prefix.swarm.d$d.uc
	time_file=$prefix.swarm.d$d.time.txt
	if [[ -f $uc_file ]]; then 
		echo "* Number of clusters..."
		total_clusters=$(awk '{if ($1 == "C") print}' $uc_file | wc -l) 
		clusters1=$(awk '{if ($1 == "C")print}' $uc_file | awk '{if ($3 > 1) print}' | wc -l) 
		clusters005=$(awk '{if ($1 == "C")print}' $uc_file | awk '{if ($3 >= '$clusters_size_threshold') print}' | wc -l) 
		echo "* Time & Memory..." 
		memory=$(grep "Memory" $time_file | cut -f 2 -d " ")
		time=$(grep "Time" $time_file | cut -f 2 -d " ")
		echo -e "swarm\t$prefix\t$d\t$total_clusters\t$clusters1\t$clusters005\t$time\t$memory" >>$output_file
	else 
		echo "[WARNING] $uc_file doesn't exists"
	fi	
	
	cd $indir/vsearch 
	echo -e "\n** vsearch clustering id=$id..."
	uc_file=$prefix.vsearch.id$id.uc 
	time_file=$prefix.vsearch.id$id.time.txt
	if [[ -f $uc_file ]]; then 
		echo "* Number of clusters..." 
		total_clusters=$(awk '{if ($1 == "C") print}' $uc_file | wc -l) 
		clusters1=$(awk '{if ($1 == "C")print}' $uc_file | awk '{if ($3 > 1) print}' | wc -l) 
		clusters005=$(awk '{if ($1 == "C")print}' $uc_file | awk '{if ($3 >= '$clusters_size_threshold') print}' | wc -l) 
		echo "* Time & Memory..." 
		memory=$(grep "Memory" $time_file | cut -f 2 -d " ")
		time=$(grep "Time" $time_file | cut -f 2 -d " ")
		echo "* Compute matrix..." 
		echo -e "vsearch\t$prefix\t$id\t$total_clusters\t$clusters1\t$clusters005\t$time\t$memory" >>$output_file
	else
		echo "[WARNING] $uc_file doesn't exists"
	fi 			
}

if [[ $# -ne 3 ]]; then 
	usage 
	exit 1 
fi 

indir=$(readlink -f $1) 
prefix=$2 
nb_reads=$3
BIN=$(echo $0 | rev | cut -f 2- -d "/" | rev)
if [[ $BIN == $0 ]]; then 
	BIN=. 
fi 
BIN=$(readlink -f $BIN) 
source $BIN/common_functions.sh 

args_gestion

output_file=$indir/$prefix.eval.tsv
echo -e "tool\tsample\tthreshold/d\tnumber_clusters\tclusters size > 1\tclusters size > 0.005% of reads\tTime\tMemory" > $output_file
clusters_size_threshold=$(echo $nb_reads | awk '{printf("%.0f",($1*0.005)/100)}') 
cluster_eval
