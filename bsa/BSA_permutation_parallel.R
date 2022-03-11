options(stringsAsFactors=F)
install.packages("pbapply",repos = 'https://mirrors.tuna.tsinghua.edu.cn/CRAN')
Args <- commandArgs()
print(Args[6])
print(Args[7])
print(Args[8])
print(Args[9])
print(Args[10])
mywindow <- as.numeric(Args[7])
mystep <- as.numeric(Args[8])
threads <- as.numeric(Args[9])
prefix <- Args[10]
dat <- read.table(Args[6])
dat <- dat[!(dat[,4]>0.9 & dat[,5] > 0.9),]

sample_sizeA <- 20
sample_sizeB <- 20
# /data/output/bsa_result/
resample_delta <- function(cov_vec,sizeA,sizeB) {
	covA <- cov_vec[1]
	covB <- cov_vec[2]
	res <- rep(0,1000)
	for (i in 1:1000) {
		A <- sample(c(0,1),sizeA,replace=T)
		B <- sample(c(0,1),sizeB,replace=T)
		AT <- sample(A,size=covA,replace=T)
		BT <- sample(B,size=covB,replace=T)
		res[i] <- abs((sum(AT) / covA) - (sum(BT) / covB))
	}
	res <- sort(res)
	myres <- c(res[950],res[990])
	return(myres)
}

cov_dat <- cbind(as.numeric(dat[,7]),as.numeric(dat[,12]))
#install.packages("pbapply",repos = 'https://mirrors.tuna.tsinghua.edu.cn/CRAN')

library(parallel)
library(pbapply)
pboptions(type = "txt")
cl <- makeCluster(threads)
delta_permutation <- pbapply( cl=cl, X=cov_dat, MARGIN=1, FUN=resample_delta, sizeA=sample_sizeA, sizeB=sample_sizeB )
stopCluster(cl)
#delta_permutation <- apply(cov_dat, 1, resample_delta, sizeA=sample_sizeA, sizeB=sample_sizeB )

chr <- as.character(dat[,1])
chr <- as.numeric(unlist(strsplit(chr,split="[A-Z,a-z,-,_]+"))[c(F,T)])
delta_permutation <- cbind(chr,t(delta_permutation))

## plot ##

#chromosome_len <- 1:9
delta_plot <- cbind(delta_permutation,dat[,c(2,6)])
delta_plot <- cbind(delta_plot,dat[,c(4,5)])
delta_plot <- delta_plot[delta_plot[,1] > 0,]
chromosome_len <- 1:length(unique(delta_plot[,1]))
filedir <- paste(prefix,"delta_permutation.txt",sep = "")
write.table(delta_plot,filedir,quote=F,row.names=F,col.names=F,sep="\t")

for (i in 1:length(chromosome_len)) {
	tmp_mat <- delta_plot[delta_plot[,1] == i,]
	dim(tmp_mat)
	nrow(tmp_mat)
	chromosome_len[i] <- tmp_mat[nrow(tmp_mat),4]
}
chromosome_len <- c(0,chromosome_len)
chromosome_len
format_dat <- NULL
text_pos <- 1:(length(chromosome_len)-1)
for (i in 1:(length(chromosome_len)-1) ) {
	tmp_mat <- rbind(NULL,delta_plot[delta_plot[,1] == i,])
	mystart <- seq(tmp_mat[1,4],tmp_mat[nrow(tmp_mat),4],mystep)
	myend <- seq(tmp_mat[1,4] + mywindow,tmp_mat[nrow(tmp_mat),4],mystep)
	mymin <- min(length(mystart),length(myend))
	mystart <- mystart[1:mymin]
	myend <- myend[1:mymin]
	seq_mat <- cbind(mystart,myend)
	tmp_res <- matrix(0,nrow=nrow(seq_mat),ncol=6)
	for (j in 1:nrow(seq_mat)) {
		tmp <- tmp_mat[tmp_mat[,4] >= seq_mat[j,1] & tmp_mat[,4] <= seq_mat[j,2],]
		if (nrow(tmp) == 0) {
			mymean <- 0
            mymean05 <- 0.4
            mymean001 <- 0.5
			mymean1 <- 0
      		mymean2 <- 0
		}else{
			mymean <- mean(tmp[,5])
			mymean05 <- mean(tmp[,2])
			mymean001 <- mean(tmp[,3])
			mymean1 <- mean(tmp[,6])
      		mymean2 <- mean(tmp[,7])
		}
		mypos <- mean(seq_mat[j,1],seq_mat[j,2])
		tmp_res[j,] <- c(mypos,mymean,mymean05,mymean001,mymean1,mymean2)
	}
	tmp_res[,1] <- tmp_res[,1] + sum(chromosome_len[1:i])
	format_dat <- rbind(format_dat,tmp_res)
	text_pos[i] <- ( sum(chromosome_len[1:i]) + sum(chromosome_len[1:i+1]) ) / 2
}

