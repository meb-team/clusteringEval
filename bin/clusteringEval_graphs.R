library(ggplot2) 

f=read.table("clusteringEval_RESULTS/all_samples-1000sp-Powerlaw.noChimeras.derep.eval.tsv",header=TRUE,sep="\t") 

f$p_singletons=f$singletons/f$total_clusters*100

ari_boxplot=ggplot(f,aes(x=tool,y=ARI,fill=tool))+geom_boxplot()+labs(fill="Tools",y="Adjusted Rand Index")+theme(axis.text.x=element_blank(),axis.title.x=element_blank(),axis.ticks.x=element_blank(),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14),strip.text.x=element_text(size=16))

precision_boxplot=ggplot(f,aes(x=tool,y=precision,fill=tool))+geom_boxplot()+labs(fill="Tools",y="Precision")+theme(axis.text.x=element_blank(),axis.title.x=element_blank(),axis.ticks.x=element_blank(),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14),strip.text.x=element_text(size=16))

recall_boxplot=ggplot(f,aes(x=tool,y=recall,fill=tool))+geom_boxplot()+labs(fill="Tools",y="Recall")+theme(axis.text.x=element_blank(),axis.title.x=element_blank(),axis.ticks.x=element_blank(),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14),strip.text.x=element_text(size=16)) 

total_clusters_boxplot=ggplot(f,aes(x=tool,y=total_clusters,fill=tool))+geom_boxplot()+labs(fill="Tools",y="Number of clusters")+theme(axis.text.x=element_blank(),axis.title.x=element_blank(),axis.ticks.x=element_blank(),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14),strip.text.x=element_text(size=16))

singletons_boxplot=ggplot(f,aes(x=tool,y=p_singletons,fill=tool))+geom_boxplot()+labs(fill="Tools",y="Singletons (%)",linetype="Algo")+theme(axis.text.x=element_blank(),axis.title.x=element_blank(),axis.ticks.x=element_blank(),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14),strip.text.x=element_text(size=16))

pdf("clusteringEval_EVAL/tools_comparison/ari_boxplot.pdf")
ari_boxplot
dev.off()

png("clusteringEval_EVAL/tools_comparison/ari_boxplot.png") 
ari_boxplot
dev.off() 

pdf("clusteringEval_EVAL/tools_comparison/precision_boxplot.pdf")
precision_boxplot
dev.off()

pdf("clusteringEval_EVAL/tools_comparison/recall_boxplot.pdf")
recall_boxplot
dev.off() 
 
pdf("clusteringEval_EVAL/tools_comparison/total_clusters_boxplot.pdf")
total_clusters_boxplot
dev.off() 
 
pdf("clusteringEval_EVAL/tools_comparison/singletons_boxplot.pdf")
singletons_boxplot 
dev.off() 

png("clusteringEval_EVAL/tools_comparison/singletons_boxplot.png") 
singletons_boxplot 
dev.off() 
