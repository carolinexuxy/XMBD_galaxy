# XMBD galaxy

This repo is dedicated to XMBD's [galaxy server](https://usegalaxy.org/), its implementation, and resources. 

For information about current server and associated tools, please read server.md. 

For information for seurat tool development, please see tool_development.md

For more, please see resources.md for links.


## Introduction 

Galaxy is a open-source platform for biomedical research. It makes 

* Easy access: 

    With tool launched on this platform, you can access it anywhere anytime while the server is up running. And anyone can access it. 

* Easy usage: 

    Codes are separted from the UI. With simple and clean GUI, those who are less experienced with computing knowledge can easily navigate themselves through different tool, and execution is just one click away after filling in the parameters. 

* Less redundent: 

    No repeated actions needed (besides the Run button)! Simply create workflow to connect your commonly-used tools to create a pipeline. Save your manual work. 


## Launch Server 
> cd ~/galaxy
>
> sh run.sh 
>
> \# wait for the following message 
> 
> serving on http://172.27.125.11:8084

## Re-install Server 

To re-install server, follow the instructions on [get galaxy page](https://galaxyproject.org/admin/get-galaxy/).