if (length(chromosome_len)-1 > 12) {
	c_n = 0.5
}else{
	c_n = 1
}
filedir <- paste(prefix,"format_final_dat.txt",sep = "")
write.table(format_dat,filedir,sep="\t",quote=F,row.names=F,col.names=F)

filedir <- paste(prefix,"Average_Delta_with_confidence_interval.png",sep = "")

png(filedir,width=1200,height=600)
plot(format_dat[,c(1,2)],pch=20,bty="l",type="n",ylab="Average delta value",xlab="Chromosome",xaxt="n",xaxs="i",yaxs="i",ylim=c(0,max(format_dat[,4],na.rm=T)+0.05))
lines(format_dat[,1],format_dat[,3],col="#FA8072")
lines(format_dat[,1],format_dat[,4],col="#3CB371")
points(format_dat[,c(1,2)],pch=20,cex=0.6)
axis(side=1,labels=paste("Chr",1:(length(chromosome_len)-1),sep=""),at=text_pos,tick=0,cex.axis=c_n)
for (i in 2:(length(chromosome_len)-1)) {
	tmp <- sum(chromosome_len[1:i])
	abline(v=tmp,col="gray",lty=2,lwd=2)
}
dev.off()
# /data/output/bsa_result/
filedir <- paste(prefix,"Average_Delta_with_confidence_interval.pdf",sep = "")
pdf(filedir,width=14,height=3.5)
plot(format_dat[,c(1,2)],pch=20,bty="l",type="n",ylab="Average delta value",xlab="Chromosome",xaxt="n",xaxs="i",yaxs="i",ylim=c(0,max(format_dat[,4],na.rm=T)+0.05))
lines(format_dat[,1],format_dat[,3],col="#FA8072")
lines(format_dat[,1],format_dat[,4],col="#3CB371")
points(format_dat[,c(1,2)],pch=20,cex=0.6)
axis(side=1,labels=paste("Chr",1:(length(chromosome_len)-1),sep=""),at=text_pos,tick=0,cex.axis=c_n)
for (i in 2:(length(chromosome_len)-1)) {
	tmp <- sum(chromosome_len[1:i])
	abline(v=tmp,col="gray",lty=2,lwd=2)
}
dev.off()
filedir <- paste(prefix,"Average_Delta_with_confidence_interval_line.png",sep = "")
png(filedir,width=1200,height=600)
plot(format_dat[,c(1,2)],pch=20,bty="l",type="n",ylab="Average delta value",xlab="Chromosome",xaxt="n",xaxs="i",yaxs="i",ylim=c(0,max(format_dat[,4],na.rm=T)+0.05))
lines(format_dat[,1],format_dat[,3],col="#FA8072")
lines(format_dat[,1],format_dat[,4],col="#3CB371")
lines(format_dat[,1],format_dat[,2],col="#2F4F4F")
#points(format_dat[,c(1,2)],pch=20,cex=0.6)
axis(side=1,labels=paste("Chr",1:(length(chromosome_len)-1),sep=""),at=text_pos,tick=0,cex.axis=c_n)
for (i in 2:(length(chromosome_len)-1)) {
	tmp <- sum(chromosome_len[1:i])
	abline(v=tmp,col="gray",lty=2,lwd=2)
}
dev.off()
#line
filedir <- paste(prefix,"Average_Delta_with_confidence_interval_line.pdf",sep = "")
pdf(filedir,width=14,height=3.5)
plot(format_dat[,c(1,2)],pch=20,bty="l",type="n",ylab="Average delta value",xlab="Chromosome",xaxt="n",xaxs="i",yaxs="i",ylim=c(0,max(format_dat[,4],na.rm=T)+0.05))
lines(format_dat[,1],format_dat[,3],col="#FA8072")
lines(format_dat[,1],format_dat[,4],col="#3CB371")
lines(format_dat[,1],format_dat[,2],col="#2F4F4F")
#points(format_dat[,c(1,2)],pch=20,cex=0.6)
axis(side=1,labels=paste("Chr",1:(length(chromosome_len)-1),sep=""),at=text_pos,tick=0,cex.axis=c_n)
for (i in 2:(length(chromosome_len)-1)) {
	tmp <- sum(chromosome_len[1:i])
	abline(v=tmp,col="gray",lty=2,lwd=2)
}
dev.off()

