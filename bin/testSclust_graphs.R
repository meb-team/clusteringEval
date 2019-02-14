library(ggplot2)  
library(gridExtra) 

f=read.table("clusteringEval_TEST_SCLUST/testSclust_all_samples-1000sp-Powerlaw.noChimeras.derep.eval.tsv",header=TRUE,sep="\t") 
f$quality=factor(f$quality) 
levels(f$sample)=c("Sample01","Sample02","Sample03","Sample04","Sample05","Sample06","Sample07","Sample08","Sample09","Sample10")
levels(f$algo)=c("Accurate","Default") 
f$p_singletons=(1-(f$clusters.size...1/f$total_clusters))*100

f_recall=data.frame(tool=f$tool,sample=f$sample,value=f$recall,type="Recall",threshold=f$threshold.d,algo=f$algo,quality=f$quality)
f_precision=data.frame(tool=f$tool,sample=f$sample,value=f$precision,type="Precision",threshold=f$threshold.d,algo=f$algo,quality=f$quality)
f_recall_precision=rbind(f_recall,f_precision)

ari_all=ggplot(f,aes(x=threshold.d,y=ARI,color=quality,linetype=algo))+geom_point()+geom_line()+facet_wrap(~sample,ncol=5)+labs(color="Quality",x="Clustering threshold (%)",y="Adjusted Rand Index",linetype="Mode")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14),strip.text.x=element_text(size=16))

recall_all=ggplot(f,aes(x=threshold.d,y=recall,color=quality,linetype=algo))+geom_point()+geom_line()+facet_wrap(~sample,ncol=5)+labs(title="Recall",color="Quality",x="Clustering threshold (%)",y="Recall",linetype="Mode")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14),strip.text.x=element_text(size=16),plot.title=element_text(size=20))

precision_all=ggplot(f,aes(x=threshold.d,y=precision,color=quality,linetype=algo))+geom_point()+geom_line()+facet_wrap(~sample,ncol=5)+labs(title="Precision",color="Quality",x="Clustering threshold (%)",y="Precision",linetype="Mode")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14),strip.text.x=element_text(size=16),plot.title=element_text(size=20))

singletons_all=ggplot(f,aes(x=threshold.d,y=p_singletons,color=quality,linetype=algo))+geom_point()+geom_line()+facet_wrap(~sample,ncol=5)+labs(color="Quality",x="Clustering threshold (%)",y="Singletons (%)",linetype="Mode")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14),strip.text.x=element_text(size=16))

number_singletons_all=ggplot(f,aes(x=threshold.d,y=singletons,color=quality,linetype=algo))+geom_point()+geom_line()+facet_wrap(~sample,ncol=5)+labs(color="Quality",x="Clustering threshold (%)",y="Number of singletons",linetype="Mode")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14),strip.text.x=element_text(size=16))

distance_all=ggplot(f,aes(x=threshold.d,y=Mean.mean.distance,color=quality,linetype=algo))+geom_point()+geom_line()+facet_wrap(~sample,ncol=5)+labs(color="Quality",x="Clustering threshold (%)",y="Mean global intra cluster distance",linetype="Mode")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14),strip.text.x=element_text(size=16))

f$threshold.d=factor(f$threshold.d)

ari_boxplot=ggplot(f,aes(x=threshold.d,y=ARI,fill=quality))+geom_boxplot()+facet_wrap(~algo,ncol=1)+labs(fill="Quality",x="Clustering threshold (%)",y="Ajusted Rand Index")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14),strip.text.x=element_text(size=16))

recall_precision_boxplot=ggplot(f_recall_precision,aes(x=threshold,y=value,fill=quality))+geom_boxplot()+facet_grid(algo~type)+labs(fill="Quality",x="Clustering threshold (%)",y="Value")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14),strip.text.x=element_text(size=16),strip.text.y=element_text(size=16))

singletons_boxplot=ggplot(f,aes(x=threshold.d,y=p_singletons,fill=quality))+geom_boxplot()+facet_wrap(~algo,ncol=1)+labs(fill="Quality",x="Clustering threshold (%)",y="Singletons (%)")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14),strip.text.x=element_text(size=16))

number_singletons_boxplot=ggplot(f,aes(x=threshold.d,y=singletons,fill=quality))+geom_boxplot()+facet_wrap(~algo,ncol=1)+labs(fill="Quality",x="Clustering threshold (%)",y="Number of singletons")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14),strip.text.x=element_text(size=16))

