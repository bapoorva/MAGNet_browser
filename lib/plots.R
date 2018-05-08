library(dplyr)
library(readr)
library('ggplot2')
#############################################################################
#                         Global vars                                       #   
#                                                                           #
#############################################################################
vcffile = "data/MAGnet_allgood_finallist.vcf.gz"

plotTheme <-theme_bw() + theme(axis.title.x = element_text(face="bold", size=12),
                               axis.text.x  = element_text(angle=35, vjust=0.5, size=12),
                               axis.title.y = element_text(face="bold", size=12),
                               axis.text.y  = element_text(angle=0, vjust=0.5, size=12))

listpalettes <-  function(){
  return( c("aaas",'npg','nejm','lancet','jama','jco','d3','simpsons'))
}

theme_opts <- function()
{
  theme(strip.background = element_rect(colour = 'white', fill = 'white')) +
    theme(panel.border = element_blank()) +
    theme(axis.line.x = element_line(size=0.25, color="black")) +
    theme(axis.line.y = element_line(size=0.25, color="black")) +
    theme(panel.grid.minor.x = element_blank(), panel.grid.minor.y = element_blank()) +
    theme(panel.grid.major.x = element_blank(), panel.grid.major.y = element_blank()) + 
    theme(panel.background = element_rect(fill='white')) +
    theme(legend.position="bottom") +
    theme(legend.title=element_blank()) +
    theme(legend.text=element_text(size=14))
  
  
  
}

#############################################################################
#                         eSNP plot                                         #   
#                                                                           #
#############################################################################


eSNP_plot <- function(eset,snp,gene,fpkm,marker_size=0.1,colorpal='aaas',xvar='Genotype',colorby='etiology',splitby='race_etiology'){
  #snp='17:64320085'
  #gene='ENSG00000154229'
  palstr <- paste0("ggsci::scale_color_",colorpal, "()")
  pheno <- pData(eset) %>% mutate(race_etiology=paste0(race,'_',etiology))
  
  geno <- read_csv(pipe(paste0("bcftools query -r ",snp,"  -f '[%SAMPLE,%ID,%REF,%ALT{0},%INFO/AF,%TGT,%DS\n]' ", vcffile)),
                   col_names=c('sample_name','snpid','ref','alt','AF','Genotype','Dosage'),
                   col_types='ccccncn')
  geno <- inner_join(geno,pheno) %>% arrange(sample_name)
  
  
  geno$signal <-as.vector(t(exprs(eset)[gene,]))
  sig=fpkm
  sig=sig[rownames(sig)==gene,]
  geno$signal <-as.vector(t(sig))
  #geno$signal <-as.vector(t(exprs(eset)[rownames(exprs(eset))==gene,]))
  
  p <- geno %>% filter(etiology %in% c('NF',"DCM")) %>% 
    ggplot(aes_(x=as.name(xvar),y=~signal,color=as.name(colorby))) 
  if(xvar=='Dosage'){
    p <- p + geom_point() + geom_smooth(method = 'lm') + xlab('Alt Allele Dosage')
    
  }else{
    p <- p + geom_point(position=position_jitterdodge(dodge.width=0.9)) + 
      geom_boxplot(alpha=0,outlier.colour = NA, position = position_dodge(width=0.9)) +
      xlab('Phased Genotype')
  }
  p <- p + ylab('Adjusted FPKM') + ggtitle(paste0(gene,'_',snp)) +
    facet_wrap(as.formula(paste("~", splitby)),nrow=1) + 
    theme_opts() + eval(parse(text = palstr))
  return(p)
}

#snp='17:64320085'
#gene='ENSG00000154229'
#load('data/magnet.RData')
#eset <- results$eset

#eSNP_plot(results$eset,snp,gene)



