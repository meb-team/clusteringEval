import sys 
import os 

def usage(): 
	print("usage : python3 cluster2matrix.py <INPUT : cluster> <INPUT : reads .taxo file> <threshold 0.05% reads>")
	print("--") 
	print("This script takes clustering file to format it into otu matrix. Format accepted for clustering file are .uc, .fuzzyout, .otumap and .clstr.")
	print(".uc are .uc format given by vsearch, usearch or swarm.")
	print("clstr are .clstr format given by cd-hit or meshclust.")
	print(".otumap is file with one line per cluster, with seed reference in first column and reference from all sequences present in the cluster in following columns, separate by tab.") 
	print(".fuzzyout is tsv file with one line per sequence, with sequence reference in first column and cluster number and informations in second column, separate by tab. Second column is separate by space and contains following information : cluster_number membership_value (cluster_quality).") 

def check_arguments(list_input):
	list_notexists=[]
	q=False
	for i in list_input: 
		if not os.path.isfile(i):
			q=True
			list_notexists.append(i)	
	if q: 
		for i in list_notexists: 
			print("[ERROR] "+i+" not found /!\ ")
		exit() 	 				
			 
	
def get_file_format(file_name):
	file_format=file_name.split(".")[-1] 
	format_accepted=["uc","clstr","otumap","fuzzyout"]
	if file_format in format_accepted:
		return file_format 
	else :
		print("[ERROR] Clustering file is ."+file_format+" which is not accepted.") 
		exit()  	
	
def get_reads_strain(reads_taxo): 
	dic={}
	f=open(reads_taxo,"r") 
	a=f.readline() 
	for l in f : 
		l_split=l.rstrip().split("\t")
		dic[l_split[0]]=l_split[9]  	
	f.close() 
	return dic 
	
def create_dic_clusters_uc(uc,dic_reads_strains): 
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
		elif l.startswith("C") and l.split("\t")[2]=="1": 
			l_split=l.rstrip().split("\t")
			cluster_nb=l_split[1]
			seed=l_split[8].split(";")[0]
			taxo_seed=dic_reads_strains[seed] 
			list_taxo.add(taxo_seed) 
			dic[cluster_nb]={taxo_seed:[seed]}  
	uc.close() 
	return list_taxo,dic
	
def create_dic_clusters_fuzzyout(fuzzyout,dic_reads_strains): 
	list_taxo=set() 
	dic={}
	f=open(fuzzyout,"r") 
	for l in f : 
		l_split=l.split("\t") 
		ref=l_split[0].split(";")[0]
		cluster_nb=l_split[1].split(" ")[0]
		taxo_ref=dic_reads_strains[ref] 
		list_taxo.add(taxo_ref) 
		add_ref_to_cluster(dic,cluster_nb,ref,taxo_ref) 	 
	f.close()  	  
	return list_taxo, dic	
	
def create_dic_clusters_otumap(otumap,dic_reads_strains): 
	list_taxo=set() 
	dic={}
	cluster_nb=0
	f=open(otumap,"r") 
	for l in f : 
		cluster_nb+=1 
		for ref in l.rstrip().split("\t")[1:]: 
			ref=ref.split(";")[0]
			taxo_ref=dic_reads_strains[ref] 
			list_taxo.add(taxo_ref) 
			add_ref_to_cluster(dic,cluster_nb,ref,taxo_ref) 	
	f.close() 	
	return list_taxo,dic
	
def create_dic_clusters_clstr(clstr,dic_reads_strains): 
	list_taxo=set()
	dic={}
	clstr=open(clstr,"r") 
	for l in clstr: 
		if l.startswith(">"): 
			cluster_nb=l.rstrip().split(" ")[1]
		else: 
			ref=l.rstrip().split("...")[0].split(", ")[1].split(";")[0].lstrip(">") 
			taxo_ref=dic_reads_strains[ref]
			list_taxo.add(taxo_ref) 
			add_ref_to_cluster(dic,cluster_nb,ref,taxo_ref)     
	clstr.close() 		
	return list_taxo,dic 
	
def add_ref_to_cluster(dic,cluster_nb,ref,taxo_ref):
	if cluster_nb in dic : 
		if taxo_ref in dic[cluster_nb]: 
			dic[cluster_nb][taxo_ref].append(ref) 
		else: 
			dic[cluster_nb][taxo_ref]=[ref]
	else: 
		dic[cluster_nb]={taxo_ref:[ref]} 
		
def delete_singletons(dic):
	new_dic={}
	for c in dic: 
		size_cluster=0
		for tax in dic[c]: 
			size_cluster+=len(dic[c][tax])
		if size_cluster>1:
			new_dic[c]=dic[c]	
	return new_dic			
		
	
def write_otumatrix(list_taxo,dic_clusters,input_file,suffix):
	output_file=".".join(input_file.split(".")[:-1])+suffix
	o=open(output_file,"w") 
	o.write("OTUvsTaxa\t"+"\t".join(list_taxo)+"\n") 
	for i in dic_clusters: 
		o.write(str(int(i))) 
		for taxa in list_taxo: 
			try : 
				nb_seq=len(dic_clusters[i][taxa])
			except KeyError:
				nb_seq=0
			o.write("\t"+str(nb_seq))
		o.write("\n") 	 			 			
	o.close()		
	
def write_otumatrix_threshold(dic_clusters,input_file,suffix,threshold):
	output_file=".".join(input_file.split(".")[:-1])+suffix
	list_taxo=set()
	new_dic={}
	for i in dic_clusters : 
		total_seq=sum([len(dic_clusters[i][taxo]) for taxo in dic_clusters[i]])
		if total_seq > threshold :
			new_dic[i]=dic_clusters[i]
			for taxo in dic_clusters[i] : 
				list_taxo.add(taxo)
	o=open(output_file,"w") 				
	o.write("OTUvsTaxa\t"+"\t".join(list_taxo)+"\n")
	for i in new_dic : 
		o.write(str(int(i)))
		for taxa in list_taxo : 
			try : 
				nb_seq=len(dic_clusters[i][taxa]) 
			except KeyError : 
				nb_seq=0 
			o.write("\t"+str(nb_seq))
		o.write("\n")	
	o.close() 				 		 
				
if len(sys.argv)!=4: 
	usage() 
	exit() 


check_arguments(sys.argv[1:3])	

dic_reads_strains=get_reads_strain(sys.argv[2]) 

file_format=get_file_format(sys.argv[1])

threshold_005=int(sys.argv[3])-1

if file_format=="uc": 
	list_taxo,dic_clusters=create_dic_clusters_uc(sys.argv[1],dic_reads_strains) 
elif file_format=="fuzzyout": 
	list_taxo,dic_clusters=create_dic_clusters_fuzzyout(sys.argv[1],dic_reads_strains) 
elif file_format=="otumap": 
	list_taxo,dic_clusters=create_dic_clusters_otumap(sys.argv[1],dic_reads_strains)	
elif file_format=="clstr": 
	list_taxo,dic_clusters=create_dic_clusters_clstr(sys.argv[1],dic_reads_strains)	

write_otumatrix(list_taxo,dic_clusters,sys.argv[1],".otumatrix") 	   
write_otumatrix_threshold(dic_clusters,sys.argv[1],".nosingletons.otumatrix",1) 
write_otumatrix_threshold(dic_clusters,sys.argv[1],".005reads.otumatrix",threshold_005) 