distance_boxplot=ggplot(f,aes(x=threshold.d,y=Mean.mean.distance,fill=quality))+geom_boxplot()+facet_wrap(~algo,ncol=1)+labs(fill="Quality",x="Clustering threshold (%)",y="Mean global intra cluster distance")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14),strip.text.x=element_text(size=16))

time_boxplot=ggplot(f,aes(x=threshold.d,y=Time.s.,fill=quality))+geom_boxplot()+facet_wrap(~algo,ncol=1)+labs(fill="Quality",x="Clustering threshold (%)",y="Time (s)")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14),strip.text.x=element_text(size=16))

memory_boxplot=ggplot(f,aes(x=threshold.d,y=Time.s.,fill=quality))+geom_boxplot()+facet_wrap(~algo,ncol=1)+labs(fill="Quality",x="Clustering threshold (%)",y="Time (s)")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14),strip.text.x=element_text(size=16))

ggsave(file="clusteringEval_RESULTS/test_SCLUST/ari_all.svg",plot=ari_all,width=12)
pdf("clusteringEval_RESULTS/test_SCLUST/ari_all.pdf",width=12)
ari_all
dev.off()
recall_precision_all=grid.arrange(recall_all,precision_all)
ggsave(file="clusteringEval_RESULTS/test_SCLUST/recall_precision_all.svg",plot=recall_precision_all,width=12,height=12)
pdf("clusteringEval_RESULTS/test_SCLUST/recall_all.pdf",width=12,height=12)
recall_all
dev.off()
pdf("clusteringEval_RESULTS/test_SCLUST/precision_all.pdf",width=12,height=12)
precision_all
dev.off()
ggsave(file="clusteringEval_RESULTS/test_SCLUST/singletons_all.svg",plot=singletons_all,width=12)
pdf("clusteringEval_RESULTS/test_SCLUST/singletons_all.pdf",width=12)
singletons_all
dev.off()
ggsave(file="clusteringEval_RESULTS/test_SCLUST/number_singletons_all.svg",plot=number_singletons_all,width=12)
pdf("clusteringEval_RESULTS/test_SCLUST/number_singletons_all.pdf",width=12)
number_singletons_all
dev.off()
ggsave(file="clusteringEval_RESULTS/test_SCLUST/distance_all.svg",plot=distance_all,width=12)
pdf("clusteringEval_RESULTS/test_SCLUST/distance_all.pdf",width=12)
distance_all
dev.off()
ggsave(file="clusteringEval_RESULTS/test_SCLUST/ari_boxplot.svg",plot=ari_boxplot,height=8)
pdf("clusteringEval_RESULTS/test_SCLUST/ari_boxplot.pdf",height=8)
ari_boxplot
dev.off()
ggsave(file="clusteringEval_RESULTS/test_SCLUST/recall_precision_boxplot.svg",plot=recall_precision_boxplot) 
pdf("clusteringEval_RESULTS/test_SCLUST/recall_precision_boxplot.pdf")
recall_precision_boxplot
dev.off()
ggsave(file="clusteringEval_RESULTS/test_SCLUST/singletons_boxplot.svg",plot=singletons_boxplot,height=8) 
pdf("clusteringEval_RESULTS/test_SCLUST/singletons_boxplot.pdf",height=8)
singletons_boxplot
dev.off()
ggsave(file="clusteringEval_RESULTS/test_SCLUST/number_singletons_boxplot.svg",plot=number_singletons_boxplot,height=8) 
pdf("clusteringEval_RESULTS/test_SCLUST/number_singletons_boxplot.pdf",height=8)
number_singletons_boxplot
dev.off()
ggsave(file="clusteringEval_RESULTS/test_SCLUST/distance_boxplot.svg",plot=distance_boxplot,height=8) 
pdf("clusteringEval_RESULTS/test_SCLUST/distance_boxplot.pdf",height=8)
distance_boxplot
dev.off() 
ggsave(file="clusteringEval_RESULTS/test_SCLUST/time_boxplot.svg",plot=time_boxplot,height=8) 
pdf("clusteringEval_RESULTS/test_SCLUST/time_boxplot.pdf",height=8)
time_boxplot 
dev.off() 
ggsave(file="clusteringEval_RESULTS/test_SCLUST/memory_boxplot.svg",plot=memory_boxplot,height=8) 
pdf("clusteringEval_RESULTS/test_SCLUST/memory_boxplot.pdf",height=8)
memory_boxplot 
dev.off() 
save.image(file="clusteringEval_RESULTS/test_SCLUST/test_SCLUST.Rdata") 


