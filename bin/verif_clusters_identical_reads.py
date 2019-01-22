import sys

def usage(): 
	print("python3 verif_clusters_identical_reads.py <.uc file> <.fastq headers with taxo>") 
	
def get_strain(fastq_header): 
	dic={} 
	f=open(fastq_header,"r") 
	for l in f: 
		l_split=l.split("description=") 
		ref=l_split[0].split(" ")[0].lstrip("@") 
		strain=l_split[-1].split(";")[-1].split(" [")[0] 
		if strain == "": 
			print(l) 
		dic[ref]=strain 
	f.close() 
	return dic
	
def get_uc_info(uc): 
	dic={}
	f=open(uc,"r") 
	for l in f : 
		if l.startswith("H"): 
			l_split=l.split("\t") 
			cluster=l_split[1] 
			hit=l_split[8]
			if cluster in dic : 
				dic[cluster].append(hit) 
			else:
				dic[cluster]=[l_split[9].rstrip(),l_split[8]] 	 
	f.close()
	return dic 		
	 	
def clusters_strains(dic_strain,dic_cluster):
	for c in dic_cluster: 
		strains_list=set() 
		for ref in dic_cluster[c]: 
			strains_list.add(dic_strain[ref]) 
		if len(strains_list)>1: 
			print(">Cluster"+c) 
			print("\n".join(list(strains_list)))   	
		 

if len(sys.argv)!=3: 
	usage() 
	exit() 
	
uc=sys.argv[1]
fastq_header=sys.argv[2]

dic_strain=get_strain(fastq_header) 
dic_cluster=get_uc_info(uc)
clusters_strains(dic_strain,dic_cluster) 
 


	
