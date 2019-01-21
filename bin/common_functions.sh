function verif_file(){
	f=$1 
	message=$2
	message2=$3
	if [[ ! -f $f ]]; then 
		echo $message 
		exit 1
	else 
		echo $message2	
	fi
}

function verif_dir(){
	d=$1 
	message=$2
	message2=$3
	if [[ ! -d $d ]]; then 
		echo $message 
		exit 1
	else 
		echo $message2	
	fi		
}	
