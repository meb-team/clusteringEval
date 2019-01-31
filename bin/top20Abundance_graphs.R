library(ggplot2) 
library(gridExtra)

f1=read.table("clusteringEval_DATA/sample01-1000sp-Powerlaw.noChimeras.derep.abundance.tsv",header=TRUE,sep="\t") 
f2=read.table("clusteringEval_DATA/sample02-1000sp-Powerlaw.noChimeras.derep.abundance.tsv",header=TRUE,sep="\t") 
f3=read.table("clusteringEval_DATA/sample03-1000sp-Powerlaw.noChimeras.derep.abundance.tsv",header=TRUE,sep="\t") 
f4=read.table("clusteringEval_DATA/sample04-1000sp-Powerlaw.noChimeras.derep.abundance.tsv",header=TRUE,sep="\t") 
f5=read.table("clusteringEval_DATA/sample05-1000sp-Powerlaw.noChimeras.derep.abundance.tsv",header=TRUE,sep="\t") 
f6=read.table("clusteringEval_DATA/sample06-1000sp-Powerlaw.noChimeras.derep.abundance.tsv",header=TRUE,sep="\t") 
f7=read.table("clusteringEval_DATA/sample07-1000sp-Powerlaw.noChimeras.derep.abundance.tsv",header=TRUE,sep="\t") 
f8=read.table("clusteringEval_DATA/sample08-1000sp-Powerlaw.noChimeras.derep.abundance.tsv",header=TRUE,sep="\t") 
f9=read.table("clusteringEval_DATA/sample09-1000sp-Powerlaw.noChimeras.derep.abundance.tsv",header=TRUE,sep="\t") 
f10=read.table("clusteringEval_DATA/sample10-1000sp-Powerlaw.noChimeras.derep.abundance.tsv",header=TRUE,sep="\t")

f1$sample="Sample01"
f2$sample="Sample02"
f3$sample="Sample03"
f4$sample="Sample04"
f5$sample="Sample05"
f6$sample="Sample06"
f7$sample="Sample07"
f8$sample="Sample08"
f9$sample="Sample09"
f10$sample="Sample10"

top20_f1=head(f1[with(f1,order(-Abundance)),],n=20) 
top20_f2=head(f2[with(f2,order(-Abundance)),],n=20) 
top20_f3=head(f3[with(f3,order(-Abundance)),],n=20) 
top20_f4=head(f4[with(f4,order(-Abundance)),],n=20) 
top20_f5=head(f5[with(f5,order(-Abundance)),],n=20) 
top20_f6=head(f6[with(f6,order(-Abundance)),],n=20) 
top20_f7=head(f7[with(f7,order(-Abundance)),],n=20) 
top20_f8=head(f8[with(f8,order(-Abundance)),],n=20) 
top20_f9=head(f9[with(f9,order(-Abundance)),],n=20) 
top20_f10=head(f10[with(f10,order(-Abundance)),],n=20) 

pdf("clusteringEval_RESULTS/abundance_samples.pdf",width=9,height=11) 
plot1=ggplot(top20_f1,aes(x=reorder(Specie.strain,Abundance),y=Abundance))+geom_bar(stat="identity")+coord_flip()+labs(title="Sample01",y="Abundance (number of reads)",x="Strain")+theme(plot.title=element_text(size=20),axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16))

plot2=ggplot(top20_f2,aes(x=reorder(Specie.strain,Abundance),y=Abundance))+geom_bar(stat="identity")+coord_flip()+labs(title="Sample02",y="Abundance (number of reads)",x="Strain")+theme(plot.title=element_text(size=20),axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16))

grid.arrange(plot1,plot2)

plot3=ggplot(top20_f3,aes(x=reorder(Specie.strain,Abundance),y=Abundance))+geom_bar(stat="identity")+coord_flip()+labs(title="Sample03",y="Abundance (number of reads)",x="Strain")+theme(plot.title=element_text(size=20),axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16))

plot4=ggplot(top20_f4,aes(x=reorder(Specie.strain,Abundance),y=Abundance))+geom_bar(stat="identity")+coord_flip()+labs(title="Sample04",y="Abundance (number of reads)",x="Strain")+theme(plot.title=element_text(size=20),axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16))

grid.arrange(plot3,plot4)

plot5=ggplot(top20_f5,aes(x=reorder(Specie.strain,Abundance),y=Abundance))+geom_bar(stat="identity")+coord_flip()+labs(title="Sample05",y="Abundance (number of reads)",x="Strain")+theme(plot.title=element_text(size=20),axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16))

plot6=ggplot(top20_f6,aes(x=reorder(Specie.strain,Abundance),y=Abundance))+geom_bar(stat="identity")+coord_flip()+labs(title="Sample06",y="Abundance (number of reads)",x="Strain")+theme(plot.title=element_text(size=20),axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16))

grid.arrange(plot5,plot6)

plot7=ggplot(top20_f7,aes(x=reorder(Specie.strain,Abundance),y=Abundance))+geom_bar(stat="identity")+coord_flip()+labs(title="Sample07",y="Abundance (number of reads)",x="Strain")+theme(plot.title=element_text(size=20),axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16))

plot8=ggplot(top20_f8,aes(x=reorder(Specie.strain,Abundance),y=Abundance))+geom_bar(stat="identity")+coord_flip()+labs(title="Sample08",y="Abundance (number of reads)",x="Strain")+theme(plot.title=element_text(size=20),axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16))

grid.arrange(plot7,plot8)

plot9=ggplot(top20_f9,aes(x=reorder(Specie.strain,Abundance),y=Abundance))+geom_bar(stat="identity")+coord_flip()+labs(title="Sample09",y="Abundance (number of reads)",x="Strain")+theme(plot.title=element_text(size=20),axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16))

plot10=ggplot(top20_f10,aes(x=reorder(Specie.strain,Abundance),y=Abundance))+geom_bar(stat="identity")+coord_flip()+labs(title="Sample10",y="Abundance (number of reads)",x="Strain")+theme(plot.title=element_text(size=20),axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16))

grid.arrange(plot9,plot10)

dev.off() 
