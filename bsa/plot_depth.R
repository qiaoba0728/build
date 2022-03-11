#GC含量比较高的窗口，有着相应比较高的测序深度
options(stringsAsFactors=F)
Args <- commandArgs()
a=read.table(Args[0])
a$GC = a[,4]/a[,3]
a$depth = a[,5]/a[,3]
a = a[a$depth<100,]
plot(a$GC,a$depth)
library(ggplot2)
# GET EQUATION AND R-SQUARED AS STRING

# SOURCE: http://goo.gl/K4yh
lm_eqn <- function(x,y){
m <- lm(y ~ x);
eq <- substitute(italic(y) == a + b %.% italic(x)*","~~italic(r)^2~"="~r2,
list(a = format(coef(m)[1], digits = 2),
b = format(coef(m)[2], digits = 2),
r2 = format(summary(m)$r.squared, digits = 3)))
as.character(as.expression(eq));
}
p=ggplot(a,aes(GC,depth)) + geom_point() +
geom_smooth(method='lm',formula=y~x)+
geom_text(x = 0.5, y = 100, label = lm_eqn(a$GC , a$depth), parse = TRUE)
p=p+theme_set(theme_set(theme_bw(base_size=20)))
p=p+theme(text=element_text(face='bold'),
axis.text.x=element_text(angle=30,hjust=1,size =15),
plot.title = element_text(hjust = 0.5) ,
panel.grid = element_blank(),
#panel.border = element_blank()
)
png("/data/output/report_depth.png",width=1200,height=600)
p
dev.off()