filedir <- paste(prefix,"Average_Delta_with_confidence_interval_adjuest.png",sep = "")
png(filedir,width=1200,height=600)
plot(format_dat[,c(1,2)],pch=20,bty="l",type="n",ylab="Average delta value",xlab="Chromosome",xaxt="n",xaxs="i",yaxs="i",ylim=c(0,0.8+0.05))
lines(format_dat[,1],format_dat[,3],col="#FA8072")
lines(format_dat[,1],format_dat[,4],col="#3CB371")
points(format_dat[,c(1,2)],pch=20,cex=0.6)
axis(side=1,labels=paste("Chr",1:(length(chromosome_len)-1),sep=""),at=text_pos,tick=0,cex.axis=c_n)
for (i in 2:(length(chromosome_len)-1)) {
	tmp <- sum(chromosome_len[1:i])
	abline(v=tmp,col="gray",lty=2,lwd=2)
}
dev.off()

## delata 
filedir <- paste(prefix,"Average_Delta_with_confidence_interval_adjuest.pdf",sep = "")
pdf(filedir,width=14,height=3.5)
plot(format_dat[,c(1,2)],pch=20,bty="l",type="n",ylab="Average delta value",xlab="Chromosome",xaxt="n",xaxs="i",yaxs="i",ylim=c(0,0.8+0.05))
lines(format_dat[,1],format_dat[,3],col="#FA8072")
lines(format_dat[,1],format_dat[,4],col="#3CB371")
points(format_dat[,c(1,2)],pch=20,cex=0.6)
axis(side=1,labels=paste("Chr",1:(length(chromosome_len)-1),sep=""),at=text_pos,tick=0,cex.axis=c_n)
for (i in 2:(length(chromosome_len)-1)) {
	tmp <- sum(chromosome_len[1:i])
	abline(v=tmp,col="gray",lty=2,lwd=2)
}
dev.off()
## delata 
filedir <- paste(prefix,"Average_Delta_with_confidence_interval_adjuest_line.png",sep = "")
png(filedir,width=1200,height=600)
plot(format_dat[,c(1,2)],pch=20,bty="l",type="n",ylab="Average delta value",xlab="Chromosome",xaxt="n",xaxs="i",yaxs="i",ylim=c(0,0.8+0.05))
# 95
lines(format_dat[,1],format_dat[,3],col="#FA8072")
# 99
lines(format_dat[,1],format_dat[,4],col="#3CB371")
lines(format_dat[,1],format_dat[,2],col="#2F4F4F")
#points(format_dat[,c(1,2)],pch=20,cex=0.6)
axis(side=1,labels=paste("Chr",1:(length(chromosome_len)-1),sep=""),at=text_pos,tick=0,cex.axis=c_n)
for (i in 2:(length(chromosome_len)-1)) {
	tmp <- sum(chromosome_len[1:i])
	abline(v=tmp,col="gray",lty=2,lwd=2)
}
dev.off()

