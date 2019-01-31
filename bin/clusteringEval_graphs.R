library(ggplot2) 

f=read.table("clusteringEval_TOOL_COMPARISON/all_samples-1000sp-Powerlaw.noChimeras.derep.eval.tsv",header=TRUE,sep="\t") 

f$p_singletons=f$singletons/f$total_clusters*100
f$clusters_no_singletons=f$total_clusters - f$singletons
levels(f$sample)=c("Sample01","Sample02","Sample03","Sample04","Sample05","Sample06","Sample07","Sample08","Sample09","Sample10")

new_f=data.frame(tool=f$tool,sample=f$sample,total_clusters=f$total_clusters,clusters_no_singletons=f$clusters_no_singletons,clusters005=f$clusters_._0.05.reads,recall=f$recall,precision=f$precision,ARI=f$ARI)

write.table(new_f,file="clusteringEval_RESULTS/tools_comparison/tools_comparison_eval.tsv",sep="\t",quote=FALSE,row.names=FALSE)

ari_boxplot=ggplot(f,aes(x=tool,y=ARI,fill=tool))+geom_boxplot()+labs(x="Tools",y="Adjusted Rand Index")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),strip.text.x=element_text(size=16))+guides(fill=FALSE)

precision_boxplot=ggplot(f,aes(x=tool,y=precision,fill=tool))+geom_boxplot()+labs(x="Tools",y="Precision")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),strip.text.x=element_text(size=16))+guides(fill=FALSE)

recall_boxplot=ggplot(f,aes(x=tool,y=recall,fill=tool))+geom_boxplot()+labs(x="Tools",y="Recall")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),strip.text.x=element_text(size=16))+guides(fill=FALSE)

total_clusters_boxplot=ggplot(f,aes(x=tool,y=total_clusters,fill=tool))+geom_boxplot()+labs(x="Tools",y="Number of clusters")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),strip.text.x=element_text(size=16))+guides(fill=FALSE)

singletons_boxplot=ggplot(f,aes(x=tool,y=p_singletons,fill=tool))+geom_boxplot()+labs(x="Tools",y="Singletons (%)")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),strip.text.x=element_text(size=16))+guides(fill=FALSE)

clusters_threshold_boxplot=ggplot(f,aes(x=tool,y=clusters_._0.05.reads,fill=tool))+geom_boxplot()+labs(x="Tools",y="Number of clusters with size >= 0.05% of reads")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),strip.text.x=element_text(size=16))+guides(fill=FALSE)

clusters_no_singletons_boxplot=ggplot(f,aes(x=tool,y=clusters_no_singletons,fill=tool))+geom_boxplot()+labs(x="Tools",y="Number of clusters with size > 1")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),strip.text.x=element_text(size=16))+guides(fill=FALSE)

time_boxplot=ggplot(f,aes(x=tool,y=Time.s.,fill=tool))+geom_boxplot()+labs(x="Tools",y="Time (s)")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),strip.text.x=element_text(size=16))+guides(fill=FALSE)

memory_boxplot=ggplot(f,aes(x=tool,y=Memory.kb./1000,fill=tool))+geom_boxplot()+labs(x="Tools",y="Memory (Mb)")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),strip.text.x=element_text(size=16))+guides(fill=FALSE)

pdf("clusteringEval_RESULTS/tools_comparison/ari_boxplot.pdf")
ari_boxplot
dev.off()

png("clusteringEval_RESULTS/tools_comparison/ari_boxplot.png") 
ari_boxplot
dev.off() 

pdf("clusteringEval_RESULTS/tools_comparison/precision_boxplot.pdf")
precision_boxplot
dev.off()

pdf("clusteringEval_RESULTS/tools_comparison/recall_boxplot.pdf")
recall_boxplot
dev.off() 
 
pdf("clusteringEval_RESULTS/tools_comparison/total_clusters_boxplot.pdf")
total_clusters_boxplot
dev.off() 
 
pdf("clusteringEval_RESULTS/tools_comparison/singletons_boxplot.pdf")
singletons_boxplot 
dev.off() 

png("clusteringEval_RESULTS/tools_comparison/singletons_boxplot.png") 
singletons_boxplot 
dev.off() 

pdf("clusteringEval_RESULTS/tools_comparison/clusters_no_singletons_boxplot.pdf")
clusters_no_singletons_boxplot
dev.off() 

pdf("clusteringEval_RESULTS/tools_comparison/clusters_005_boxplot.pdf")
clusters_threshold_boxplot
dev.off() 

png("clusteringEval_RESULTS/tools_comparison/clusters_005_boxplot.png")
clusters_threshold_boxplot
dev.off() 

pdf("clusteringEval_RESULTS/tools_comparison/time_boxplot.pdf") 
time_boxplot
dev.off() 

png("clusteringEval_RESULTS/tools_comparison/time_boxplot.png")
time_boxplot
dev.off() 

pdf("clusteringEval_RESULTS/tools_comparison/memory_boxplot.pdf") 
memory_boxplot
dev.off() 

