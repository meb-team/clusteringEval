library(ggplot2) 
library(gridExtra)

f=read.table("clusteringEval_TOOL_COMPARISON/all_samples-1000sp-Powerlaw.noChimeras.derep.eval.tsv",header=TRUE,sep="\t") 

f$p_singletons=f$singletons/f$total_clusters*100
f$clusters_no_singletons=f$total_clusters - f$singletons
levels(f$sample)=c("Sample01","Sample02","Sample03","Sample04","Sample05","Sample06","Sample07","Sample08","Sample09","Sample10")
levels(f$tool)=c("CDHIT","MESHCLUST","SCLUST","SUMACLUST","SWARM","VSEARCH")

new_f=data.frame(tool=f$tool,sample=f$sample,total_clusters=f$total_clusters,clusters_no_singletons=f$clusters_no_singletons,clusters005=f$clusters_._0.05.reads,recall=f$recall,precision=f$precision,ARI=f$ARI)

f_recall=data.frame(tool=f$tool,sample=f$sample,value=f$recall,type="Recall")
f_precision=data.frame(tool=f$tool,sample=f$sample,value=f$precision,type="Precision")
f_recall_precision=rbind(f_recall,f_precision)

total_clusters=data.frame(Tools=f$tool,Sample=f$sample,Number=f$total_clusters,Type="Total clusters")
clusters_no_singletons=data.frame(Tools=f$tool,Sample=f$sample,Number=f$clusters_no_singletons,Type="Clusters size > 1")
clusters_threshold=data.frame(Tools=f$tool,Sample=f$sample,Number=f$clusters_._0.05.reads,Type="Clusters size >= 0.05% of reads")
number_clusters=rbind(total_clusters,clusters_no_singletons,clusters_threshold) 

write.table(new_f,file="clusteringEval_RESULTS/tools_comparison/tools_comparison_eval.tsv",sep="\t",quote=FALSE,row.names=FALSE)

ari_boxplot=ggplot(f,aes(x=tool,y=ARI,fill=tool))+geom_boxplot()+labs(x="Tools",y="Adjusted Rand Index")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),strip.text.x=element_text(size=16))+guides(fill=FALSE)

recall_precision_boxplot=ggplot(f_recall_precision,aes(x=tool,fill=tool,y=value))+geom_boxplot()+coord_flip()+facet_wrap(~type,ncol=1)+labs(x="Tools",y="Value")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),strip.text.x=element_text(size=16))+guides(fill=FALSE)

total_clusters_boxplot=ggplot(f,aes(x=tool,y=total_clusters,fill=tool))+geom_boxplot()+labs(x="Tools",y="Number of clusters")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),strip.text.x=element_text(size=16))+guides(fill=FALSE)

singletons_boxplot=ggplot(f,aes(x=tool,y=p_singletons,fill=tool))+geom_boxplot()+labs(x="Tools",y="Singletons (%)")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),strip.text.x=element_text(size=16))+guides(fill=FALSE)


clusters_threshold_boxplot=ggplot(f,aes(x=tool,y=clusters_._0.05.reads,fill=tool))+geom_boxplot()+labs(x="Tools",y="Number of clusters with size >= 0.05% of reads")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),strip.text.x=element_text(size=16))+guides(fill=FALSE)

clusters_no_singletons_boxplot=ggplot(f,aes(x=tool,y=clusters_no_singletons,fill=tool))+geom_boxplot()+labs(x="Tools",y="Number of clusters with size > 1")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),strip.text.x=element_text(size=16))+guides(fill=FALSE)

number_clusters_boxplot=ggplot(number_clusters,aes(x=Tools,y=Number,fill=Tools))+geom_boxplot()+coord_flip()+facet_wrap(~Type,ncol=1)+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),strip.text.x=element_text(size=16))+guides(fill=FALSE)

time_boxplot=ggplot(f,aes(x=tool,y=Time.s.,fill=tool))+geom_boxplot()+coord_flip()+labs(title="Time",x="Tools",y="Time (s)")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),plot.title=element_text(size=20),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),strip.text.x=element_text(size=16),plot.margin=unit(c(0.5,1,0.5,0.5),"cm"))+guides(fill=FALSE)

memory_boxplot=ggplot(f,aes(x=tool,y=Memory.kb./1000,fill=tool))+geom_boxplot()+coord_flip()+labs(title="Memory",x="Tools",y="Memory (Mb)")+theme(axis.text.x=element_text(size=14),plot.title=element_text(size=20),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),strip.text.x=element_text(size=16),plot.margin=unit(c(0.5,1,0.5,0.5),"cm"))+guides(fill=FALSE)

ggsave(file="clusteringEval_RESULTS/tools_comparison/ari_boxplot.svg",plot=ari_boxplot,width=8)
ggsave(file="clusteringEval_RESULTS/tools_comparison/precision_recall.svg",plot=recall_precision_boxplot)
ggsave(file="clusteringEval_RESULTS/tools_comparison/singletons_boxplot.svg",plot=singletons_boxplot,width=8) 
ggsave(file="clusteringEval_RESULTS/tools_comparison/number_clusters.svg",number_clusters_boxplot,height=8) 
time_memory=grid.arrange(time_boxplot,memory_boxplot,ncol=1)
ggsave(file="clusteringEval_RESULTS/tools_comparison/time_memory.svg",plot=time_memory,height=8) 

