# Tool Development 

## Tool development overview 
Tool development on galaxy consists of three major components: 

### Your Script 
In order to load your tool onto the galaxy platform, please have your script/algorithm/executables placed on the server within the galaxy folder. 

### Tool Wrapper 
Galaxy requires a tool wrapper written in XML to recognize the tool and load necessary inputs and parameters for execution.     

For guidelines about how to construct this wrapper, please visit the official page on [Galaxy XML Tool File](https://docs.galaxyproject.org/en/release_24.0/dev/schema.html).

Once the wrapper file is ready, please place it under: 
> ~/galaxy/tools/

### tool_conf.xml 

Upon launching, the server uses ~/galaxy/config/tool_conf.xml to recognize which tools to load. This file should consists all tools that you wish to load in and points to the location of the tools' wrapper file. 

Once tool wrapper and tool scripts are ready on the server. Please create a new entry in the format of 
> \<tool file="path-from-tools-folder-to-wrapper/wrapper-name.xml"/>

under the a newly created or desired section. 

Upon relaunching the server, this tool will appears under the section you assign it to if no errors are found when compiling the tool's interface. 


## Planemo 

[Planemo](https://github.com/galaxyproject/planemo) is a command-line tool that assists the development of galaxy's tool, workflow, and training. This could be a great resources to:

* verify tool wrapper correctiveness 
    
    upon tool creation, launch planemo and try linting 
        
    > planemo l tool-wrapper.xml 
    
    to view any error, warnings, and success message 

* run tool tests 

* and more


### Other Tool Sources 

Galaxy also hosts many published tools that can be installed into each server on-demand. The Galaxy Tool Shed  continas ~10000 tools that are published and public. 

To add a new tool from the tool shed to our server: 

1. lunch server 

2. log in with admin account 

3. navigate to Admin -> Tool Mangement -> Install and Uninstall

4. Search for the tool that is neededf 

5. Install to the desired section 

6. Ready to use!
