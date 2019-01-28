import sys 
from Bio import SeqIO 
from ete3 import NCBITaxa

def usage(): 
	print("usage : python3 frogs_taxo.py <fastq headers with taxo> <fasta used for clustering> <abundance output> <taxonomy output>") 

if len(sys.argv)!=5: 
	usage() 
	exit() 

def get_taxo(fastq_header): 
	dic={}
	f=open(fastq_header,"r") 
	for l in f: 
		l_split=l.split("description=") 
		ref=l_split[0].split(" ")[0].lstrip("@") 
		taxo=l_split[-1].split(";")
		taxo="\t".join([t.split(" [")[0] for t in taxo]).lstrip('"') 
		dic[ref]=taxo 
	return dic	

dic_taxo=get_taxo(sys.argv[1]) 
	
dic_abundance={}	

tax_output=open(sys.argv[4],"w") 

tax_output.write("Read\tAbundance\tKingdom\tPhylum\tClass\tOrder\tFamily\tGenus\tSpecies/strain\n") 	
for record in SeqIO.parse(sys.argv[2],"fasta"): 
	ref=record.id.split(";")[0]
	abundance=record.id.split(";")[1].split("=")[1]
	specie=dic_taxo[ref].split("\t")[7]
	if specie in dic_abundance:
		dic_abundance[specie]+=int(abundance)
	else: 
		dic_abundance[specie]=int(abundance)	
	tax_output.write(ref+"\t"+abundance+"\t"+dic_taxo[ref]+"\n") 

tax_output.close() 

ab_output=open(sys.argv[3],"w") 
ab_output.write("Specie/strain\tAbundance\n") 
for tax in dic_abundance: 
	ab_output.write(tax+"\t"+str(dic_abundance[tax])+"\n")
ab_output.close() 	 
	

	
	
