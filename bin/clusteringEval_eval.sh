set -e 

function usage(){
	echo "usage : bash clusteringEval_eval.sh <input dir> <input prefix>"
	echo "<input dir> is directory where results from clusteringEval_clustering.sh are stored
	<input prefix> is results prefix from clusteringEval_clustering.sh results." 
}	

function args_gestion(){
	echo -e "\n -- CHECK ARGUMENTS --" 
	verif_dir $indir "[INPUT] Input directory not found /!\ " "[INPUT] Input directory found" 
	for tool in cdhit meshclust sclust sumaclust swarm vsearch; do 
		verif_dir $indir/$tool "[INPUT] $tool directory not found. Relaunch clusteringEval_clustering.sh or create clusters manually /!\ " "[INPUT] $tool directory found."  
	done 	
}

function cluster_number(){
	echo -e "\n-- COMPUTE CLUSTER NUMBERS --" 
	echo "* swarm clustering..." 
	cd $indir/swarm 
	for d in 1 3; do 
		uc_file=$prefix.swarm.d$d.uc
		if [[ -f $uc_file ]]; then 
			total_clusters=$(awk '{if ($1 == "C") print}' $uc_file | wc -l) 
			singletons=$(awk '{if ($1 == "C") print}' $uc_file | awk '{if ($3 == 1) print}' | wc -l)
			pairs=$(awk '{if ($1 == "C") print}' $uc_file | awk '{if ($3 == 2) print}' | wc -l)
			echo -e "swarm\t$d\t-\t-\t$total_clusters\t$singletons\t$pairs" >> $output_file 
		else 
			echo "[WARNING] $uc_file doesn't exists."
		fi 		
	done 
	
	echo "* vsearch clustering..." 
	cd $indir/vsearch 
	for id in 97 99; do 
		uc_file=$prefix.vsearch.id$id.uc 
		if [[ -f $uc_file ]]; then 
			total_clusters=$(awk '{if ($1 == "C") print}' $uc_file | wc -l) 
			singletons=$(awk '{if ($1 == "C") print}' $uc_file | awk '{if ($3 == 1) print}' | wc -l)
			pairs=$(awk '{if ($1 == "C") print}' $uc_file | awk '{if ($3 == 2) print}' | wc -l)
			echo -e "vsearch\t$id\t-\t-\t$total_clusters\t$singletons\t$pairs" >> $output_file 
		else 
			echo "[WARNING] $uc_file doesn't exists."
		fi 
		
	done 
	
	echo "* sclust clustering..." 
	cd $indir/sclust 
	for id in 97 99; do 
		wid=$(($id-2)) 
		for qual in 0 0.5 1; do 
			fuzzyout_file=$prefix.sclust.id$id.wid$wid.qual$qual.fuzzyout 
			if [[ -f $fuzzyout_file ]]; then 
				total_clusters=$(cut -f 2 $fuzzyout_file | cut -f 1 -d " " | sort -u | wc -l)
				singletons=$(cut -f 2 $fuzzyout_file | cut -f 1 -d " " | sort | uniq -c | awk '{if ($1==1) print}' | wc -l)
				pairs=$(cut -f 2 $fuzzyout_file | cut -f 1 -d " " | sort | uniq -c | awk '{if ($1==2) print}' | wc -l)
				echo -e "sclust\t$id\t$wid\t$qual\t$total_clusters\t$singletons\t$pairs" >> $output_file
			else 
				echo "[WARNING] $fuzzyout_file doesn't exists/"
			fi 	 
		done  
	done
	
	echo "* sumaclust clustering..." 
	cd $indir/sumaclust 
	for id in 97 99; do 
		otumap_file=$prefix.sumaclust.id$id.otumap 
		if [[ -f $otumap_file ]]; then 
			treatment=$(python3 $BIN/treat_otumap.py $otumap_file) 
			total_clusters=$(echo $treatment | cut -f 1 -d " ") 
			singletons=$(echo $treatment | cut -f 2 -d " ") 
			pairs=$(echo $treatment | cut -f 3 -d " ") 
			echo -e "sumaclust\t$id\t-\t-\t$total_clusters\t$singletons\t$pairs" >> $output_file
		else 
			echo "[WARNING] $otumap_file doesn't exists."
		fi	
	done 
	
	for tool in cdhit meshclust; do  
		echo "* $tool clustering..." 
		for id in 97 99; do 
			cd $indir/$tool 
			clstr_file=$prefix.$tool.id$id.clstr 
			if [[ -f $clstr_file ]]; then 
				treatment=$(python3 $BIN/treat_clstr.py $clstr_file) 
				total_clusters=$(echo $treatment | cut -f 1 -d " ") 
				singletons=$(echo $treatment | cut -f 2 -d " ") 
				pairs=$(echo $treatment | cut -f 3 -d " ") 
				echo -e "$tool\t$id\t-\t-\t$total_clusters\t$singletons\t$pairs" >> $output_file
			else
				echo "[WARNING] $clstr_file doesn't exists."  
			fi 
		done
	done 	
}

if [[ $# -ne 2 ]]; then 
	usage 
	exit 1 
fi 

indir=$(readlink -f $1) 
prefix=$2 
BIN=$(echo $0 | rev | cut -f 2- -d "/" | rev)
if [[ $BIN == $0 ]]; then 
	BIN=. 
fi 
BIN=$(readlink -f $BIN) 
source $BIN/common_functions.sh 

args_gestion

output_file=$indir/clusteringEval_stats.tsv
echo -e "tool\tthreshold/d\tweak_threshold\tquality\ttotal_clusters\tsingletons\tpairs" > $output_file 

cluster_number
