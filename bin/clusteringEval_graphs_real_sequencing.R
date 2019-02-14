library(ggplot2)
f=read.table("clusteringEval_LAKE_DATA/FW_newname_30_06_2015.derep.eval.tsv",header=TRUE,sep="\t") 
levels(f$tool)=c("CDHIT","MESHCLUST","SCLUST","SUMACLUST","SWARM","VSEARCH")

f$p_singletons=((f$number_clusters-f$clusters.size...1)/f$number_clusters)*100 
f_all=data.frame(tool=f$tool,number_clusters=f$number_clusters,type="All clusters")
f_1=data.frame(tool=f$tool,number_clusters=f$clusters.size...1,type="Clusters with size > 1")
f_005=data.frame(tool=f$tool,number_clusters=f$clusters.size...0.005..of.reads,type="Clusters with size >= 0.005% of reads")
f_singletons=data.frame(tool=f$tool,number_clusters=f$singletons,type="Singletons")
f_bind=rbind(f_singletons,f_1)

f_bind$type=factor(f_bind$type,levels=c("Clusters with size > 1", "Singletons"))

plot_number_clusters=ggplot(f_bind,aes(x=tool,y=number_clusters/1000,fill=type))+geom_col()+labs(x="Tools",y="Number of clusters (in thousand)")+scale_fill_manual(values=c("#4c4cff","#b2b2ff"))+theme(axis.text.x=element_text(size=14),plot.title=element_text(size=20),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),strip.text.x=element_text(size=16))
 
plot_percent_singletons=ggplot(f,aes(x=tool,y=p_singletons,fill=tool))+geom_col()+labs(x="Tools",y="% of singletons")+theme(axis.text.x=element_text(size=14),plot.title=element_text(size=20),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),strip.text.x=element_text(size=16))+guides(fill=FALSE)

plot_number_singletons=ggplot(f,aes(x=tool,y=singletons/1000,fill=tool))+geom_col()+labs(x="Tools",y="Number of singletons (in thousand)")+theme(axis.text.x=element_text(size=14),plot.title=element_text(size=20),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),strip.text.x=element_text(size=16))+guides(fill=FALSE)

plot_big_clusters=ggplot(f,aes(x=tool,y=clusters.size...0.005..of.reads,fill=tool))+geom_col()+labs(x="Tools",y="Number of clusters with size >= 0.005% of reads")+theme(axis.text.x=element_text(size=14),plot.title=element_text(size=20),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),strip.text.x=element_text(size=16))+guides(fill=FALSE)

plot_memory=ggplot(f,aes(x=tool,y=Memory/1000000,fill=tool))+geom_col()+labs(x="Tools",y="Max memory (Gb)")+theme(axis.text.x=element_text(size=14),plot.title=element_text(size=20),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),strip.text.x=element_text(size=16))+guides(fill=FALSE)

ggsave(file="clusteringEval_RESULTS/lake_data/number_clusters.svg",plot=plot_number_clusters,width=8)
pdf("clusteringEval_RESULTS/lake_data/number_clusters.pdf",width=12)
plot_number_clusters
dev.off()

ggsave(file="clusteringEval_RESULTS/lake_data/percent_singletons.svg",plot=plot_percent_singletons,width=8)
pdf("clusteringEval_RESULTS/lake_data/percent_singletons.pdf",width=8)
plot_percent_singletons
dev.off()

ggsave(file="clusteringEval_RESULTS/lake_data/number_singletons.svg",plot=plot_number_singletons,width=8)
pdf("clusteringEval_RESULTS/lake_data/number_singletons.pdf",width=8)
plot_number_singletons
dev.off()

ggsave(file="clusteringEval_RESULTS/lake_data/big_clusters.svg",plot=plot_big_clusters,width=8)
pdf("clusteringEval_RESULTS/lake_data/big_clusters.pdf",width=8)
plot_big_clusters
dev.off()

ggsave(file="clusteringEval_RESULTS/lake_data/memory.svg",plot=plot_memory,width=8)
pdf("clusteringEval_RESULTS/lake_data/memory.pdf",width=8)
plot_memory
dev.off()


save.image(file="clusteringEval_RESULTS/lake_data/lake_data.Rdata") 

