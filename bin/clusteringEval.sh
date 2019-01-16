set -e 

function usage(){
	echo "usage : bash clusteringEval.sh" 
}	

function check_dependencies(){
	echo -e "\n-- CHECK DEPENDENCIES --" 

	if [[ $(command -v cd-hit-est) ]]; then 
		echo "* CD-HIT : installed" 
	else 
		echo "* CD-HIT not installed /!\ "
		quit=1  
	fi 
	
	if [[ $(command -v dnaclust) ]]; then 
		echo "* DNACLUST : installed" 
	else 
		echo "* DNACLUST : not installed /!\ " 
		quit=1 
	fi 
	
	if [[ $(command -v meshclust) ]]; then 
		echo "* MESHCLUST : installed" 
	else 
		echo "* MESHCLUST : not installed /!\ " 
		quit=1 
	fi  
	
	if [[ $(command -v sumaclust) ]]; then 
		echo "* SUMACLUST : installed" 
	else 
		echo "* SUMACLUST : not installed /!\ " 
		quit=1 
	fi 
	
	if [[ $(command -v swarm) ]]; then 
		echo "* SWARM : installed" 
	else 
		echo "* SWARM : not installed /!\ " 
		quit=1 
	fi 
	
	if [[ $(command -v usearch) ]]; then 
		echo "* USEARCH : installed" 
	else 
		echo "* USEARCH : not installed /!\ " 
		quit=1 
	fi
	
	if [[ $(command -v vsearch) ]]; then 
		echo "* VSEARCH : installed" 
	else 
		echo "* VSEARCH : not installed /!\ " 
		quit=1 
	fi
	
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

function download_data(){
	echo -e "\n-- DOWNLOAD DATA --" 
	mkdir -p clusteringEval_DATA
	
	echo "* Mock community : even"
	mock_dir=clusteringEval_DATA/mock_community 
	mkdir -p $mock_dir 
	mock_even=$mock_dir/even 
	if [[ ! -f $mock_even.fasta.bz2 ]]; then 
		echo "Downloading..."  
		wget -nv -O $mock_even.fasta.bz2 http://sbr2.sb-roscoff.fr/download/externe/de/fmahe/even.fasta.bz2 
	else 
		echo "Already exists." 
	fi 	
	
	echo "* Mock community : uneven" 
	mock_uneven=$mock_dir/uneven
	if [[ ! -f $mock_uneven.fasta.bz2 ]]; then 
		echo "Downloading..."  
		wget -nv -O $mock_uneven.fasta.bz2 http://sbr2.sb-roscoff.fr/download/externe/de/fmahe/uneven.fasta.bz2 
	else 
		echo "Already exists." 
	fi 
	
}	
		
function derep(){ 
	echo -e "\n-- DEREPLICATION --" 
	
	for M in even uneven; do 
		echo "* Mock community : $M"
		if [[ ! -f $mock_dir/$M.derep.fasta ]]; then  
			echo "Dereplicate..." 
			vsearch --derep_fulllength $mock_dir/$M.fasta.bz2 --output $mock_dir/$M.derep.fasta --sizeout --fasta_width 0 --threads $THREADS --relabel_sha1
		else 
			echo "Already exists." 
		fi 	
	done 	
}

function run_clustering(){
	echo -e "\n-- CLUSTERING --" 
	
	for M in uneven; do
	
		outdir=$RESULTS/mock_community_$M
		mkdir -p $outdir
		
		for rep in $(seq $nb_rep); do  
			for id in 97 99; do 
				mkdir -p $outdir/cdhit 
				id_perc=$(echo $id | awk '{print $1/100}') 
				result=$outdir/cdhit/$M.cdhit.id$id.rep$rep 
				if [[ ! -f $result.clstr ]]; then 
					echo -e "\n* Clustering $M mock community with cd-hit at id $id, REP $rep..." 
					/usr/bin/time -f "TIME:%U\nMEMORY:%M" -o $result.perf.txt cd-hit-est -i $mock_dir/$M.derep.fasta -o $result -c $id_perc -M 0 -T $THREADS
				fi
			
				for tool in vsearch usearch; do 
					mkdir -p $outdir/$tool
					result=$outdir/$tool/$M.$tool.id$id.rep$rep 
					if [[ ! -f $result.uc ]]; then 
						echo -e "\n* Clustering $M mock community with $tool at id $id, REP $rep..." 
						/usr/bin/time -f "TIME:%U\nMEMORY:%M" -o $result.perf.txt $tool --cluster_fast $mock_dir/$M.derep.fasta --id $id_perc --uc $result.uc --threads $THREADS
					fi
				done 
				
				weak_id=$(($id -2)) 
				weak_id_perc=$(echo $weak_id | awk '{print $1/100}') 
				mkdir -p $outdir/sclust 
				for qual in 0 0.5 1; do 
					result=$outdir/sclust/$M.sclust.id$id.wid$weak_id.qual$qual.rep$rep 
					if [[ ! -f $result.fuzzyout ]]; then 
						echo -e "\n* Clustering $M mock community with sclust, id $id weak id $weak_id and quality $qual, REP $rep..."
						/usr/bin/time -f "TIME:%U\nMEMORY:%M" -o $result.perf.txt sclust --cluster_fuzzy $mock_dir/$M.derep.fasta --id $id_perc --weak_id $weak_id_perc --fuzzyout $result.fuzzyout --threads $THREADS --quality $qual 
						mv RepartitionClust.txt $result.repartitionClust.txt 
					fi	
				done    
				
				mkdir -p $outdir/dnaclust 
				result=$outdir/dnaclust/$M.dnaclust.id$id.rep$rep 
				if [[ ! -f $result.clusters ]]; then 
					echo -e "\n* Clustering $M mock community with dnaclust, id $id, REP $rep..."
					/usr/bin/time -f "TIME:%U\nMEMORY:%M" -o $result.perf.txt dnaclust $mock_dir/$M.derep.fasta -s $id_perc -t $THREADS > $result.clusters 
				fi
				
			done	
		done 			 
	done 	
}	

function write_stats_file(){ 
	echo -e "\n-- WRITE STATS FILE --" 
	stats_file=$RESULTS/clusteringEval_stats.tsv 
	echo -e "data\tsample\trepetition\ttool\tid\tweak_id\tquality\ttime\tmax_memory\ttotal_clusters\tsingletons\tpairs\tbelow10\tabove10" > $stats_file
	for M in uneven; do 
		results_dir=$RESULTS/mock_community_$M
		data="mock_$M" 	
		for rep in $(seq $nb_rep); do 
			for id in 97 99; do 
				for tool in usearch vsearch; do 
					result=$results_dir/$tool/$M.$tool.id$id.rep$rep
					nb_clusters $result.uc 
					time=$(grep "TIME" $result.perf.txt | cut -f 2 -d ":")
					maxMemory=$(grep "MEMORY" $result.perf.txt | cut -f 2 -d ":") 
					echo -e "$data\t0\t$rep\t$tool\t$id\t-\t-\t$time\t$maxMemory\t$total_clusters\t$singletons\t$pairs\t$below10\t$above10" >> $stats_file 
				done
			
				#for tool in cdhit dnaclust; do 
				#	result=$results_dir/$tool/$M.$tool.id$id.rep$rep 
				#	time=$(grep "TIME" $result.perf.txt | cut -f 2 -d ":")
				#	maxMemory=$(grep "MEMORY" $result.perf.txt | cut -f 2 -d ":") 
				#	echo -e "$data\t0\t$rep\t$tool\t$id\t-\t-\t$time\t$maxMemory\t0\t0\t0\t0\t0" >> $stats_file 
				#done 
				
				for qual in 0 0.5 1; do 
					weak_id=$(($id - 2))
					result=$results_dir/sclust/$M.sclust.id$id.wid$weak_id.qual$qual.rep$rep 
					nb_clusters_fuzzyout $result.fuzzyout
					time=$(grep "TIME" $result.perf.txt | cut -f 2 -d ":")
					maxMemory=$(grep "MEMORY" $result.perf.txt | cut -f 2 -d ":")  
					echo -e "$data\t0\t$rep\tsclust\t$id\t$weak_id\t$qual\t$time\t$maxMemory\t$total_clusters" >> $stats_file 
				done 
				
			done 
			
		done 	
	done 	
}

function write_clusters_file(){
	echo -e "\n-- WRITE CLUSTERS FILE --" 
	nb_clusters_file=$RESULTS/clusteringEval_nbClusters.tsv
	echo -e "data\tsample\ttool\tid\tweak_id\ttype_cluster\tnumber_clusters" > $nb_clusters_file
	for M in uneven; do 
		results_dir=$RESULTS/mock_community_$M
		data="mock_$M" 	
		for id in 97 99; do 
			for tool in usearch vsearch; do 
				result=$results_dir/$tool/$M.$tool.id$id.rep1
				nb_clusters $result.uc 
				echo -e "$data\t0\t$tool\t$id\t-\t-\tsingletons\t$singletons" >> $nb_clusters_file
				echo -e "$data\t0\t$tool\t$id\t-\t-\tpairs\t$pairs" >> $nb_clusters_file
				echo -e "$data\t0\t$tool\t$id\t-\t-\tbelow10\t$below10" >> $nb_clusters_file
				echo -e "$data\t0\t$tool\t$id\t-\t-\tabove10\t$above10" >> $nb_clusters_file
			done 
			for qual in 0 0.5 1; do 
				weak_id=$(($id - 2))
				result=$results_dir/sclust/$M.sclust.id$id.wid$weak_id.qual$qual.rep1
				nb_clusters_fuzzyout $result.fuzzyout 
				echo -e "$data.qual$qual\t0\tsclust\t$id\t$weak_id\tsingletons\t$singletons" >> $nb_clusters_file
				echo -e "$data.qual$qual\t0\tsclust\t$id\t$weak_id\tpairs\t$pairs" >> $nb_clusters_file
				echo -e "$data.qual$qual\t0\tsclust\t$id\t$weak_id\tbelow10\t$below10" >> $nb_clusters_file
				echo -e "$data.qual$qual\t0\tsclust\t$id\t$weak_id\tabove10\t$above10" >> $nb_clusters_file
			done 
		done
	done 
}	

function nb_clusters(){
	uc_file=$1
	total_clusters=$(awk '{if ($1=="C") print}' $uc_file | wc -l)  
	singletons=$(awk '{if ($1=="C") print}' $uc_file | awk '{if ($3==1) print}' | wc -l)  
	pairs=$(awk '{if ($1=="C") print}' $uc_file | awk '{if ($3==2) print}' | wc -l)
	below10=$(awk '{if ($1=="C") print}' $uc_file | awk '{if ($3>2 && $3<10) print}' | wc -l)
	above10=$(awk '{if ($1=="C") print}' $uc_file | awk '{if ($3>=10) print}' | wc -l)
}	

function nb_clusters_fuzzyout(){
	fuzzyout=$1
	total_clusters=$(cut -f 2 $fuzzyout | cut -f 1 -d " " | sort -u | wc -l) 
	singletons=$(cut -f 2 $fuzzyout | cut -f 1 -d " " | sort | uniq -c | awk '{if ($1==1) print}' | wc -l) 
	pairs=$(cut -f 2 $fuzzyout | cut -f 1 -d " " | sort | uniq -c | awk '{if ($1==2) print}' | wc -l)
	below10=$(cut -f 2 $fuzzyout | cut -f 1 -d " " | sort | uniq -c | awk '{if ($1>2 && $1<10) print}' | wc -l)
	above10=$(cut -f 2 $fuzzyout | cut -f 1 -d " " | sort | uniq -c | awk '{if ($1>=10) print}' | wc -l)
}
	
	


THREADS=10
RESULTS=clusteringEval_RESULTS
nb_rep=10
mkdir -p $RESULTS

check_dependencies
download_data
derep
run_clustering
write_stats_file
write_clusters_file


