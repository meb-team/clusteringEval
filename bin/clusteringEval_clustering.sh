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
	echo -e "\n -- CHECK ARGUMENTS --" 
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
for id in 97 98 99; do 
	perc_id=$(echo $id | awk '{print $1/100}') 
	echo "* Cluster $input with cd-hit at id $id..."
	if [[ ! -f $dir/$prefix.cdhit.id$id.clstr ]]; then 
		cd-hit-est -i $input -o $dir/$prefix.cdhit.id$id -c $perc_id -M 0 -T $THREADS
	else 
		echo "Results already exists" 
	fi 	
	echo "* Cluster $input with accurate cd-hit at id $id..."	
	if [[ ! -f $dir/$prefix.cdhit.accurate.id$id.clstr ]]; then 
		cd-hit-est -i $input -o $dir/$prefix.cdhit.accurate.id$id -c $perc_id -M 0 -T $THREADS
	else 
		echo "Results already exists" 
	fi	
done 	

echo -e "\n-- MESHCLUST CLUSTERING --" 
dir=$outdir/meshclust 
mkdir -p $dir 
for id in 97 98 99; do 
	perc_id=$(echo $id | awk '{print $1/100}') 
	echo "* Cluster $input with meshclust at id $id..."
	if [[ ! -f $dir/$prefix.meshclust.id$id.clstr ]]; then 
		meshclust $input --id $perc_id --threads $THREADS --output $dir/$prefix.meshclust.id$id.clstr  
	else 
		echo "Results already exists" 
	fi 		
	echo "* Cluster $input with accurate meshclust at id $id..."
	if [[ ! -f $dir/$prefix.meshclust.accurate.id$id.clstr ]]; then 
		meshclust $input --id $perc_id --threads $THREADS --align --output $dir/$prefix.meshclust.accurate.id$id.clstr
	else 
		echo "Results already exists" 
	fi 			
done  

echo -e "\n-- SCLUST CLUSTERING --" 
dir=$outdir/sclust 
mkdir -p $dir 
for id in 97 98 99; do 
	wid=$(($id - 2))
	perc_id=$(echo $id | awk '{print $1/100}') 
	perc_wid=$(echo $wid | awk '{print $1/100}') 
	for qual in 0; do
		echo "* Cluster $input with sclust at id $id, weak id $wid and quality $qual..."
		if [[ ! -f $dir/$prefix.sclust.id$id.wid$wid.qual$qual.fuzzyout ]]; then 
			sclust --cluster_fuzzy $input --id $perc_id --weak_id $perc_wid --quality $qual --threads $THREADS --fuzzyout $dir/$prefix.sclust.id$id.wid$wid.qual$qual.fuzzyout 
			mv RepartitionClust.txt $dir/$prefix.sclust.id$id.wid$wid.qual$qual.repartitionClust.txt 
		else 
			echo "Results already exists" 
		fi 
		echo "* Cluster $input with accurate sclust at id $id, weak id $wid and quality $qual..."
		if [[ ! -f $dir/$prefix.sclust.accurate.id$id.wid$wid.qual$qual.fuzzyout ]]; then 
			sclust --cluster_fuzzy $input --id $perc_id --weak_id $perc_wid --quality $qual --threads $THREADS --fuzzyout $dir/$prefix.sclust.accurate.id$id.wid$wid.qual$qual.fuzzyout --maxaccepts 0 --maxrejects 0
			mv RepartitionClust.txt $dir/$prefix.sclust.accurate.id$id.wid$wid.qual$qual.repartitionClust.txt 
		else 
			echo "Results already exists" 
		fi	
		
	done 	
done 	 

echo -e "\n-- SUMACLUST CLUSTERING --"
dir=$outdir/sumaclust 
mkdir -p $dir  
echo "* Sumaclust formatting..." 
sed "s/;size=/ count=/g" $input > $input.sumaclust 
for id in 97 98 99; do 
	perc_id=$(echo $id | awk '{print $1/100}') 
	echo "* Cluster $input with sumaclust at id $id..."
	if [[ ! -f $dir/$prefix.sumaclust.id$id.otumap ]]; then 
		sumaclust -t $perc_id -p $THREADS -O $dir/$prefix.sumaclust.id$id.otumap -F $dir/$prefix.sumaclust.id$id.fasta $input
	else 
		echo "Results already exists." 
	fi 	
	echo "* Cluster $input with accurate sumaclust at id $id..."
	if [[ ! -f $dir/$prefix.sumaclust.accurate.id$id.otumap ]]; then 
		sumaclust -e -t $perc_id -p $THREADS -O $dir/$prefix.sumaclust.accurate.id$id.otumap -F $dir/$prefix.sumaclust.accurate.id$id.fasta $input
	else 
		echo "Results already exists." 
	fi 
done 
rm $input.sumaclust 

echo -e "\n-- SWARM CLUSTERING --" 
dir=$outdir/swarm 
mkdir -p $dir 
for d in 3 2 1; do 
	echo "* Cluster $input with swarm with d=$d..." 
	if [[ ! -f $dir/$prefix.swarm.d$d.uc ]]; then 
		swarm $input -t $THREADS -d $d -u $dir/$prefix.swarm.d$d.uc -z > $dir/$prefix.swarm.d$d.otumap 
	else 
		echo "Results already exists." 
	fi 	
done 

echo -e "\n-- VSEARCH CLUSTERING --" 
dir=$outdir/vsearch 
mkdir -p $dir 
for id in 97 98 99; do 
	perc_id=$(echo $id | awk '{print $1/100}') 
	echo "* Cluster $input with vsearch at id $id..."
	if [[ ! -f $dir/$prefix.vsearch.id$id.uc ]]; then 
		vsearch --cluster_fast $input --id $perc_id --threads $THREADS --uc $dir/$prefix.vsearch.id$id.uc 
	else 
		echo "Results already exists." 
	fi 
	echo "* Cluster $input with accurate vsearch at id $id..."
	if [[ ! -f $dir/$prefix.vsearch.accurate.id$id.uc ]]; then 
		vsearch --cluster_fast $input --id $perc_id --threads $THREADS --uc $dir/$prefix.vsearch.accurate.id$id.uc --maxaccepts 0 --maxrejects 0 
	else 
		echo "Results already exists." 
	fi 
done 
