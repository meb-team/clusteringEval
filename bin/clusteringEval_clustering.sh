set -e 

function usage(){ 
	echo "usage : bash clusteringEval_clustering.sh <fastq|fasta file> <outdir> <clustering identity>"  
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
	echo -e "\n -- CHECK ARGUMENTS --" 
	verif_file $input "[INPUT] $input not found." "[INPUT] $input found"
	mkdir -p $outdir 
}	
	


if [[ $# -ne 3 ]]; then 
	usage 
	exit 1 
fi 

input=$1
outdir=$2
id=$3
BIN=$(echo $0 | rev | cut -f 2- -d "/" | rev)
THREADS=10
if [[ $BIN == $0 ]]; then 
	BIN=. 
fi 
source $BIN/common_functions.sh 

check_dependencies
args_gestion

prefix=$(echo $input | rev | cut -f 1 -d "/" | cut -f 2- -d "." | rev) 

echo -e "\n-- CD-HIT CLUSTERING --" 
dir=$outdir/cdhit 
mkdir -p $dir
perc_id=$(echo $id | awk '{print $1/100}') 
echo "* Cluster $input with cd-hit at id $id..."
if [[ ! -f $dir/$prefix.cdhit.id$id.clstr ]]; then 
	/usr/bin/time -f "Memory %M\nTime %U" -o $dir/$prefix.cdhit.id$id.time.txt cd-hit-est -i $input -o $dir/$prefix.cdhit.id$id -c $perc_id -M 0 -T $THREADS
else 
	echo "Results already exists" 
fi 	

echo -e "\n-- MESHCLUST CLUSTERING --" 
dir=$outdir/meshclust 
mkdir -p $dir 
perc_id=$(echo $id | awk '{print $1/100}') 
echo "* Cluster $input with meshclust at id $id..."
if [[ ! -f $dir/$prefix.meshclust.id$id.clstr ]]; then 
	/usr/bin/time -f "Memory %M\nTime %U" -o $dir/$prefix.meshclust.id$id.time.txt meshclust $input --id $perc_id --threads $THREADS --output $dir/$prefix.meshclust.id$id.clstr  
else 
	echo "Results already exists" 
fi 		

echo -e "\n-- SCLUST CLUSTERING --" 
dir=$outdir/sclust 
mkdir -p $dir 

wid=$(($id - 2))
qual=0
perc_id=$(echo $id | awk '{print $1/100}') 
perc_wid=$(echo $wid | awk '{print $1/100}') 
echo "* Cluster $input with sclust at id $id, weak id $wid and quality $qual..."
if [[ ! -f $dir/$prefix.sclust.id$id.wid$wid.qual$qual.fuzzyout ]]; then 
	/usr/bin/time -f "Memory %M\nTime %U" -o $dir/$prefix.sclust.id$id.wid$wid.qual$qual.time.txt sclust --cluster_fuzzy $input --id $perc_id --weak_id $perc_wid --quality $qual --threads $THREADS --fuzzyout $dir/$prefix.sclust.id$id.wid$wid.qual$qual.fuzzyout 
	mv RepartitionClust.txt $dir/$prefix.sclust.id$id.wid$wid.qual$qual.repartitionClust.txt 
else 
	echo "Results already exists" 
fi 

echo -e "\n-- SUMACLUST CLUSTERING --"
dir=$outdir/sumaclust 
mkdir -p $dir  
echo "* Sumaclust formatting..." 
sed "s/;size=/ count=/g" $input > $input.sumaclust 

perc_id=$(echo $id | awk '{print $1/100}') 
echo "* Cluster $input with sumaclust at id $id..."
if [[ ! -f $dir/$prefix.sumaclust.id$id.otumap ]]; then 
	/usr/bin/time -f "Memory %M\nTime %U" -o $dir/$prefix.sumaclust.id$id.time.txt sumaclust -t $perc_id -p $THREADS -O $dir/$prefix.sumaclust.id$id.otumap -F $dir/$prefix.sumaclust.id$id.fasta $input
else 
	echo "Results already exists." 
fi 	
rm $input.sumaclust 

echo -e "\n-- SWARM CLUSTERING --" 
dir=$outdir/swarm 
mkdir -p $dir 
d=$((100-$id)) 
echo "* Cluster $input with swarm with d=$d..." 
if [[ ! -f $dir/$prefix.swarm.d$d.uc ]]; then 
	/usr/bin/time -f "Memory %M\nTime %U" -o $dir/$prefix.swarm.d$d.time.txt swarm $input -d $d -t $THREADS -u $dir/$prefix.swarm.d$d.uc -z > $dir/$prefix.swarm.d$d.otumap 
else 
	echo "Results already exists." 
fi

echo -e "\n-- VSEARCH CLUSTERING --" 
dir=$outdir/vsearch 
mkdir -p $dir 
perc_id=$(echo $id | awk '{print $1/100}') 
echo "* Cluster $input with vsearch at id $id..."
if [[ ! -f $dir/$prefix.vsearch.id$id.uc ]]; then 
	/usr/bin/time -f "Memory %M\nTime %U" -o $dir/$prefix.vsearch.id$id.time.txt vsearch --cluster_fast $input --id $perc_id --threads $THREADS --uc $dir/$prefix.vsearch.id$id.uc 
else 
	echo "Results already exists." 
fi 
