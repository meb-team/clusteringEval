library(ggplot2)  

f=read.table("clusteringEval_TEST_SCLUST/testSclust.eval.tsv",header=TRUE,sep="\t") 
f$quality=factor(f$quality) 
levels(f$sample)=c("Sample01","Sample02","Sample03","Sample04","Sample05","Sample06","Sample07","Sample08","Sample09","Sample10")
f$p_singletons=f$singletons/f$total_clusters*100

ari_all=ggplot(f,aes(x=threshold.d,y=ARI,color=quality,linetype=algo))+geom_point()+geom_line()+facet_wrap(~sample)+labs(color="Quality",x="Clustering threshold (%)",y="Adjusted Rand Index",linetype="Algo")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14),strip.text.x=element_text(size=16))

recall_all=ggplot(f,aes(x=threshold.d,y=recall,color=quality,linetype=algo))+geom_point()+geom_line()+facet_wrap(~sample)+labs(color="Quality",x="Clustering threshold (%)",y="Recall",linetype="Algo")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14),strip.text.x=element_text(size=16))

precision_all=ggplot(f,aes(x=threshold.d,y=precision,color=quality,linetype=algo))+geom_point()+geom_line()+facet_wrap(~sample)+labs(color="Quality",x="Clustering threshold (%)",y="Precision",linetype="Algo")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14),strip.text.x=element_text(size=16))

singletons_all=ggplot(f,aes(x=threshold.d,y=p_singletons,color=quality,linetype=algo))+geom_point()+geom_line()+facet_wrap(~sample)+labs(color="Quality",x="Clustering threshold (%)",y="Singletons (%)",linetype="Algo")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14),strip.text.x=element_text(size=16))

f$threshold.d=factor(f$threshold.d)
levels(f$algo)=c("All database","Default") 

ari_boxplot=ggplot(f,aes(x=threshold.d,y=ARI,fill=quality))+geom_boxplot()+facet_wrap(~algo,ncol=1)+labs(fill="Quality",x="Clustering threshold (%)",y="Ajusted Rand Index")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14),strip.text.x=element_text(size=16))

recall_boxplot=ggplot(f,aes(x=threshold.d,y=recall,fill=quality))+geom_boxplot()+facet_wrap(~algo,ncol=1)+labs(fill="Quality",x="Clustering threshold (%)",y="Recall")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14),strip.text.x=element_text(size=16))

precision_boxplot=ggplot(f,aes(x=threshold.d,y=precision,fill=quality))+geom_boxplot()+facet_wrap(~algo,ncol=1)+labs(fill="Quality",x="Clustering threshold (%)",y="Precision")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14),strip.text.x=element_text(size=16))

singletons_boxplot=ggplot(f,aes(x=threshold.d,y=p_singletons,fill=quality))+geom_boxplot()+facet_wrap(~algo,ncol=1)+labs(fill="Quality",x="Clustering threshold (%)",y="Singletons (%)")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14),strip.text.x=element_text(size=16))


pdf("clusteringEval_GRAPHS/test_SCLUST/ari_all.pdf",width=12)
ari_all 
dev.off() 

pdf("clusteringEval_GRAPHS/test_SCLUST/recall_all.pdf",width=12)
recall_all 
dev.off()

pdf("clusteringEval_GRAPHS/test_SCLUST/precision_all.pdf",width=12)
precision_all 
dev.off()

pdf("clusteringEval_GRAPHS/test_SCLUST/singletons_all.pdf",width=12)
singletons_all 
dev.off()

pdf("clusteringEval_GRAPHS/test_SCLUST/ari_boxplot.pdf",height=10)
ari_boxplot 
dev.off() 

pdf("clusteringEval_GRAPHS/test_SCLUST/recall_boxplot.pdf")
recall_boxplot 
dev.off()

pdf("clusteringEval_GRAPHS/test_SCLUST/precision_boxplot.pdf")
precision_boxplot 
dev.off()

pdf("clusteringEval_GRAPHS/test_SCLUST/singletons_boxplot.pdf")
singletons_boxplot 
dev.off()

save.image(file="clusteringEval_GRAPHS/test_SCLUST/test_SCLUST.Rdata") 


