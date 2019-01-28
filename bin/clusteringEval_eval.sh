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
	for tool in cdhit meshclust sclust sumaclust swarm vsearch; do 
		verif_dir $indir/$tool "[INPUT] $tool directory not found. Relaunch clusteringEval_clustering.sh or create clusters manually /!\ " "[INPUT] $tool directory found."  
	done 	
}

function compute_evaluation(){
	matrix_prefix=$1
	for m in otumatrix; do
		matrix_file=$matrix_prefix.$m
		echo "* Recall, precision and ARI for $m..."
		evaluation_param=$($BIN/CValidate.pl --cfile $matrix_file)
		recall=$(echo $evaluation_param | cut -f 1 -d ",") 
		precision=$(echo $evaluation_param | cut -f 2 -d ",") 
		ari=$(echo $evaluation_param | cut -f 5 -d ",") 
	done  	
}	

function cluster_eval(){
	echo -e "\n-- COMPUTE EVALUATION --" 
	cd $indir/swarm 
	for d in 1 2 3; do 
		id=$((100 - $d)) 
		echo -e "\n** swarm clustering d=$d..." 
		uc_file=$prefix.swarm.d$d.uc
		if [[ -f $uc_file ]]; then 
			echo "* Number of clusters..."
			total_clusters=$(awk '{if ($1 == "C") print}' $uc_file | wc -l) 
			singletons=$(awk '{if ($1 == "C") print}' $uc_file | awk '{if ($3 == 1) print}' | wc -l)
			pairs=$(awk '{if ($1 == "C") print}' $uc_file | awk '{if ($3 == 2) print}' | wc -l)
			echo "* Compute matrix..." 
			python3 $BIN/cluster2matrix.py $uc_file $taxo 
			compute_evaluation $prefix.swarm.d$d
			echo -e "swarm\t$prefix\tdefault\t$id\t$total_clusters\t$singletons\t$pairs\t$recall\t$precision\t$ari" >> $output_file 
		else 
			echo "[WARNING] $uc_file doesn't exists."
		fi 		
	done 
	 
	cd $indir/vsearch 
	for id in 97 98 99; do 
		echo -e "\n** vsearch clustering id=$id..."
		uc_file=$prefix.vsearch.id$id.uc 
		uc_acc_file=$prefix.vsearch.accurate.id$id.uc
		if [[ -f $uc_file ]]; then 
			echo "* Number of clusters..." 
			total_clusters=$(awk '{if ($1 == "C") print}' $uc_file | wc -l) 
			singletons=$(awk '{if ($1 == "C") print}' $uc_file | awk '{if ($3 == 1) print}' | wc -l)
			pairs=$(awk '{if ($1 == "C") print}' $uc_file | awk '{if ($3 == 2) print}' | wc -l)
			echo "* Compute matrix..." 
			python3 $BIN/cluster2matrix.py $uc_file $taxo 
			compute_evaluation $prefix.vsearch.id$id 
			echo -e "vsearch\t$prefix\tdefault\t$id\t$total_clusters\t$singletons\t$pairs\t$recall\t$precision\t$ari" >> $output_file 
		else 
			echo "[WARNING] $uc_file doesn't exists."
		fi 
		if [[ -f $uc_acc_file ]]; then 
			echo "* Number of clusters (accurate)..." 
			total_clusters=$(awk '{if ($1 == "C") print}' $uc_acc_file | wc -l) 
			singletons=$(awk '{if ($1 == "C") print}' $uc_acc_file | awk '{if ($3 == 1) print}' | wc -l)
			pairs=$(awk '{if ($1 == "C") print}' $uc_acc_file | awk '{if ($3 == 2) print}' | wc -l)
			echo "* Compute matrix (accurate)..." 
			python3 $BIN/cluster2matrix.py $uc_acc_file $taxo 
			compute_evaluation $prefix.vsearch.accurate.id$id 
			echo -e "vsearch\t$prefix\taccurate\t$id\t$total_clusters\t$singletons\t$pairs\t$recall\t$precision\t$ari" >> $output_file 
		else 
			echo "[WARNING] $uc_acc_file doesn't exists."
		fi 
		
	done 
	
	
	cd $indir/sclust 
	for id in 97 98 99; do 
		for qual in 0; do
			wid=$(($id - 2)) 
			echo -e "\n** sclust clustering id=$id, weak id=$wid, qual=$qual ..." 
			fuzzyout_file=$prefix.sclust.id$id.wid$wid.qual$qual.fuzzyout 
			fuzzyout_acc_file=$prefix.sclust.accurate.id$id.wid$wid.qual$qual.fuzzyout 
			if [[ -f $fuzzyout_file ]]; then 
				echo "* Number of clusters..."
				total_clusters=$(cut -f 2 $fuzzyout_file | cut -f 1 -d " " | sort -u | wc -l)
				singletons=$(cut -f 2 $fuzzyout_file | cut -f 1 -d " " | sort | uniq -c | awk '{if ($1==1) print}' | wc -l)
				pairs=$(cut -f 2 $fuzzyout_file | cut -f 1 -d " " | sort | uniq -c | awk '{if ($1==2) print}' | wc -l)
				echo "* Compute matrix..." 
				python3 $BIN/cluster2matrix.py $fuzzyout_file $taxo 
				compute_evaluation $prefix.sclust.id$id.wid$wid.qual$qual
				echo -e "sclust\t$prefix\tdefault\t$id\t$total_clusters\t$singletons\t$pairs\t$recall\t$precision\t$ari" >> $output_file
			else 
				echo "[WARNING] $fuzzyout_file doesn't exists/"
			fi 	 
			if [[ -f $fuzzyout_acc_file ]]; then 
				echo "* Number of clusters (accurate)..."
				total_clusters=$(cut -f 2 $fuzzyout_acc_file | cut -f 1 -d " " | sort -u | wc -l)
				singletons=$(cut -f 2 $fuzzyout_acc_file | cut -f 1 -d " " | sort | uniq -c | awk '{if ($1==1) print}' | wc -l)
				pairs=$(cut -f 2 $fuzzyout_acc_file | cut -f 1 -d " " | sort | uniq -c | awk '{if ($1==2) print}' | wc -l)
				echo "* Compute matrix (accurate)..." 
				python3 $BIN/cluster2matrix.py $fuzzyout_acc_file $taxo 
				compute_evaluation $prefix.sclust.accurate.id$id.wid$wid.qual$qual
				echo -e "sclust\t$prefix\taccurate\t$id\t$total_clusters\t$singletons\t$pairs\t$recall\t$precision\t$ari" >> $output_file
			else 
				echo "[WARNING] $fuzzyout_acc_file doesn't exists/"
			fi 	 
		done	
	done  
	
	cd $indir/sumaclust 
	for id in 97 98 99; do 
		echo -e "\n** sumaclust clustering id=$id..." 
		otumap_file=$prefix.sumaclust.id$id.otumap 
		otumap_acc_file=$prefix.sumaclust.accurate.id$id.otumap 
		if [[ -f $otumap_file ]]; then 
			echo "* Number of clusters..."
			treatment=$(python3 $BIN/treat_otumap.py $otumap_file) 
			total_clusters=$(echo $treatment | cut -f 1 -d " ") 
			singletons=$(echo $treatment | cut -f 2 -d " ") 
			pairs=$(echo $treatment | cut -f 3 -d " ") 
			echo "* Compute matrix..." 
			python3 $BIN/cluster2matrix.py $otumap_file $taxo 
			compute_evaluation $prefix.sumaclust.id$id
			echo -e "sumaclust\t$prefix\tdefault\t$id\t$total_clusters\t$singletons\t$pairs\t$recall\t$precision\t$ari" >> $output_file
		else 
			echo "[WARNING] $otumap_file doesn't exists."
		fi	
		if [[ -f $otumap_acc_file ]]; then 
			echo "* Number of clusters (accurate)..."
			treatment=$(python3 $BIN/treat_otumap.py $otumap_acc_file) 
			total_clusters=$(echo $treatment | cut -f 1 -d " ") 
			singletons=$(echo $treatment | cut -f 2 -d " ") 
			pairs=$(echo $treatment | cut -f 3 -d " ") 
			echo "* Compute matrix (accurate)..." 
			python3 $BIN/cluster2matrix.py $otumap_acc_file $taxo 
			compute_evaluation $prefix.sumaclust.accurate.id$id
			echo -e "sumaclust\t$prefix\taccurate\t$id\t$total_clusters\t$singletons\t$pairs\t$recall\t$precision\t$ari" >> $output_file
		else 
			echo "[WARNING] $otumap_acc_file doesn't exists."
		fi	
	done 
	
	for tool in cdhit meshclust; do  
		for id in 97 98 99; do 
			echo -e "\n** $tool clustering id=$id..." 
			cd $indir/$tool 
			clstr_file=$prefix.$tool.id$id.clstr 
			clstr_acc_file=$prefix.$tool.accurate.id$id.clstr 
			if [[ -f $clstr_file ]]; then 
				echo "* Number of clusters..."
				treatment=$(python3 $BIN/treat_clstr.py $clstr_file) 
				total_clusters=$(echo $treatment | cut -f 1 -d " ") 
				singletons=$(echo $treatment | cut -f 2 -d " ") 
				pairs=$(echo $treatment | cut -f 3 -d " ") 
				echo "* Compute matrix..." 
				python3 $BIN/cluster2matrix.py $clstr_file $taxo 
				compute_evaluation $prefix.$tool.id$id
				echo -e "$tool\t$prefix\tdefault\t$id\t$total_clusters\t$singletons\t$pairs\t$recall\t$precision\t$ari" >> $output_file
			else
				echo "[WARNING] $clstr_file doesn't exists."  
			fi 
			if [[ -f $clstr_acc_file ]]; then 
				echo "* Number of clusters (accurate)..."
				treatment=$(python3 $BIN/treat_clstr.py $clstr_acc_file) 
				total_clusters=$(echo $treatment | cut -f 1 -d " ") 
				singletons=$(echo $treatment | cut -f 2 -d " ") 
				pairs=$(echo $treatment | cut -f 3 -d " ") 
				echo "* Compute matrix (accurate)..." 
				python3 $BIN/cluster2matrix.py $clstr_acc_file $taxo 
				compute_evaluation $prefix.$tool.accurate.id$id
				echo -e "$tool\t$prefix\taccurate\t$id\t$total_clusters\t$singletons\t$pairs\t$recall\t$precision\t$ari" >> $output_file
			else
				echo "[WARNING] $clstr_acc_file doesn't exists."  
			fi
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
echo -e "tool\tsample\talgo\tthreshold\ttotal_clusters\tsingletons\tpairs\trecall\tprecision\tARI" > $output_file 

cluster_eval
