import sys 

def usage(): 
	print("usage : python3 treat_clstr.py <.clstr file> <threshold>")

if len(sys.argv)!=3: 
	usage() 
	exit() 
	
f=open(sys.argv[1],"r") 
threshold=int(sys.argv[2]) 
dic_otu={}
nb_otu=0
for l in f: 
	if l.startswith(">"):
		nb_otu+=1  
		dic_otu["OTU"+str(nb_otu)]=0   
	else: 
		dic_otu["OTU"+str(nb_otu)]+=1  
			  
singletons=0 
pairs=0			  
clusters005=0
for otu in dic_otu: 
	if dic_otu[otu]==1: 
		singletons+=1 
	elif dic_otu[otu]==2: 
		pairs+=1 
	if dic_otu[otu]>=threshold: 
		clusters005+=1	

print(len(dic_otu),singletons,pairs,clusters005) 	  			  
			
