import sys 

def usage(): 
	print("usage : python3 distanceArbre.py <cluster results> <.tsv taxo file>")
	
def get_file_format(file_name):
	file_format=file_name.split(".")[-1] 
	format_accepted=["uc","clstr","otumap","fuzzyout"]
	if file_format in format_accepted:
		return file_format 
	else :
		print("[ERROR] Clustering file is ."+file_format+" which is not accepted.") 
		exit()	
		
def get_dic_clusters(cluster_file,file_format): 
	dic={}
	f=open(cluster_file,"r") 
	if file_format=="fuzzyout": 
		for l in f: 
			read=l.split("\t")[0].split(";")[0]
			cluster=l.split("\t")[1].split(" ")[0]
			dic[read]=cluster 
		f.close() 	
		return dic 
	elif file_format=="uc": 
		for l in f : 
			if l.startswith("S"): 
				l_split=l.split("\t")
				cluster=l_split[1]
				print(cluster) 
				read=l_split[8].split(";")[0]
				dic[read]=cluster
			elif l.startswith("H"): 
				l_split=l.split("\t")
				cluster=l_split[1]
				read=l_split[8].split(";")[0]
				dic[read]=cluster
		f.close()
		return dic 
	elif file_format=="clstr": 
		for l in f: 
			if l.startswith(">"): 
				cluster=l.rstrip().split(" ")[-1]	
				print(cluster) 
			else: 
				read=l.split(" ")[1].split(";")[0].lstrip(">") 
				dic[read]=cluster 
		f.close() 
		return dic 
	elif file_format=="otumap":
		i=0
		for l in f: 
			l_reads=l.rstrip().split("\t")[1:]
			for read in l_reads : 
				dic[read]=str(i) 
			i+=1 
		f.close() 
		return dic 		
				
def get_dic_taxo(taxo_file): 
	dic={}
	f=open(taxo_file,"r") 
	for l in f: 
		read=l.split("\t")[0]
		taxo=l.rstrip().split("\t")[2:]
		dic[read]=taxo 
	f.close() 
	return dic 
	
def get_dic_distance(dic_clusters,dic_taxo): 
	dic_distance={}
	list_reads=list(dic_clusters.keys())
	for i in range(len(list_reads)): 
		for j in range(i+1,len(list_reads)): 
			read1=list_reads[i] 
			read2=list_reads[j]
			if dic_clusters[read1]==dic_clusters[read2]: 
				cluster=dic_clusters[read1]
				taxo1=dic_taxo[read1]
				taxo2=dic_taxo[read2]
				k=0
				while taxo1[k]==taxo2[k] :
					k=k+1 	  
					if k==len(taxo1): 
						break
				dist=len(taxo1)-k	
				if cluster in dic_distance : 
					dic_distance[cluster].append(dist) 
				else: 
					dic_distance[cluster]=[dist] 
	return dic_distance 					

def compute_distance(dic_distance): 
	print("Cluster\tMaximum distance\tMean distance")
	for i in range(len(dic_distance)):
		try : 
			max_dist=max(dic_distance[str(i)])
			mean_dist=sum(dic_distance[str(i)])/len(dic_distance[str(i)])  								
			print(str(i)+"\t"+str(max_dist)+"\t"+str(mean_dist))
		except KeyError: 
			print(str(i)+"_singleton\t0\t0")	 

if len(sys.argv)!=3 : 
	usage()
	exit() 	 


file_format=get_file_format(sys.argv[1]) 
dic_clusters=get_dic_clusters(sys.argv[1],file_format) 
dic_taxo=get_dic_taxo(sys.argv[2]) 
dic_distance=get_dic_distance(dic_clusters,dic_taxo)
compute_distance(dic_distance) 
