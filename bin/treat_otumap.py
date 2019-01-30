import sys 

def usage(): 
	print("usage : python3 treat_otumap.py <.otumap file> <threshold>" )


if len(sys.argv)!=3: 
	usage()
	exit()
	
f=open(sys.argv[1],"r") 
threshold=int(sys.argv[2])
total_clusters=0
singletons=0
pairs=0 
clusters005=0
for l in f: 
	total_clusters+=1
	otu_size=len(l.split("\t"))-1  
	if otu_size == 1: 
		singletons+=1 
	elif otu_size == 2: 
		pairs+=1 	
	if otu_size >= threshold :  
		clusters005+=1

print(total_clusters,singletons,pairs,clusters005)
