library(ggplot2) 

f_all=read.table("clusteringEval_TOOL_COMPARISON/all_samples-1000sp-Powerlaw.noChimeras.derep.eval.tsv",header=TRUE,sep="\t") 
f_nosingle=read.table("clusteringEval_TOOL_COMPARISON/all_samples-1000sp-Powerlaw.noChimeras.derep.nosingle.eval.tsv",header=TRUE,sep="\t") 
f_005=read.table("clusteringEval_TOOL_COMPARISON/all_samples-1000sp-Powerlaw.noChimeras.derep.005reads.eval.tsv",header=TRUE,sep="\t") 

f_all=data.frame(tool=f_all$tool,sample=f_all$sample,algo=f_all$algo,threshold.d=f_all$threshold.d,number_clusters=f_all$total_clusters,recall=f_all$recall,precision=f_all$precision,ARI=f_all$ARI,"Mean mean distance"=f_all$Mean.mean.distance,"Mean max distance"=f_all$Mean.max.distance) 

f_all$type="All clusters" 
f_nosingle$type="Clusters with size > 1" 
f_005$type="Clusters with size >= 0.05% of reads" 

f=rbind(f_all,f_nosingle,f_005) 

f$type=factor(f$type,levels=c("All clusters", "Clusters with size > 1", "Clusters with size >= 0.05% of reads"))

levels(f$tool)=c("CDHIT","MESHCLUST","SCLUST","SUMACLUST","SWARM","VSEARCH")

ari=ggplot(f,aes(x=tool,y=ARI,fill=type))+geom_boxplot()+labs(x="Tools",y="Adjusted Rand Index",fill="Selected clusters")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),strip.text.x=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14))

recall=ggplot(f,aes(x=tool,y=recall,fill=type))+geom_boxplot()+labs(x="Tools",y="Recall",fill="Selected clusters")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),strip.text.x=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14))

precision=ggplot(f,aes(x=tool,y=precision,fill=type))+geom_boxplot()+labs(x="Tools",y="Precision",fill="Selected clusters")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),strip.text.x=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14))

distance=ggplot(f,aes(x=tool,y=Mean.mean.distance,fill=type))+geom_boxplot()+labs(x="Tools",y="Mean global intra cluster distance",fill="Selected clusters")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),strip.text.x=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14))

number_clusters=ggplot(f,aes(x=tool,y=number_clusters,fill=type))+geom_boxplot()+labs(x="Tools",y="Number of clusters",fill="Selected clusters")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),strip.text.x=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14))

ggsave(file="clusteringEval_RESULTS/tools_comparison/ari_selected_clusters_boxplot.svg",plot=ari,width=11)
pdf("clusteringEval_RESULTS/tools_comparison/ari_selected_clusters_boxplot.pdf",width=11)
ari 
dev.off() 
ggsave(file="clusteringEval_RESULTS/tools_comparison/recall_selected_clusters_boxplot.svg",plot=recall,width=11)
pdf("clusteringEval_RESULTS/tools_comparison/recall_selected_clusters_boxplot.pdf",width=11)
recall
dev.off() 
ggsave(file="clusteringEval_RESULTS/tools_comparison/precision_selected_clusters_boxplot.svg",plot=precision,width=11)
pdf("clusteringEval_RESULTS/tools_comparison/precision_selected_clusters_boxplot.pdf",width=11) 
precision
dev.off()
ggsave(file="clusteringEval_RESULTS/tools_comparison/number_clusters_selected_clusters_boxplot.svg",plot=number_clusters,width=11)
pdf("clusteringEval_RESULTS/tools_comparison/number_clusters_selected_clusters_boxplot.pdf",width=11)
number_clusters
dev.off()
ggsave(file="clusteringEval_RESULTS/tools_comparison/distance_selected_clusters_boxplot.svg",plot=distance,width=11)
pdf("clusteringEval_RESULTS/tools_comparison/distance_selected_clusters_boxplot.pdf",width=11)
distance
dev.off()
save.image(file="clusteringEval_RESULTS/tools_comparison/tools_comparison_selected_clusters.Rdata") 