filedir <- paste(prefix,"Average_Delta_with_confidence_interval_adjuest_line.pdf",sep = "")
pdf(filedir,width=14,height=3.5)
plot(format_dat[,c(1,2)],pch=20,bty="l",type="n",ylab="Average delta value",xlab="Chromosome",xaxt="n",xaxs="i",yaxs="i",ylim=c(0,0.8+0.05))
# 95
lines(format_dat[,1],format_dat[,3],col="#FA8072")
# 99
lines(format_dat[,1],format_dat[,4],col="#3CB371")
lines(format_dat[,1],format_dat[,2],col="#2F4F4F")
#points(format_dat[,c(1,2)],pch=20,cex=0.6)
axis(side=1,labels=paste("Chr",1:(length(chromosome_len)-1),sep=""),at=text_pos,tick=0,cex.axis=c_n)
for (i in 2:(length(chromosome_len)-1)) {
	tmp <- sum(chromosome_len[1:i])
	abline(v=tmp,col="gray",lty=2,lwd=2)
}
dev.off()

## w png
filedir <- paste(prefix,"Average_Delta_with_confidence_interval_w.png",sep = "")
png(filedir,width=1200,height=600)
plot(format_dat[,c(1,5)],pch=20,bty="l",type="n",ylab="Average value",xlab="Chromosome",xaxt="n",xaxs="i",yaxs="i",ylim=c(0,max(format_dat[,5],na.rm=T)+0.05))
points(format_dat[,c(1,5)],pch=20,cex=0.6)
axis(side=1,labels=paste("Chr",1:(length(chromosome_len)-1),sep=""),at=text_pos,tick=0,cex.axis=c_n)
for (i in 2:(length(chromosome_len)-1)) {
	tmp <- sum(chromosome_len[1:i])
	abline(v=tmp,col="gray",lty=2,lwd=2)
}
dev.off()

## w 
filedir <- paste(prefix,"Average_Delta_with_confidence_interval_w.pdf",sep = "")
pdf(filedir,width=14,height=3.5)
plot(format_dat[,c(1,5)],pch=20,bty="l",type="n",ylab="Average value",xlab="Chromosome",xaxt="n",xaxs="i",yaxs="i",ylim=c(0,max(format_dat[,5],na.rm=T)+0.05))
points(format_dat[,c(1,5)],pch=20,cex=0.6)
axis(side=1,labels=paste("Chr",1:(length(chromosome_len)-1),sep=""),at=text_pos,tick=0,cex.axis=c_n)
for (i in 2:(length(chromosome_len)-1)) {
	tmp <- sum(chromosome_len[1:i])
	abline(v=tmp,col="gray",lty=2,lwd=2)
}
dev.off()

## p png
filedir <- paste(prefix,"Average_Delta_with_confidence_interval_p.png",sep = "")
png(filedir,width=1200,height=600)
plot(format_dat[,c(1,6)],pch=20,bty="l",type="n",ylab="Average value",xlab="Chromosome",xaxt="n",xaxs="i",yaxs="i",ylim=c(0,max(format_dat[,6],na.rm=T)+0.05))
points(format_dat[,c(1,6)],pch=20,cex=0.6)
axis(side=1,labels=paste("Chr",1:(length(chromosome_len)-1),sep=""),at=text_pos,tick=0,cex.axis=c_n)
for (i in 2:(length(chromosome_len)-1)) {
	tmp <- sum(chromosome_len[1:i])
	abline(v=tmp,col="gray",lty=2,lwd=2)
}
dev.off()

