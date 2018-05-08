library(shinydashboard)
#library(shinyIncubator)
library(shiny)
library(shinyBS)
library(plotly)
library(d3heatmap)
library(shinyjs)
library(rglwidget)
library(SPIA)

ui <- dashboardPage(
  dashboardHeader(title = "NGS Data Analysis Web Interface",titleWidth = 350),
  dashboardSidebar(width = 350,
                   div(style="overflow-y: scroll"),
                   tags$head(tags$style(HTML(".sidebar { height: 170vh; overflow-y: auto; }" ))),
                   uiOutput("projects"),
                   fluidRow(
                     column(12,uiOutput("contrasts"))
                   ),
                   sidebarMenu(
                     menuItem('PCA-Plot', tabName = 'pcaplot', icon = icon('hand-o-right'), 
                              menuSubItem("PCA Plot", tabName = "dashboard"),
                              menuSubItem('Display Variances', tabName = 'var'),
                              menuSubItem('Show 3D plot', tabName = '3dplot')),
                     menuItem('Project Summary and Results', tabName = 'summres', icon = icon('hand-o-right'), 
                              menuSubItem('Results', tabName = 'geneselection'),
                              menuSubItem('View volcano plot', tabName = 'volcanoplot'),
                              menuSubItem('View Limma results of Multiple Contrasts', tabName = 'multilimma'),
                              menuSubItem(icon=NULL,checkboxInput("check", label = "Display Contrast List", value = FALSE)))
                   ),#end of sidebar menu
                   conditionalPanel(
                     condition = "input.check ==true",
                     uiOutput("contrastslimma")
                   ),
                   sidebarMenu(
                     menuItem('View Raw Expression Data', tabName = 'voom', icon = icon('hand-o-right')),
                     menuItem('View Sample Data', tabName = 'phenofile', icon = icon('hand-o-right')),
                     menuItem('Generate Heatmap', tabName = 'heatmap', icon = icon('hand-o-right')),
                     menuItem('GSEA Using Camera', tabName = 'cam', icon = icon('hand-o-right'),
                              menuSubItem('View Camera results', tabName = 'camera'),
                              menuSubItem(icon=NULL,uiOutput("cameradd"))),
                     menuItem('Pathway Analysis using SPIA', tabName = 'spia', icon = icon('hand-o-right')),
                     menuItem('GO Analysis using GAGE', icon = icon('hand-o-right'),
                              menuSubItem('GAGE Results', tabName = 'gogage')
                     )
                   ),
                   uiOutput("eqtllist"),
                   sidebarMenu(
                     menuItem("View eQTLs", tabName = "eqtl", icon = icon('hand-o-right')),
                     menuItem("eSNP lookup", tabName = "esnp", icon = icon('hand-o-right')),
                     menuItem("Gene Expression", tabName = "diffexpression", icon = icon('hand-o-right'))
                   )#end of sidebar menu
                  
  ),#end dashboardSidebar
  
  
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
    ),
    useShinyjs(),
    tabItems(
      tabItem(tabName = "dashboard",
              box(
                width = 10, status = "primary",solidHeader = TRUE,title = "Select Options",
                fluidRow(
                  column(6,uiOutput("pcaxoptions")),
                  column(6,uiOutput("pcayoptions"))
                ),
                br(),textOutput("biplottitle"),br(),
                fluidRow(
                  column(6,uiOutput("pcipslide")),
                  column(6,uiOutput("pcslide"))
                ),br(),
                fluidRow(
                  column(6,uiOutput("ellipse")),
                  column(6,uiOutput("habbilage"))
                )),
              box(
                width = 10, status = "primary",solidHeader = TRUE,
                title = "PCA Plot",plotOutput("biplot",height=600)
                
              ),br(),
              fluidRow(
                column(6,uiOutput("dwldbiplot")))
              
      ),
      
      tabItem(tabName = "var",
              box(width = 10, status = "primary",solidHeader = TRUE,title = "Variances of principal Components",
                  textOutput("pcatitle"),plotOutput("pcaplot_ip",width=700,height=400),br()),
              box(width = 12, status = "primary",solidHeader = TRUE,title = "Amount of Variation explained by each Principle Component",DT::dataTableOutput('pcaplot_tab'))),
      
      tabItem(tabName = "3dplot",h4("3D plot"),br(),br(),rglwidgetOutput("pcaplot3d",width = "850px", height = "750px")),
      
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      
      tabItem(tabName = "geneselection",
              box(width = 10, status = "primary",solidHeader = TRUE,title = "Project Description",
                  textOutput("pdesc")),
              
              fluidRow(
                box(width = 8, status = "primary",solidHeader = TRUE,title = "Dot Plot of the gene of interest",
                    fluidRow(
                      column(6,selectInput("color","Select an Attribute for the X-axis",c("tissue_source","etiology","gender","race","maineffect","Library.Pool"))),
                      column(6,selectInput("color2","Color By",c("tissue_source","etiology","gender","race","maineffect","Library.Pool")))
                    ),
                    uiOutput("minexprline"),
                    plotOutput('dotplot')
                    ),
                box(width = 4, status = "primary",solidHeader = TRUE,title = "Gene Selection",
                    radioButtons("radio", label = h4("Gene Selection"),
                                 choices = c("None" = 'none',"Upregulated" = 'up', "Downregulated" = 'down', "Both" = 'both'),
                                 selected = 'none'),
                    
                    sliderInput("lfc", label = h4("Fold Change"), min = 0.5,max = 6, value = 2),
                    sliderInput("apval", label = h4("P. Value"), min = 0.01,max = 0.2, value =0.05),br(),
                    fluidRow(
                      column(6,downloadButton('dwld','Download results table')),
                      column(6,downloadButton('downloaddotplot', 'Download Dot plot')))
                )),
              
              box(width = 12, status = "primary",solidHeader = TRUE,title = "Limma data",
                  h5(p(div(span("Note:fc - Fold Change",style="color:red")))),
                  br(),textOutput("contrdesc"),br(),DT::dataTableOutput('table'))),
      
      tabItem(tabName = "volcanoplot",
              fluidRow(
                column(6,plotlyOutput("volcanoplot",width=800,height=700)),
                column(width = 3, offset = 2,uiOutput("volcdrop")),
                column(width =4, offset = 2,uiOutput("volcslider"))
              ),br(),DT::dataTableOutput('table_volc')),
      tabItem(tabName = "multilimma",DT::dataTableOutput('table_TRUE'),fluidRow(uiOutput("dwldmultitab"))),
      
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      tabItem(tabName = "voom",DT::dataTableOutput('table3'),
              fluidRow(uiOutput("dwldrawtab"))
      ),
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      tabItem(tabName = "phenofile",DT::dataTableOutput('phenofile')),
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      tabItem(tabName = "heatmap",
              box(width = 8, status = "primary",solidHeader = TRUE,title = "Heatmap",
                  textOutput("htitle"),br(),
                  fluidRow(
                    column(6,uiOutput('hmplim')),
                    column(width = 3, offset = 2,plotOutput('hmpscale_out',width = 200,height = 65))
                  ),
                  fluidRow(
                    column(6,uiOutput('hmpsamp')),
                    column(6,h4(""))
                  ),
                  d3heatmapOutput('heatmap',width=550,height=900)
              ),
              
              box(width = 4, status = "primary",solidHeader = TRUE,title = "Controls",
                  selectInput("hmip", "Select Heatmap input type",c('Top number of genes' = "genenum",'Enter Genelist' = "geneli", 'Top Variable genes' = "vargenes")),
                  selectInput("hmpcol", "Select Heatmap Color Palette",c('YlGnBu' = "YlGnBu",'RdBu' = "RdBu",'YlOrRd' = "YlOrRd",'PRGn'="PRGn", 'Blues' = "Blues")),
                  selectInput("clusterby", "Cluster By",c('Both'="both",'Row' = "row",'Column' = "column",'None' = "none")),
                  checkboxInput("checkbox", label = "Reverse Colors", value = FALSE),
                  
                  conditionalPanel(
                    condition = "input.hmip == 'genenum'",
                    uiOutput("dropdown"),
                    sliderInput("gene", label = h4("Top number of genes"), min = 2,max = 500, value = 50)
                  ),
                  conditionalPanel(
                    condition = "input.hmip == 'geneli'",
                    selectInput(inputId = 'selectidentifier',label='Select Identifier',choices=list('Ensembl ID'='ensembl','Entrez Id'='entrez','Gene Symbol'='genesym')),
                    fileInput('genelistfile', 'Upload Text File',accept=c('text/csv','text/comma-separated-values,text/plain','.txt')),
                    actionButton(inputId = 'ga', label = 'Display Results')
                  ),
                  conditionalPanel(
                    condition = "input.hmip == 'vargenes'",
                    #uiOutput("dropdown"),
                    sliderInput("vgene", label = h4("Top variable genes"), min = 2,max = 500, value = 50)
                  ),br(),
                  downloadButton('downloadheatmap', 'Download')
              )#end box
      ),#end tabItem
      
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      
      tabItem(tabName = "camera",
              fluidRow(
                box(width = 8, status = "primary",solidHeader = TRUE,title = "Camera Heatmap",
                    fluidRow(
                      column(6,uiOutput('hmplimcam')),
                      column(width = 3, offset = 2,plotOutput('hmpscale_out2',width = 200,height = 65))
                    ),
                    fluidRow(
                      column(6,uiOutput('hmpsamp2')),
                      column(6,h4(""))
                    ),
                    d3heatmapOutput('camheatmap',width=550,height=900)),
                box(width = 4, status = "primary",solidHeader = TRUE,title = "Controls",
                    selectInput("hmpcol2", "Select Heatmap Color Palette",c('YlGnBu' = "YlGnBu",'RdBu' = "RdBu",'YlOrRd' = "YlOrRd",'PRGn'="PRGn", 'Blues' = "Blues")),
                    selectInput("clusterby2", "Cluster By",c('Both'="both",'Row' = "row",'Column' = "column",'None' = "none")),
                    checkboxInput("checkbox2", label = "Reverse Colors", value = FALSE),
                    br(),
                    downloadButton('downloadcamheatmap', 'Download Heatmap'))),
              box(width = 12, status = "primary",solidHeader = TRUE,title = "Table",
                  DT::dataTableOutput('tablecam'),textOutput("camdesc"),DT::dataTableOutput('campick3'))
              
              
              
      ),#end tabItem
      
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      
      tabItem(tabName = "spia", DT::dataTableOutput('spiaop'),textOutput("spiadesc"),DT::dataTableOutput('spiagenes')),
      
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      tabItem(tabName = "gogage",
              fluidRow(
                box(width = 8, status = "primary",solidHeader = TRUE,title = "GO Heatmap",
                    fluidRow(
                      column(6,uiOutput('hmplimgo')),
                      column(width = 3, offset = 2,plotOutput('hmpscale_out3',width = 200,height = 65))
                    ),
                    fluidRow(
                      column(6,uiOutput('hmpsamp3')),
                      column(6,h4(""))
                    ),
                    d3heatmapOutput('goheatmap',width=550,height=900)),
                box(width = 4, status = "primary",solidHeader = TRUE,title = "Controls",
                    fluidRow(
                      column(6,radioButtons(inputId='gage', label = h5("Select ontology"),
                                            choices = c("Biological Process" = 'BP', "Cellular Component" = 'cc', "Molecular Function" = 'MF'))),
                      column(6,selectInput("go_dd", "GO Selection",c('Upregulated' = "upreg",'Downregulated' = "downreg")))),
                    #actionButton(inputId = 'ga', label = 'Display Results'),
                    #bsPopover("ga",title="Note",content= "If you get an error with the heatmap,try refreshing",placement="right",trigger="hover",options=list(container="body")),
                    #br(),br(),
                    fluidRow( 
                      column(6,downloadButton('downloadgo', 'Download GO Data')),
                      column(6,downloadButton('downloadgogene', 'Download GO Genelist'))),
                    br(),
                    downloadButton('downloadgoheatmap', 'Download GO Heatmap'),
                    br(),
                    selectInput("hmpcol3", "Select Heatmap Color Palette",c('YlGnBu' = "YlGnBu",'RdBu' = "RdBu",'YlOrRd' = "YlOrRd",'PRGn'="PRGn", 'Blues' = "Blues")),
                    selectInput("clusterby3", "Cluster By",c('Both'="both",'Row' = "row",'Column' = "column",'None' = "none")),
                    checkboxInput("checkbox3", label = "Reverse Colors", value = FALSE))),
              box(width = 12, status = "primary",solidHeader = TRUE,title = "Table",
                  DT::dataTableOutput('table4'),textOutput("godesc"),DT::dataTableOutput('x4'))
              
              
              
      ),
      
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      tabItem(tabName = "eqtl",
              # fluidRow(
              box(plotOutput("eSNP_plot", height = 600),width=8,solidHeader = TRUE),
              box(
                title = "Controls",solidHeader = TRUE,width=4,status='primary',
                selectInput("xvar", label = h3("Genotype Variable"), 
                            choices = c('Genotype','Dosage'), selected = 'Genotype'),
                selectInput("colorby", label ="Color By", 
                             choices = c('etiology','race','race_etiology','gender','afib','Diabetes','Hypertension'), selected = 'etiology'),
                selectInput("splitby", label = "Split By", 
                            choices = c('etiology','race','race_etiology','gender','afib','Diabetes','Hypertension'), selected = 'race_etiology'),
                selectInput("colorpal", label = h3("Colour Palette"), 
                            choices = c("aaas",'npg','nejm','lancet','jama','jco','d3','simpsons'), selected = 'aaas'),
                downloadButton('download_eSNP_Plot', 'Download')
              ),
              box(DT::dataTableOutput('eQTLTable'), width=12,status='primary',solidHeader = TRUE,title="eQTL")
      ),
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      tabItem(tabName = "esnp",
              # fluidRow(
              box(plotOutput("snplookup_plot", height = 600),width=8,solidHeader = TRUE),
              box(
                title = "Controls",solidHeader = TRUE,width=4,status='primary',
                textInput("snpid", label="Enter rsid of the snp", value = ""),
                textInput("geneid", label="Enter Gene", value = ""),
                selectInput("xvaresnp", label = h3("Genotype Variable"), choices = c('Genotype','Dosage'), selected = 'Genotype'),
                selectInput("colorbyesnp", label ="Color By", 
                            choices = c('etiology','race','race_etiology','gender','afib','diabetes','hypertension'), selected = 'etiology'),
                selectInput("splitbyesnp", label = "Split By", 
                            choices = c('etiology','race','race_etiology','gender','afib','diabetes','hypertension'), selected = 'race_etiology'),
                selectInput("colorpalesnp", label = "Colour Palette", 
                            choices = c("aaas",'npg','nejm','lancet','jama','jco','d3','simpsons'), selected = 'aaas'),
                downloadButton('download_eSNPlookupPlot', 'Download')
              )
      ),
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      tabItem(tabName = "diffexpression",
              # fluidRow(
              box(plotOutput("geneexp_plot", height = 600),width=8,solidHeader = TRUE),
              box(
                title = "Controls",solidHeader = TRUE,width=4,status='primary',
                textInput("genedeg", label="Enter Gene id", value = ""),
                selectInput("colorbydeg", label = "Color By", 
                            choices = c('etiology','race','Race_CHF_Etiology','gender','Afib','Diabetes','Hypertension'), selected = 'etiology'),
                selectInput("splitbydeg", label = "Split By", 
                            choices = c('etiology','race','Race_CHF_Etiology','gender','Afib','Diabetes','Hypertension'), selected = 'Race_CHF_Etiology'),
                downloadButton('download_genedeg', 'Download')
              )
      )
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
      
    )
  )
)


