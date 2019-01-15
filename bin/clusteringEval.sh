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
	for M in even uneven; do
		outdir=$RESULTS/mock_community_$M
		mkdir -p $outdir
		for tool in vsearch usearch; do 
			for id in 97 99; do 
				if [[ ! -f $outdir/$M.$tool.$id.uc ]]; then 
					echo "* Clustering $M mock community with $tool at id $id..." 
					/usr/bin/time -f "TIME : %U\nMEMORY : %M" -o $outdir/$M.$tool.$id.perf.txt $tool --cluster_fast $mock_dir/$M.derep.fasta --id $(echo $id | awk '{print $1/100}') --uc $outdir/$M.$tool.$id.uc --threads $THREADS
				fi
			done 		 
		done 
	done 	
}	


THREADS=10
RESULTS=clusteringEval_RESULTS
mkdir -p $RESULTS

check_dependencies
download_data
derep
run_clustering


