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
	cd $indir/swarm 
	echo -e "\n** swarm clustering..." 
	uc_file=$prefix.swarm.uc
	time_file=$prefix.swarm.time.txt
	if [[ -f $uc_file ]]; then 
		echo "* Number of clusters..."
		total_clusters=$(awk '{if ($1 == "C") print}' $uc_file | wc -l) 
		singletons=$(awk '{if ($1 == "C") print}' $uc_file | awk '{if ($3 == 1) print}' | wc -l)
		pairs=$(awk '{if ($1 == "C") print}' $uc_file | awk '{if ($3 == 2) print}' | wc -l)
		clusters005=$(awk '{if ($1 == "C")print}' $uc_file | awk '{if ($3 >= '$clusters_size_threshold') print}' | wc -l) 
		echo "* Time & Memory..." 
		memory=$(grep "Memory" $time_file | cut -f 2 -d " ")
		time=$(grep "Time" $time_file | cut -f 2 -d " ")
		echo "* Compute matrix..." 
		matrix=$prefix.swarm.otumatrix 
		python3 $BIN/cluster2matrix.py $uc_file $taxo $clusters_size_threshold
		python3 $BIN/matrix2distance.py $matrix $taxo > $matrix.distance
		compute_evaluation $matrix 
		echo -e "swarm\t$prefix\tdefault\t1\t$total_clusters\t$singletons\t$pairs\t$clusters005\t$recall\t$precision\t$ari\t$time\t$memory\t$mean_mean\t$mean_max" >> $output_file
		
		echo "* Compute no singletons..." 
		matrix=$prefix.swarm.nosingletons.otumatrix
		total_clusters=$(awk '{if ($1 == "C") print}' $uc_file | awk '{if ($3 > 1) print}' | wc -l)
		python3 $BIN/matrix2distance.py $matrix $taxo > $matrix.distance
		compute_evaluation $matrix
		echo -e "swarm\t$prefix\tdefault\t1\t$total_clusters\t$recall\t$precision\t$ari\t$mean_mean\t$mean_max" >> $output_file_nosingle
		
		echo "* Compute clusters >= 0.05% of reads..." 
		matrix=$prefix.swarm.005reads.otumatrix
		total_clusters=$clusters005
		python3 $BIN/matrix2distance.py $matrix $taxo > $matrix.distance
		compute_evaluation $matrix
		echo -e "swarm\t$prefix\tdefault\t1\t$total_clusters\t$recall\t$precision\t$ari\t$mean_mean\t$mean_max" >> $output_file_005reads
		
	else 
		echo "[WARNING] $uc_file doesn't exists."
	fi 		
	 
	cd $indir/vsearch 
	id=97
	echo -e "\n** vsearch clustering id=$id..."
	uc_file=$prefix.vsearch.id$id.uc 
	time_file=$prefix.vsearch.id$id.time.txt
	if [[ -f $uc_file ]]; then 
		echo "* Number of clusters..." 
		total_clusters=$(awk '{if ($1 == "C") print}' $uc_file | wc -l) 
		singletons=$(awk '{if ($1 == "C") print}' $uc_file | awk '{if ($3 == 1) print}' | wc -l)
		pairs=$(awk '{if ($1 == "C") print}' $uc_file | awk '{if ($3 == 2) print}' | wc -l)
		clusters005=$(awk '{if ($1 == "C")print}' $uc_file | awk '{if ($3 >= '$clusters_size_threshold') print}' | wc -l) 
		echo "* Time & Memory..." 
		memory=$(grep "Memory" $time_file | cut -f 2 -d " ")
		time=$(grep "Time" $time_file | cut -f 2 -d " ")
		echo "* Compute matrix..." 
		matrix=$prefix.vsearch.id$id.otumatrix 
		python3 $BIN/cluster2matrix.py $uc_file $taxo $clusters_size_threshold
		python3 $BIN/matrix2distance.py $matrix $taxo > $matrix.distance
		compute_evaluation $matrix
		echo -e "vsearch\t$prefix\tdefault\t$id\t$total_clusters\t$singletons\t$pairs\t$clusters005\t$recall\t$precision\t$ari\t$time\t$memory\t$mean_mean\t$mean_max" >> $output_file 
		
		echo "* Compute no singletons..." 
		matrix=$prefix.vsearch.id$id.nosingletons.otumatrix
		total_clusters=$(awk '{if ($1 == "C") print}' $uc_file | awk '{if ($3 > 1) print}' | wc -l)
		python3 $BIN/matrix2distance.py $matrix $taxo > $matrix.distance
		compute_evaluation $matrix
		echo -e "vsearch\t$prefix\tdefault\t$id\t$total_clusters\t$recall\t$precision\t$ari\t$mean_mean\t$mean_max" >> $output_file_nosingle
		
		echo "* Compute clusters >= 0.05% of reads..." 
		matrix=$prefix.vsearch.id$id.005reads.otumatrix
		total_clusters=$clusters005
		python3 $BIN/matrix2distance.py $matrix $taxo > $matrix.distance
		compute_evaluation $matrix
		echo -e "vsearch\t$prefix\tdefault\t$id\t$total_clusters\t$recall\t$precision\t$ari\t$mean_mean\t$mean_max" >> $output_file_005reads
		
	else 
		echo "[WARNING] $uc_file doesn't exists."
	fi 
	
	cd $indir/sclust 
	id=97
	wid=95
	qual=0
	echo -e "\n** sclust clustering id=$id, weak id=$wid, qual=$qual ..." 
	fuzzyout_file=$prefix.sclust.id$id.wid$wid.qual$qual.fuzzyout 
	time_file=$prefix.sclust.id$id.wid$wid.qual$qual.time.txt
	if [[ -f $fuzzyout_file ]]; then 
		echo "* Number of clusters..."
		total_clusters=$(cut -f 2 $fuzzyout_file | cut -f 1 -d " " | sort -u | wc -l)
		singletons=$(cut -f 2 $fuzzyout_file | cut -f 1 -d " " | sort | uniq -c | awk '{if ($1==1) print}' | wc -l)
		pairs=$(cut -f 2 $fuzzyout_file | cut -f 1 -d " " | sort | uniq -c | awk '{if ($1==2) print}' | wc -l)
		clusters005=$(cut -f 2 $fuzzyout_file | cut -f 1 -d " " | sort | uniq -c | awk '{if ($1>='$clusters_size_threshold') print}' | wc -l)
		echo "* Time & Memory..." 
		memory=$(grep "Memory" $time_file | cut -f 2 -d " ")
		time=$(grep "Time" $time_file | cut -f 2 -d " ")
		echo "* Compute matrix..." 
		matrix=$prefix.sclust.id$id.wid$wid.qual$qual.otumatrix 
		python3 $BIN/cluster2matrix.py $fuzzyout_file $taxo $clusters_size_threshold
		python3 $BIN/matrix2distance.py $matrix $taxo > $matrix.distance
		compute_evaluation $matrix
		echo -e "sclust\t$prefix\tdefault\t$id\t$total_clusters\t$singletons\t$pairs\t$clusters005\t$recall\t$precision\t$ari\t$time\t$memory\t$mean_mean\t$mean_max" >> $output_file
		
		echo "* Compute no singletons..." 
		matrix=$prefix.sclust.id$id.wid$wid.qual$qual.nosingletons.otumatrix
		total_clusters=$(cut -f 2 $fuzzyout_file | cut -f 1 -d " " | sort | uniq -c | awk '{if ($1>1) print}' | wc -l)
		python3 $BIN/matrix2distance.py $matrix $taxo > $matrix.distance
		compute_evaluation $matrix
		echo -e "sclust\t$prefix\tdefault\t$id\t$total_clusters\t$recall\t$precision\t$ari\t$mean_mean\t$mean_max" >> $output_file_nosingle
		
		echo "* Compute clusters >= 0.05% of reads..." 
		matrix=$prefix.sclust.id$id.wid$wid.qual$qual.005reads.otumatrix
		total_clusters=$clusters005
		python3 $BIN/matrix2distance.py $matrix $taxo > $matrix.distance
		compute_evaluation $matrix
		echo -e "sclust\t$prefix\tdefault\t$id\t$total_clusters\t$recall\t$precision\t$ari\t$mean_mean\t$mean_max" >> $output_file_005reads
		
	else 
		echo "[WARNING] $fuzzyout_file doesn't exists/"
	fi 	 

	cd $indir/sumaclust 
	id=97
	echo -e "\n** sumaclust clustering id=$id..." 
	otumap_file=$prefix.sumaclust.id$id.otumap 
	otumap_acc_file=$prefix.sumaclust.accurate.id$id.otumap 
	time_file=$prefix.sumaclust.id$id.time.txt 
	if [[ -f $otumap_file ]]; then 
		echo "* Number of clusters..."
		treatment=$(python3 $BIN/treat_otumap.py $otumap_file $clusters_size_threshold) 
		total_clusters=$(echo $treatment | cut -f 1 -d " ") 
		singletons=$(echo $treatment | cut -f 2 -d " ") 
		pairs=$(echo $treatment | cut -f 3 -d " ") 
		clusters005=$(echo $treatment | cut -f 4 -d " ") 
		echo "* Time & Memory..." 
		memory=$(grep "Memory" $time_file | cut -f 2 -d " ")
		time=$(grep "Time" $time_file | cut -f 2 -d " ")
		echo "* Compute matrix..." 
		matrix=$prefix.sumaclust.id$id.otumatrix 
		python3 $BIN/cluster2matrix.py $otumap_file $taxo $clusters_size_threshold
		python3 $BIN/matrix2distance.py $matrix $taxo > $matrix.distance
		compute_evaluation $matrix
		echo -e "sumaclust\t$prefix\tdefault\t$id\t$total_clusters\t$singletons\t$pairs\t$clusters005\t$recall\t$precision\t$ari\t$time\t$memory\t$mean_mean\t$mean_max" >> $output_file
		
		echo "* Compute no singletons..." 
		matrix=$prefix.sumaclust.id$id.nosingletons.otumatrix
		total_clusters=$(($total_clusters - $singletons))
		python3 $BIN/matrix2distance.py $matrix $taxo > $matrix.distance
		compute_evaluation $matrix
		echo -e "sumaclust\t$prefix\tdefault\t$id\t$total_clusters\t$recall\t$precision\t$ari\t$mean_mean\t$mean_max" >> $output_file_nosingle
		
		echo "* Compute clusters >= 0.05% of reads..." 
		matrix=$prefix.sumaclust.id$id.005reads.otumatrix
		total_clusters=$clusters005
		python3 $BIN/matrix2distance.py $matrix $taxo > $matrix.distance
		compute_evaluation $matrix
		echo -e "sumaclust\t$prefix\tdefault\t$id\t$total_clusters\t$recall\t$precision\t$ari\t$mean_mean\t$mean_max" >> $output_file_005reads
		
	else 
		echo "[WARNING] $otumap_file doesn't exists."
	fi	
	
	for tool in cdhit meshclust; do  
		id=97
		echo -e "\n** $tool clustering id=$id..." 
		cd $indir/$tool 
		clstr_file=$prefix.$tool.id$id.clstr 
		time_file=$prefix.$tool.id$id.time.txt
		if [[ -f $clstr_file ]]; then 
			echo "* Number of clusters..."
			treatment=$(python3 $BIN/treat_clstr.py $clstr_file $clusters_size_threshold) 
			total_clusters=$(echo $treatment | cut -f 1 -d " ") 
			singletons=$(echo $treatment | cut -f 2 -d " ") 
			pairs=$(echo $treatment | cut -f 3 -d " ") 
			clusters005=$(echo $treatment | cut -f 4 -d " ") 
			echo "* Time & Memory..." 
			memory=$(grep "Memory" $time_file | cut -f 2 -d " ")
			time=$(grep "Time" $time_file | cut -f 2 -d " ")
			echo "* Compute matrix..." 
			matrix=$prefix.$tool.id$id.otumatrix 
			python3 $BIN/cluster2matrix.py $clstr_file $taxo $clusters_size_threshold
			python3 $BIN/matrix2distance.py $matrix $taxo > $matrix.distance
			compute_evaluation $matrix
			echo -e "$tool\t$prefix\tdefault\t$id\t$total_clusters\t$singletons\t$pairs\t$clusters005\t$recall\t$precision\t$ari\t$time\t$memory\t$mean_mean\t$mean_max" >>$output_file
			
			echo "* Compute no singletons..." 
			matrix=$prefix.$tool.id$id.nosingletons.otumatrix
			total_clusters=$(($total_clusters - $singletons))
			python3 $BIN/matrix2distance.py $matrix $taxo > $matrix.distance
			compute_evaluation $matrix
			echo -e "$tool\t$prefix\tdefault\t$id\t$total_clusters\t$recall\t$precision\t$ari\t$mean_mean\t$mean_max" >> $output_file_nosingle
			
			echo "* Compute clusters >= 0.05% of reads..." 
			matrix=$prefix.$tool.id$id.005reads.otumatrix
			total_clusters=$clusters005
			python3 $BIN/matrix2distance.py $matrix $taxo > $matrix.distance
			compute_evaluation $matrix
			echo -e "$tool\t$prefix\tdefault\t$id\t$total_clusters\t$recall\t$precision\t$ari\t$mean_mean\t$mean_max" >> $output_file_005reads
			
		else
			echo "[WARNING] $clstr_file doesn't exists."  
		fi 
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
output_file_nosingle=$indir/$prefix.nosingle.eval.tsv 
output_file_005reads=$indir/$prefix.005reads.eval.tsv 
echo -e "tool\tsample\talgo\tthreshold/d\ttotal_clusters\tsingletons\tpairs\tclusters_>_0.05%reads\trecall\tprecision\tARI\tTime(s)\tMemory(kb)\tMean mean distance\tMean max distance" > $output_file 
echo -e "tool\tsample\talgo\tthreshold/d\tnumber_clusters\trecall\tprecision\tARI\tMean mean distance\tMean max distance" > $output_file_nosingle 
echo -e "tool\tsample\talgo\tthreshold/d\tnumber_clusters\trecall\tprecision\tARI\tMean mean distance\tMean max distance" > $output_file_005reads
nb_reads=$(($(wc -l $taxo | cut -f 1 -d " ") - 1)) 
clusters_size_threshold=$(echo $nb_reads | awk '{printf("%.0f",($1*0.05)/100)}') 
cluster_eval
