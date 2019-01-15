set -e 

function check_dependencies(){
	echo "-- CHECK DEPENDENCIES --" 

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

check_dependencies
