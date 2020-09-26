# MAGnet
The Myocardial Applied Genomics Network [MAGNet](www.med.upenn.edu/magnet) is a collaborative effort by a group of investigators to understand human myocardial disease using genomic approaches. 

# Data Analysis
[MAGNet](www.med.upenn.edu/magnet) harvested human cardiac tissue from patients with heart failure undergoing transplantation as well as donor hearts with normal function but unviable for transplant.  RNA Sequencing libraries we prepared from the RNA extracted from these samples and sequenced. The data analysis pipeline can be found [here](https://github.com/mpmorley/MAGNet)


# Visualization
The MAGNet Browser is an easy-to-use application that utilizes the R Shiny framework to make the data easily accessible to the users as well as provide an interactive platform to look at the results of differential expression and eQTL analysis

# Requirements
- R (version > 3.4)
- RStudio Server
- Shiny Server (if you need to host it online)

If you need help installing the above or getting started, refer to [this](https://deanattali.com/2015/05/09/setup-rstudio-shiny-server-digital-ocean/#install-r)

# Installation
Run the following commands in R to install all required packages
```
install.packages(c("devtools","shiny","shinydashboard","shinyjs","shinyBS","RColorBrewer","reshape2","ggplot2","ggrepel",
                   "dplyr","tidyr","plotly","htmlwidgets","DT","shinyRGL","rgl","rglwidget","readxl","png","FactoMineR","factoextra"
                    "data.table","NMF","readr"))

## try http:// if https:// URLs are not supported
biocManager::install(c("biomaRt","Biobase","SPIA","gage","gageData","KEGGgraph","KEGGREST",
                  "GO.db","limma""ReactomePA"))
                  
devtools::install_github("rstudio/d3heatmap")
```

# Input Data format
The data is analyzed using the [pipeline](https://github.com/mpmorley/MAGNet) and results are saved as an RData file which is read into the Shiny application as an input

Note : Data to be mae available soon
