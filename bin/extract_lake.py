from Bio import SeqIO
import sys 

def usage(): 
	print("usage : python3 extract_lake.py <fasta> <lake keyword> <output fasta>")
	
if len(sys.argv)!=4: 
	usage()
	exit() 

keyword=sys.argv[2]
out=open(sys.argv[3],"w") 
for record in SeqIO.parse(sys.argv[1],"fasta"):
	if keyword in record.id: 
		SeqIO.write(record,out,"fasta") 			
out.close() 