## p
filedir <- paste(prefix,"Average_Delta_with_confidence_interval_p.pdf",sep = "")
pdf(filedir,width=14,height=3.5)
plot(format_dat[,c(1,6)],pch=20,bty="l",type="n",ylab="Average value",xlab="Chromosome",xaxt="n",xaxs="i",yaxs="i",ylim=c(0,max(format_dat[,6],na.rm=T)+0.05))
points(format_dat[,c(1,6)],pch=20,cex=0.6)
axis(side=1,labels=paste("Chr",1:(length(chromosome_len)-1),sep=""),at=text_pos,tick=0,cex.axis=c_n)
for (i in 2:(length(chromosome_len)-1)) {
	tmp <- sum(chromosome_len[1:i])
	abline(v=tmp,col="gray",lty=2,lwd=2)
}
dev.off()
# print("start plot 0.05 pdf\n")
# filedir <- paste(prefix,"Average_Delta_with_confidence_interval_0.05.pdf",sep = "")
# pdf(filedir,width=14,height=3.5)
# plot(format_dat[,c(1,2)],pch=20,bty="l",ylab="Average delta value",xlab="Chromosome",xaxt="n",xaxs="i",yaxs="i",ylim=c(0,0.8+0.05))
# axis(side=1,labels=paste("Chr",1:(length(chromosome_len)-1),sep=""),at=text_pos,tick=0,cex.axis=c_n)
# for (i in 2:(length(chromosome_len)-1)) {
#         tmp <- sum(chromosome_len[1:i])
#         abline(v=tmp,col="gray",lty=2,lwd=2)
# }
# lines(format_dat[,1],format_dat[,3],col="#EBD3E8")

# dev.off()
# print("start plot 0.05 png\n")
# filedir <- paste(prefix,"Average_Delta_with_confidence_interval_0.05.png",sep = "")
# png(filedir,width=1200,height=600)
# plot(format_dat[,c(1,2)],pch=20,bty="l",ylab="Average delta value",xlab="Chromosome",xaxt="n",xaxs="i",yaxs="i",ylim=c(0,0.8+0.05))
# axis(side=1,labels=paste("Chr",1:(length(chromosome_len)-1),sep=""),at=text_pos,tick=0,cex.axis=c_n)
# for (i in 2:(length(chromosome_len)-1)) {
#         tmp <- sum(chromosome_len[1:i])
#         abline(v=tmp,col="gray",lty=2,lwd=2)
# }
# lines(format_dat[,1],format_dat[,3],col="#EBD3E8")

# dev.off()
# print("plot finished")


# filedir <- paste(prefix,"Average_Delta_with_confidence_interval_base0.1.pdf",sep = "")
# pdf(filedir,width=14,height=3.5)
# plot(format_dat[,c(1,2)],pch=20,bty="l",ylab="Average delta value",xlab="Chromosome",xaxt="n",xaxs="i",yaxs="i",ylim=c(0.1,max(format_dat[,4],na.rm=T)+0.05))
# abline(h=0.1)
# axis(side=1,labels=paste("Chr",1:(length(chromosome_len)-1),sep=""),at=text_pos,tick=0,cex.axis=c_n)
# for (i in 2:(length(chromosome_len)-1)) {
#         tmp <- sum(chromosome_len[1:i])
#         abline(v=tmp,col="gray",lty=2,lwd=2)
# }
# lines(format_dat[,1],format_dat[,3],col="#FA8072")
# lines(format_dat[,1],format_dat[,4],col="#3CB371")

# dev.off()

# filedir <- paste(prefix,"Average_Delta_with_confidence_interval_base0.1_0.05.pdf",sep = "")
# pdf(filedir,width=14,height=3.5)
# plot(format_dat[,c(1,2)],pch=20,bty="l",ylab="Average delta value",xlab="Chromosome",xaxt="n",xaxs="i",yaxs="i",ylim=c(0.1,max(format_dat[,2],na.rm=T)+0.05))
# abline(h=0.1)
# axis(side=1,labels=paste("Chr",1:(length(chromosome_len)-1),sep=""),at=text_pos,tick=0,cex.axis=c_n)
# for (i in 2:(length(chromosome_len)-1)) {
#         tmp <- sum(chromosome_len[1:i])
#         abline(v=tmp,col="gray",lty=2,lwd=2)
# }
# lines(format_dat[,1],format_dat[,3],col="#EBD3E8")

# dev.off()




