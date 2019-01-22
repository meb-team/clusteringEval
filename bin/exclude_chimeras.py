import sys 
from Bio import SeqIO 

def usage(): 
	print("usage : python3 exclude_chimeras.py <FROGS .fastq file> <output fastq file>")
	print("--") 
	print("This script delete chimeras sequences produces by sequencing simulation for FROGS synthetic dataset (from SILVA)")
	print("Datasets : http://frogs.toulouse.inra.fr/data_to_test_frogs/") 
	
if len(sys.argv)!=3: 
	usage() 
	exit() 
	
fastq_out=open(sys.argv[2],"w") 	
for record in SeqIO.parse(sys.argv[1],"fastq"): 
	if "description" in record.description:  
		SeqIO.write(record,fastq_out,"fastq") 
fastq_out.close() 		
		
		
