set -e 

function usage(){ 
	echo "usage : bash clusteringEval_testSclust.sh <fastq|fasta reads file> <.taxo.tsv reads file> <outdir>"  
}

function check_dependencies(){
	echo -e "\n-- CHECK DEPENDENCIES --" 
	
	if [[ $(command -v sclust) ]]; then 
		echo "* SCLUST : installed " 
	else 
		echo "* SCLUST : not installed /!\ "
		quit=1 
	fi 	
	
	if [[ $quit ]]; then 
		echo "[ERROR] Some dependencies are not found. Please install them and/or add them to your \$PATH variable."
		exit 1 
	fi	
}	

function args_gestion(){
	echo -e "\n -- CHECK ARGUMENTS --" 
	verif_file $input "[INPUT] $input not found /!\ " "[INPUT] $input found"
	verif_file $taxo "[INPUT $taxo not found /!\ " "[INPUT] $taxo found" 
	mkdir -p $outdir 
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
	time_file=$matrix_prefix.time.txt
	echo "* Time & Memory..."
	time=$(grep "Time" $time_file)
	memory=$(grep "Memory" $time_file)
}	

function combined_files(){ 
	first_file=$1
	shift 

	tmp=1
	other_file=""
	while [ $1 ]; do
		tail -n +2 $1 > $tmp.tmp
		other_file="$other_file $tmp.tmp" 
		tmp=$(($tmp+1))
		shift 
	done
	cat $first_file $other_file > $output_file
	rm *.tmp 
}	

