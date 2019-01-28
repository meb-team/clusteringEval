library(ggplot2) 

s1=read.table("clusteringEval_RESULTS/sample01-1000sp-Powerlaw.noChimeras.derep.eval.tsv",header=TRUE,sep="\t") 
s2=read.table("clusteringEval_RESULTS/sample02-1000sp-Powerlaw.noChimeras.derep.eval.tsv",header=TRUE,sep="\t")

s1$p_singletons=s1$singletons/s1$total_clusters*100

plot_ARI_algo=ggplot(s1,aes(x=threshold,y=ARI,color=tool))+geom_point()+geom_line()+facet_wrap(~algo)  
plot_recall_algo=ggplot(s1,aes(x=threshold,y=recall,color=tool))+geom_point()+geom_line()+facet_wrap(~algo)  
plot_precision_algo=ggplot(s1,aes(x=threshold,y=precision,color=tool))+geom_point()+geom_line()+facet_wrap(~algo)  
plot_singletons_algo=ggplot(s1,aes(x=threshold,y=p_singletons,color=tool))+geom_point()+geom_line()+facet_wrap(~algo) 

 
