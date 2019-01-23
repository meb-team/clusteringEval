import sys 

def usage(): 
	print("usage : python3 fuzzyout2matrix.py <INPUT : .fuzzyout file> <INPUT : reads .taxo file>")
	print("--") 
	print("This script takes clustering .fuzzyout file for input and create otu matrix with taxonomy count for each OTU.") 
	
def get_reads_strain(reads_taxo): 
	dic={}
	f=open(reads_taxo,"r") 
	a=f.readline() 
	for l in f : 
		l_split=l.rstrip().split("\t")
		dic[l_split[0]]=l_split[9]  	
	f.close() 
	return dic 
	
def create_clusters_dic(fuzzyout,dic_reads_strains,wsingletons): 
	list_taxo=set() 
	dic={}
	f=open(fuzzyout,"r") 
	for l in f : 
		l_split=l.split("\t") 
		ref=l_split[0].split(";")[0]
		cluster_nb=l_split[1].split(" ")[0]
		taxo_ref=dic_reads_strains[ref] 
		list_taxo.add(taxo_ref) 
		if cluster_nb in dic : 
			if taxo_ref in dic[cluster_nb]: 
				dic[cluster_nb][taxo_ref].append(ref) 
			else: 
				dic[cluster_nb][taxo_ref]=[ref]
		else: 
			dic[cluster_nb]={taxo_ref:[ref]} 		 
	f.close()  
	return list_taxo, dic
	
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
list_taxo,dic_clusters=create_clusters_dic(sys.argv[1],dic_reads_strains,True) 	
print(dic_clusters["1310"]) 
write_otumatrix(list_taxo,dic_clusters,sys.argv[1],".otumatrix") 
