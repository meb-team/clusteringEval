import sys 
from Bio import SeqIO 
from ete3 import NCBITaxa

def usage(): 
	print("usage : python3 frogs_taxo.py <fastq headers with taxo> <fasta used for clustering>") 

if len(sys.argv)!=3: 
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
	
print("Read\tAbundance\tKingdom\tPhylum\tClass\tOrder\tFamily\tGenus\tSpecies/strain") 	
for record in SeqIO.parse(sys.argv[2],"fasta"): 
	ref=record.id.split(";")[0]
	abundance=record.id.split(";")[1].split("=")[1]
	print(ref+"\t"+abundance+"\t"+dic_taxo[ref]) 


	
	