if [[ $# -ne 3 ]]; then 
	usage 
	exit 1 
fi 


input=$(readlink -f $1)
taxo=$(readlink -f $2) 
outdir=$(readlink -f $3)
output_file=$outdir/testSclust_eval.tsv
BIN=$(echo $0 | rev | cut -f 2- -d "/" | rev)
THREADS=6
if [[ $BIN == $0 ]]; then 
	BIN=. 
fi 
BIN=$(readlink -f $BIN)
source $BIN/common_functions.sh 

check_dependencies
args_gestion

prefix=$(echo $input | rev | cut -f 1 -d "/" | cut -f 2- -d "." | rev) 


echo -e "\n-- SCLUST CLUSTERING --" 
dir=$outdir/sclust
mkdir -p $dir
for id in 95 96 97 98 99; do  
	wid=$(($id - 2)) 
	perc_id=$(echo $id | awk '{print $1/100}') 
	perc_wid=$(echo $wid | awk '{print $1/100}') 
	for qual in 0 0.25 0.5 0.75 1; do
		echo "* Cluster $input with sclust at id $id, weak id $wid and quality $qual..."
		if [[ ! -f $dir/$prefix.sclust.id$id.wid$wid.qual$qual.fuzzyout ]]; then 
			/usr/bin/time -f "Memory %M\nTime %U" -o $dir/$prefix.sclust.id$id.wid$wid.qual$qual.time.txt sclust --cluster_fuzzy $input --id $perc_id --weak_id $perc_wid --quality $qual --threads $THREADS --fuzzyout $dir/$prefix.sclust.id$id.wid$wid.qual$qual.fuzzyout
			mv RepartitionClust.txt $dir/$prefix.sclust.id$id.wid$wid.qual$qual.repartitionClust.txt 
		else 
			echo "Results already exists" 
		fi 
	done 	 	
done 

echo -e "\n -- SCLUST EVALUATION --" 
cd $dir 
output_stats=$prefix.eval.tsv
echo $output_stats 
if [[ ! -f $output_stats ]]; then 
	echo -e "tool\tsample\tthreshold/d\tweak_threshold\tquality\talgo\ttotal_clusters\tsingletons\tpairs\trecall\tprecision\tARI\ttime(s)\tmemory(kb)" > $output_stats
	for id in 95 96 97 98 99; do  
		wid=$(($id - 2)) 
		for qual in 0 0.25 0.5 0.75 1; do
			fuzzyout_file=$prefix.sclust.id$id.wid$wid.qual$qual.fuzzyout
			echo "* Evaluate sclust clustering at id $id, weak id $wid and quality $qual..."
			echo "* Number of clusters..."
			total_clusters=$(cut -f 2 $fuzzyout_file | cut -f 1 -d " " | sort -u | wc -l)
			singletons=$(cut -f 2 $fuzzyout_file | cut -f 1 -d " " | sort | uniq -c | awk '{if ($1==1) print}' | wc -l)
			pairs=$(cut -f 2 $fuzzyout_file | cut -f 1 -d " " | sort | uniq -c | awk '{if ($1==2) print}' | wc -l)
			echo "* Compute matrix..." 
			python3 $BIN/cluster2matrix.py $fuzzyout_file $taxo 
			compute_evaluation $prefix.sclust.id$id.wid$wid.qual$qual
			echo -e "sclust\t$prefix\t$id\t$wid\t$qual\tdefault\t$total_clusters\t$singletons\t$pairs\t$recall\t$precision\t$ari\t$time\t$memory" >> $output_stats
		done 
	done 
fi	

echo -e "\n-- SCLUST EXACT CLUSTERING --" 
dir=$outdir/sclust_exact
mkdir -p $dir
for id in 95 96 97 98 99; do  
	wid=$(($id - 2)) 
	perc_id=$(echo $id | awk '{print $1/100}') 
	perc_wid=$(echo $wid | awk '{print $1/100}') 
	for qual in 0 0.25 0.5 0.75 1; do
		echo "* Cluster $input with sclust at id $id, weak id $wid and quality $qual..."
		if [[ ! -f $dir/$prefix.sclust.id$id.wid$wid.qual$qual.fuzzyout ]]; then 
			/usr/bin/time -f "Memory %M\nTime %U" -o $dir/$prefix.sclust.id$id.wid$wid.qual$qual.time.txt sclust --cluster_fuzzy $input --id $perc_id --weak_id $perc_wid --quality $qual --threads $THREADS --fuzzyout $dir/$prefix.sclust.id$id.wid$wid.qual$qual.fuzzyout --maxaccepts 0 --maxrejects 0
			mv RepartitionClust.txt $dir/$prefix.sclust.id$id.wid$wid.qual$qual.repartitionClust.txt 
		else 
			echo "Results already exists" 
		fi 
	done 	 	
done 

echo -e "\n -- SCLUST EXACT EVALUATION --" 
cd $dir 
output_stats=$prefix.exact_eval.tsv
if [[ ! -f $output_stats ]]; then 
	echo -e "tool\tsample\tthreshold/d\tweak_threshold\tquality\talgo\ttotal_clusters\tsingletons\tpairs\trecall\tprecision\tARI\ttime(s)\tmemory(kb)" > $output_stats
	for id in 95 96 97 98 99; do  
		wid=$(($id - 2)) 
		for qual in 0 0.25 0.5 0.75 1; do
			fuzzyout_file=$prefix.sclust.id$id.wid$wid.qual$qual.fuzzyout
			echo "* Evaluate sclust clustering at id $id, weak id $wid and quality $qual..."
			echo "* Number of clusters..."
			total_clusters=$(cut -f 2 $fuzzyout_file | cut -f 1 -d " " | sort -u | wc -l)
			singletons=$(cut -f 2 $fuzzyout_file | cut -f 1 -d " " | sort | uniq -c | awk '{if ($1==1) print}' | wc -l)
			pairs=$(cut -f 2 $fuzzyout_file | cut -f 1 -d " " | sort | uniq -c | awk '{if ($1==2) print}' | wc -l)
			echo "* Compute matrix..." 
			python3 $BIN/cluster2matrix.py $fuzzyout_file $taxo 
			compute_evaluation $prefix.sclust.id$id.wid$wid.qual$qual
			echo -e "sclust\t$prefix\t$id\t$wid\t$qual\taccurate\t$total_clusters\t$singletons\t$pairs\t$recall\t$precision\t$ari\t$time\t$memory" >> $output_stats
		done 
	done 
fi	




		

