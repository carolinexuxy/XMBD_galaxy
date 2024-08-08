# setwd("~/project/sc_standard_procedure/Seurat/3.0.0")
# source("~/project/sc_standard_procedure/index_function.R")
# source("~/project/sc_standard_procedure/theme.R")

library(Seurat)
library(ggplot2)
library(ggsci)
library(dplyr)
library(presto)

rj.ftheme <- theme(panel.background = element_rect(fill='transparent', color="black"),
                   strip.text = element_text(size = 18),
                   panel.grid.minor=element_blank(),
                   panel.grid.major=element_blank(),
                   panel.border = element_rect(fill='transparent', color='black'),
                   plot.title = element_text(size = 16, hjust = 0),
                   plot.subtitle = element_text(size = 16, hjust = 0),
                   legend.key = element_blank(),
                   legend.background = element_blank(),
                   legend.text = element_text(vjust = 0.4, size = 14, colour = 'black'),
                   legend.title = element_text(vjust = 0.4, size = 14, colour = 'black'),
                   axis.title.x = element_text(vjust = -1.5, size = 15, colour = 'black'),
                   axis.title.y = element_text(vjust = 1.5, size = 15, colour = 'black'),
                   axis.ticks = element_blank(),
                   axis.text.x = element_text(vjust = -0.5, size = 14, colour = 'black'),
                   axis.text.y = element_text(vjust = 0.5, size = 14, colour = 'black'),
                   plot.margin = unit(c(0.5,0.5,0.5,0.5), "cm"))

#
# 1. create
#
pbmc.data <- Read10X(data.dir = "./data/hg19")
pbmc <- CreateSeuratObject(counts = pbmc.data, project = "pbmc3k", min.cells = 3, min.features = 200)

#
# 2. normalization 
#
pbmc <- NormalizeData(pbmc, normalization.method = "LogNormalize", scale.factor = 10000)
pbmc[["percent.mt"]] <- PercentageFeatureSet(pbmc, pattern = "^MT-")
#---factors that can be considered based on different data
#---pbmc[["batch"]]
#---pbmc[["percent.blood"]]

#
# 3. filter
#
p <- VlnPlot(object = pbmc, features = c("nFeature_RNA", "nCount_RNA", "percent.mt"))
ggsave("vlnplot.png", p, width = 10, height = 7)

plot1 <- FeatureScatter(object = pbmc, feature1 = "nCount_RNA", feature2 = "percent.mt")
plot2 <- FeatureScatter(object = pbmc, feature1 = "nCount_RNA", feature2 = "nFeature_RNA")
ggsave("nCount_RNA.png", CombinePlots(plots = list(plot1, plot2)), width = 10, height = 5)

pbmc <- subset(pbmc, subset = nFeature_RNA > 200 & nFeature_RNA < 2500 & percent.mt < 5)

#
# 4. find variable features
#
#---vst: counts
#---mean.var.plot: data
#---dispersion: data
pbmc <- FindVariableFeatures(object = pbmc, selection.method = "vst", nfeatures = 2000)
top10 <- head(x = VariableFeatures(object = pbmc), 10)
plot1 <- VariableFeaturePlot(object = pbmc)
plot2 <- LabelPoints(plot = plot1, points = top10, repel = TRUE)

ggsave("VariableFeatures.png", CombinePlots(plots = list(plot1, plot2)), width = 12, height = 6)

#
# 5. scale without regress 
#
all.genes <- rownames(x = pbmc)
pbmc <- ScaleData(object = pbmc, features = all.genes)

#
# 6. pca
#
pbmc <- RunPCA(pbmc, features = VariableFeatures(object = pbmc))
ggsave("pca.png",  DimPlot(pbmc, reduction = "pca"), width = 5, height = 5)
ggsave("feature_loading.png",  VizDimLoadings(object = pbmc, dims = 1:2), width = 8, height = 6)

#
# 7. determine how many pca to do the following work
#
# pbmc <- JackStraw(pbmc, reduction = "pca", dims = 30, num.replicate = 100)
# pbmc <- ScoreJackStraw(pbmc, dims = 1:30, reduction = "pca", do.plot = FALSE)
# ggsave("JackStrawPlot.png", JackStrawPlot(object = pbmc, dims = 1:30, reduction = "pca"))
ggsave("PCElbowPlot.png", ElbowPlot(object = pbmc, ndims = 30, reduction = "pca"))

#
# 8. clustering
#
res <- 0.5
pc_num <- 10

pbmc <- FindNeighbors(object = pbmc, reduction = "pca", dims = 1:pc_num)
pbmc <- FindClusters(object = pbmc, resolution = res )
    
#
# 9. dimensionality reduction
#
pbmc <- RunTSNE(object = pbmc, reduction = "pca", dims = 1:pc_num)
pbmc <- RunUMAP(object = pbmc, reduction = "pca", dims = 1:pc_num)

#
# 10. find all markers
#
Idents(pbmc) <- pbmc@meta.data[,paste0("RNA_snn_res.", res)]
pbmc[["seurat_clusters"]] <-Idents(pbmc)
marker <- FindAllMarkers(pbmc, only.pos = F, min.pct = 0.25, logfc.threshold = 0.25)
top10 <- marker %>% group_by(cluster) %>% top_n(n = 10, wt = avg_log2FC)
write.csv(marker, file = "marker.csv")

#
# 11. plot
#
p1 <- VlnPlot(pbmc, features = c("MS4A1", "GNLY", "CD3E", "CD14", "FCER1A", "FCGR3A", 
                                 "LYZ", "PPBP", "CD8A","IL7R","CCR7","S100A4"), ncol = 4)
p2 <- FeaturePlot(pbmc, features = c("MS4A1", "GNLY", "CD3E", "CD14", "FCER1A", "FCGR3A", 
                                     "LYZ", "PPBP", "CD8A","IL7R","CCR7","S100A4"), ncol = 4)

ggsave(paste0("vln_features2.png"), p1, width = 15, height = 12)
ggsave(paste0("UMAP_features.png"), p2, width = 15, height = 12)

p <- DimPlot(pbmc, reduction="umap", label = TRUE, pt.size = 1) + 
  scale_colour_d3("category20") +
  rj.ftheme
ggsave(paste0("UMAP_cluster.png"), p, width = 5, height = 4.5)

p <- DimPlot(pbmc, reduction="tsne", label = TRUE, pt.size = 1) + 
  scale_colour_d3("category20") +
  rj.ftheme
ggsave(paste0("tSNE_cluster.png"), p, width = 5, height = 4.5)

p <- DoHeatmap(pbmc, features = top10$gene, label = F) 
ggsave("heatmap_features.png", p, width = 15, height = 10)

#
# 12. add annotation
#
new.cluster.ids <- c("Naive CD4 T", "Memory CD4 T", "CD14+ Mono", "B", "CD8 T", "FCGR3A+ Mono", 
                     "NK", "DC", "Platelet")
names(new.cluster.ids) <- levels(pbmc)
pbmc <- RenameIdents(pbmc, new.cluster.ids)

p <- DimPlot(pbmc, reduction="umap", label = TRUE, pt.size = 1.5) + 
  scale_colour_d3("category20") +
  rj.ftheme
ggsave(paste0("UMAP_celltype.png"), p, width = 6.5, height = 4.5)

#
# 13. save rda
#
save(pbmc, file = "pbmc.rda")

