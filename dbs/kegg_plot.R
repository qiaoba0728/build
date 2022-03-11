### ClusterProfiler进行富集分析
#安装clusterProfiler包
args=commandArgs(T)
print(args[1])
print(args[2])
BiocManager::install("clusterProfiler")
library(clusterProfiler)
### 准备pathway注释文件
data <- read.table(args[1], header = T, sep = "\t")
go2gene <- data[, c(2, 1)]
go2name <- data[, c(2, 3)]
### 准备差异基因列表文件
genelist <- read.table(args[2], header = T,sep = "\t")
### 差异基因ID向量
gene <- as.factor(genelist$Gene)
### sorted vector: number should be sorted in decreasing order
gene <- sort(gene, decreasing = TRUE)
### ORA（Over-Representation Analysis）
kk <- enricher(gene,TERM2GENE = go2gene,TERM2NAME = go2name, pvalueCutoff  = 0.05,
               pAdjustMethod  = "BH",
               minGSSize = 5,
               qvalueCutoff  = 0.5)
write.table(kk, file = "diff-keggenricher.txt", quote =F, sep = "\t", row.names = F)
