import sys 

def usage(): 
	print("usage : python3 uc2matrix.py <INPUT : .uc file> <INPUT : reads .taxo file>")
	print("--") 
	print("This script takes clustering .uc file for input and create otu matrix with taxonomy count for each OTU.") 

def get_reads_strain(reads_taxo): 
	dic={}
	f=open(reads_taxo,"r") 
	a=f.readline() 
	for l in f : 
		l_split=l.rstrip().split("\t")
		dic[l_split[0]]=l_split[9]  	
	f.close() 
	return dic 
	
def create_clusters_dic(uc,dic_reads_strains,wsingletons): 
	list_taxo=set() 
	dic={}
	uc=open(uc,"r") 
	for l in uc : 
		#OTU size > 1 
		if l.startswith("H"): 
			l_split=l.rstrip().split("\t")
			cluster_nb=l_split[1]
			hit=l_split[8].split(";")[0]
			seed=l_split[9].split(";")[0]
			taxo_hit=dic_reads_strains[hit]
			list_taxo.add(taxo_hit)
			if cluster_nb in dic : 
				if taxo_hit in dic[cluster_nb]: 
					dic[cluster_nb][taxo_hit].append(hit) 
				else: 
					dic[cluster_nb][taxo_hit]=[hit]	
			else: 
				taxo_seed=dic_reads_strains[seed]
				dic[cluster_nb]={taxo_seed:[seed]}
				if taxo_hit in dic[cluster_nb]: 
					dic[cluster_nb][taxo_hit].append(hit) 
				else: 
					dic[cluster_nb][taxo_hit]=[hit]
		#OTU size = 1  
		elif l.startswith("C") and l.split("\t")[2]=="1" and wsingletons==True: 
			l_split=l.rstrip().split("\t")
			cluster_nb=l_split[1]
			seed=l_split[8].split(";")[0]
			taxo_seed=dic_reads_strains[seed] 
			list_taxo.add(taxo_seed) 
			dic[cluster_nb]={taxo_seed:[seed]}  
	uc.close() 
	return list_taxo,dic	
	
def write_otumatrix(list_taxo,dic_clusters,input_file,suffix):
		output_file=".".join(input_file.split(".")[:-1])+suffix
		o=open(output_file,"w") 
		o.write("OTUvsTaxa\t"+"\t".join(list_taxo)+"\n") 
		for i in dic_clusters: 
			o.write(str(int(i)+1)) 
			for taxa in list_taxo: 
				try : 
					nb_seq=len(dic_clusters[i][taxa])
				except KeyError:
					nb_seq=0
				o.write("\t"+str(nb_seq))
			o.write("\n") 	 			 			
		o.close()
	
if len(sys.argv)!=3: 
	usage()
	exit() 
	
dic_reads_strains=get_reads_strain(sys.argv[2]) 
list_taxo_singletons,clusters_dic_singletons=create_clusters_dic(sys.argv[1],dic_reads_strains,True) 
list_taxo_nosingletons,clusters_dic_nosingletons=create_clusters_dic(sys.argv[1],dic_reads_strains,False) 
write_otumatrix(list(list_taxo_singletons),clusters_dic_singletons,sys.argv[1],".otumatrix") 
write_otumatrix(list(list_taxo_nosingletons),clusters_dic_nosingletons,sys.argv[1],".nosingletons.otumatrix") 
