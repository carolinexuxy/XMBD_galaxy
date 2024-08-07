# Current Galaxy Server 

The current galaxy server for XMBD is located on server 172.27.125.11, port 8084, current version 20.09. 

To launch the server, ssh into server 172.27.125.11: 

> cd ~/galaxy
>
> sh run.sh 
>
> \# wait for the following message 
> 
> serving on http://172.27.125.11:8084

## Admin Account 
### Existing Admin Account 
> username: test1
>
> password: testing

### Create Admin Account 
To create admin account/give admin access to other account: 

1. create a new account 
2. In the galaxy folder: 

    > cd config 
    >
    > vim galaxy.yml
    >
    >\# find the admin_user section
    >
    >\# append account's associated email to the end of the comma-separated list.
3. Re-start the server 


## Sample Tools

The current server contains several sample tools.

1. E-SpotFinder under XMBDToolbox section

2. Under Seurat Section: 

    * Seurat Percentage Feature Set

    * Seurat Feature Scatter

    * Seurat Subset 

    * Seurat FindVariableFeatures 

    * Seurat Rename 

    * Seurat VariableFeatures 

    * Seurat VariableFeaturePlot

    * Seurat LabelPoints 

    * Rownames 

    * Seurat VizDimLoadings 

    * Seurat Elbow Plot 

    * Seurat Extract Metadata 

    * Seurat Ident 

    * Seurat FindAllMarkers 

    * Seurat Filter Markers 

The above tools are created for the purpose of testing server performance and edge behaviors with inputs/outputs, some sections are not implmented to their fullest extend. If you wish to reuse these tools for the long term, it is advice that you complete some of the missing components (e.g. test, help message, citation, athor) before proceeding. 

### For Seurat Tools
The seurat tools listed above are created in the styles of [existing seurat tools](https://github.com/ebi-gene-expression-group/container-galaxy-sc-tertiary/tree/main/tools/tertiary-analysis/seurat) on galaxy, including Plot, RunPCA, and Scale Data, created by the EBI Gene Expression Team. A small part of their  [seurat_macros](https://github.com/ebi-gene-expression-group/container-galaxy-sc-tertiary/blob/main/tools/tertiary-analysis/seurat/seurat_macros.xml) has been reused in the new tool development for convenience and similar layout. 






