#!/usr/bin/env Rscript
library(ggplot2)
library(scales)


args = commandArgs(TRUE)

print(args[1])
print(args[2])
var <- read.table(args[1], sep="\t", header=TRUE)
name <- args[2]

if(args[3] == "SNPs") {

    xlab_size=10
    q <- ggplot(var, aes(x=SNPs, y=Variants)) ## plotting the barplot by defining x and y variables
    plot <- q + geom_bar(position='dodge',stat='identity',color='red') +
    ggtitle(paste("Number of Variants ", sep="")) + xlab("SNPs") + ylab("Number") + ## titles
    theme(axis.text.x=element_text(angle=45, hjust=1, size=xlab_size), axis.title=element_text(size=14, face="bold"), plot.title=element_text(hjust=0.5, size=16, face="bold")) + ## angle and size of axis labels
    scale_y_continuous(labels=comma)   ## converts the y-axis numbers from scientific to full numbers (note: scales library should be loaded first)
    fineName=paste0(name,"-snps.png")
    png(fineName)
    print(plot)
    dev.off()

    fineName=paste0(name,"-snps.pdf")
    pdf(fineName)
    print(plot)
    dev.off()

#ggsave("SNPs.pdf", width = 16, height = 9, dpi = 120)
}

if(args[3] == "Insertions") {

    xlab_size=4

    q <- ggplot(var, aes(x=Insertions, y=Variants)) ## plotting the barplot by defining x and y variables
    plot <- q + geom_bar(position='dodge',stat='identity',color='red') +
    ggtitle(paste("Number of Variants ", sep="")) + xlab("Insertions") + ylab("Number") + ## titles
    theme(axis.text.x=element_text(angle=45, hjust=1, size=xlab_size), axis.title=element_text(size=14, face="bold"), plot.title=element_text(hjust=0.5, size=16, face="bold")) + ## angle and size of axis labels
    scale_y_continuous(labels=comma)   ## converts the y-axis numbers from scientific to full numbers (note: scales library should be loaded first)

    fineName=paste0(name,"-indel.png")
    png(fineName)
    print(plot)
    dev.off()
    fineName=paste0(name,"-indel.pdf")
    pdf(fineName)
    print(plot)
    dev.off()
#ggsave("Insertions.pdf", width = 16, height = 9, dpi = 120)
}


