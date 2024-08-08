
library(Seurat)
library(SeuratWrappers)
library(Azimuth)
library(ggplot2)
library(ggsci)
library(dplyr)
library(presto)
library(harmony)

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


# library(SeuratData)
# SeuratData::InstallData("pbmcsca")
# obj <- LoadData("pbmcsca")
# saveRDS(obj, file = "obj.rds")

obj <- readRDS("data/obj.rds")
obj <- subset(obj, nFeature_RNA > 1000)
obj <- RunAzimuth(obj, reference = "pbmcref")

#
# 1. unintegrated
#
obj[["RNA"]] <- split(obj[["RNA"]], f = obj$Method)
obj <- NormalizeData(obj)
obj <- FindVariableFeatures(obj)
obj <- ScaleData(obj)
obj <- RunPCA(obj)

obj <- FindNeighbors(obj, dims = 1:30, reduction = "pca")
obj <- FindClusters(obj, resolution = 2, cluster.name = "unintegrated_clusters")

obj <- RunUMAP(obj, dims = 1:30, reduction = "pca", reduction.name = "umap.unintegrated")

p <- DimPlot(obj, 
             reduction = "umap.unintegrated", 
             group.by = c("Method", "predicted.celltype.l2"))
ggsave(paste0("umap.unintegrated.png"), p, width = 14, height = 4.5)

#
# 2. Perform streamlined (one-line) integrative analysis
#
obj <- IntegrateLayers(
  object = obj, method = CCAIntegration,
  orig.reduction = "pca", new.reduction = "integrated.cca",
  verbose = FALSE
)
obj <- IntegrateLayers(
  object = obj, method = RPCAIntegration,
  orig.reduction = "pca", new.reduction = "integrated.rpca",
  verbose = FALSE
)
obj <- IntegrateLayers(
  object = obj, method = HarmonyIntegration,
  orig.reduction = "pca", new.reduction = "harmony",
  verbose = FALSE
)
obj <- IntegrateLayers(
  object = obj, method = FastMNNIntegration,
  new.reduction = "integrated.mnn",
  verbose = FALSE
)
# obj <- IntegrateLayers(
#   object = obj, method = scVIIntegration,
#   new.reduction = "integrated.scvi",
#   conda_env = "/home/renjun/miniconda3/envs/scvi", verbose = FALSE
# )

#
# 3. clustering with different reduction
#
obj <- FindNeighbors(obj, reduction = "integrated.cca", dims = 1:30)
obj <- FindClusters(obj, resolution = 2, cluster.name = "cca_clusters")

obj <- RunUMAP(obj, reduction = "integrated.cca", dims = 1:30, reduction.name = "umap.cca")
p1 <- DimPlot(
  obj,
  reduction = "umap.cca",
  group.by = c("Method", "predicted.celltype.l2", "cca_clusters"),
  combine = FALSE, label.size = 2
)

obj <- FindNeighbors(obj, reduction = "harmony", dims = 1:30)
obj <- FindClusters(obj, resolution = 2, cluster.name = "harmony_clusters")
obj <- RunUMAP(obj, reduction = "harmony", dims = 1:30, reduction.name = "umap.harmony")
p2 <- DimPlot(
  obj,
  reduction = "umap.harmony",
  group.by = c("Method", "predicted.celltype.l2", "harmony_clusters"),
  combine = FALSE, label.size = 2
)

p = wrap_plots(c(p1, p2), ncol = 2, byrow = F)
ggsave("combine.png", p, width = 18, height = 10)

#
# 4. vlnplot with different clustering results
#
p1 <- VlnPlot(
  obj,
  features = "rna_CD8A", group.by = "unintegrated_clusters"
) + NoLegend() + ggtitle("CD8A - Unintegrated Clusters")
p2 <- VlnPlot(
  obj, "rna_CD8A",
  group.by = "cca_clusters"
) + NoLegend() + ggtitle("CD8A - CCA Clusters")
p3 <- VlnPlot(
  obj, "rna_CD8A",
  group.by = "harmony_clusters"
) + NoLegend() + ggtitle("CD8A - harmony Clusters")
p = p1 | p2 | p3
ggsave("combine_vln.png", p, width = 18, height = 5)

#
# 5. dimplot with different reduction
#
obj <- RunUMAP(obj, reduction = "integrated.rpca", dims = 1:30, reduction.name = "umap.rpca")
p4 <- DimPlot(obj, reduction = "umap.unintegrated", group.by = c("cca_clusters"))
p5 <- DimPlot(obj, reduction = "umap.rpca", group.by = c("cca_clusters"))
p6 <- DimPlot(obj, reduction = "umap.harmony", group.by = c("cca_clusters"))
p <- p4 | p5 | p6
ggsave("combine_dim.png", p, width = 18, height = 5)

#
# 6. save rda
#
save(obj, file = "obj.rda")
writeLines(capture.output(sessionInfo()), "sessionInfo.txt")