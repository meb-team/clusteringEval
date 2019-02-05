import sys 

def usage(): 
	print("usage : python3 matrix2distance.py <otu matrix> <reads taxo>") 
	
def get_strain_taxo(taxo):
	f=open(taxo,"r") 
	f.readline()
	dic={}
	for l in f : 
		l_split=l.rstrip().split("\t")  
		strain=l_split[9]
		dic[strain]=l_split[2:]
	f.close() 
	return dic 	
	
def get_dic_distance(matrix,dic_strain_taxo):
	matrix=open(matrix,"r") 
	taxo=matrix.readline().rstrip().split("\t")[1:]
	dic_distance={}
	for l in matrix :
		dic_occ={}
		cluster=l.split("\t")[0]
		occurences=l.rstrip().split("\t")[1:]
		for i in range(len(occurences)): 
			if occurences[i]!="0":
				if taxo[i] in dic_occ: 
					dic_occ[taxo[i]]+=int(occurences[i]) 
				else: 
					dic_occ[taxo[i]]=int(occurences[i])  
		if len(dic_occ)==1: 
			dist=0
			dic_distance[cluster]=[0]
		else: 
			list_taxo=[]
			for taxa in dic_occ : 
				for j in range(dic_occ[taxa]): 
					list_taxo.append(taxa) 
			for k in range(len(list_taxo)): 
				for l in range(j+1,len(list_taxo)): 
					strain1=list_taxo[k]
					strain2=list_taxo[l]
					taxo1=dic_strain_taxo[strain1]
					taxo2=dic_strain_taxo[strain2]
					m=0
					while taxo1[m]==taxo2[m] :
						m+=1	  
						if m==len(taxo1): 
							break
					dist=len(taxo1)-m			
				if cluster in dic_distance : 
					dic_distance[cluster].append(dist) 
				else: 
					dic_distance[cluster]=[dist] 
	matrix.close()
	return(dic_distance) 		

def compute_distance(dic_distance): 
	print("Cluster\tMaximum distance\tMean distance")
	for cluster in dic_distance :
		max_dist=max(dic_distance[cluster])
		mean_dist=sum(dic_distance[cluster])/len(dic_distance[cluster])  								
		print(cluster+"\t"+str(max_dist)+"\t"+str(mean_dist))
	
if len(sys.argv)!=3: 
	usage() 
	exit() 	
	

dic_strain_taxo=get_strain_taxo(sys.argv[2]) 
dic_distance=get_dic_distance(sys.argv[1],dic_strain_taxo)
compute_distance(dic_distance) 


	
	

