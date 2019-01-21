import sys 

def usage(): 
	print("usage : python3 treat_otumap.py <.otumap file>")


if len(sys.argv)!=2: 
	usage()
	exit()
	
f=open(sys.argv[1],"r") 

total_clusters=0
singletons=0
pairs=0 
for l in f: 
	total_clusters+=1
	otu_size=len(l.split("\t"))-1  
	if otu_size == 1: 
		singletons+=1 
	elif otu_size == 2: 
		pairs+=1 	

print(total_clusters,singletons,pairs)
