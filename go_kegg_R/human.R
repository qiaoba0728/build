# 安装包
source("https://bioconductor.org/biocLite.R")

BiocManager::install("clusterProfiler")  #用来做富集分析
BiocManager::install("topGO")  #画GO图用的
BiocManager::install("Rgraphviz")
BiocManager::install("pathview") #看KEGG pathway的
BiocManager::install("org.Hs.eg.db") #这个包里存有人的注释文件

# 载入包dian
library(clusterProfiler)
library(topGO)
library(Rgraphviz)
library(pathview)
library(org.Hs.eg.db)
DEG.gene_symbol = as.character(output.gene_id$gene_id) #获得基因 symbol ID
DEG.entrez_id = mapIds(x = org.Hs.eg.db,
                       keys = DEG.gene_symbol,
                       keytype = "SYMBOL",
                       column = "ENTREZID")
DEG.entrez_id = na.omit(DEG.entrez_id)

erich.go.BP = enrichGO(gene = DEG.entrez_id,
                       OrgDb = org.Hs.eg.db,
                       keyType = "ENTREZID",
                       ont = "BP",
                       pvalueCutoff = 0.5,
                       qvalueCutoff = 0.5)

##分析完成后，作图
dotplot(erich.go.BP)
plotGOgraph(erich.go.BP)


erich.go.CC = enrichGO(gene = DEG.entrez_id,
                       OrgDb = org.Hs.eg.db,
                       keyType = "ENTREZID",
                       ont = "CC",
                       pvalueCutoff = 0.5,
                       qvalueCutoff = 0.5)

##分析完成后，作图
dotplot(erich.go.CC)
plotGOgraph(erich.go.CC)

erich.go.MF = enrichGO(gene = DEG.entrez_id,
                       OrgDb = org.Hs.eg.db,
                       keyType = "ENTREZID",
                       ont = "MF",
                       pvalueCutoff = 0.5,
                       qvalueCutoff = 0.5)

##分析完成后，作图
dotplot(erich.go.MF)
plotGOgraph(erich.go.MF)