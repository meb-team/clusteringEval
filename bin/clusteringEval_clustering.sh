set -e 

function usage(){ 
	echo "usage : bash clusteringEval_clustering.sh <fastq|fasta file> <outdir>"  
}

function check_dependencies(){
	echo -e "\n-- CHECK DEPENDENCIES --" 

	if [[ $(command -v cd-hit-est) ]]; then 
		echo "* CD-HIT : installed" 
	else 
		echo "* CD-HIT not installed /!\ "
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

function args_gestion(){
	echo "\n -- CHECK ARGUMENTS --" 
	verif_file $input "[INPUT] $input not found." "[INPUT] $input found"
	mkdir -p $outdir 
}	


if [[ $# -ne 2 ]]; then 
	usage 
	exit 1 
fi 

input=$1
outdir=$2
BIN=$(echo $0 | rev | cut -f 2- -d "/" | rev)
THREADS=6
echo $BIN 	
if [[ $BIN == $0 ]]; then 
	BIN=. 
fi 
source $BIN/common_functions.sh 

check_dependencies
args_gestion

echo "-- CD-HIT CLUSTERING --" 
dir=$outdir/cdhit 
mkdir -p $dir 

cd-hit-est  




