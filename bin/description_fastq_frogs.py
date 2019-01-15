import sys 
from Bio import SeqIO

def usage(): 
	print("usage : python3 description_fastq.py <fastq file>")

if len(sys.argv)!=2:
	usage()
	exit() 	 

dic_specie={}
for record in SeqIO.parse(sys.argv[1],"fastq"):
	if "description=" in record.description :  
		specie=record.description.split("description=")[1].split(";")[-1].split("[")[0] 	 
	else: 
		specie="undefined" 	
	if specie in dic_specie :
		dic_specie[specie]+=1 
	else: 
		dic_specie[specie]=1	
		
print("#specie\treads_number")		
for sp in dic_specie:
	print(sp+"\t"+str(dic_specie[sp]))  		
