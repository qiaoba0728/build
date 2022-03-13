#!/usr/bin/perl
##--- zwy 2016.9.27 for web --##

use strict;
use Getopt::Std;
our($opt_f,$opt_b,$opt_a,$opt_1,$opt_2,$opt_r,$opt_s,$opt_3,$opt_4,$opt_5,$opt_6,,$opt_7,$opt_t);
getopts('f:b:a:1:2:r:s:3:4:5:6:7:t:');

my $reference    = $opt_f;
my $bowtie_index = $opt_b;
my $lable1       = (defined $opt_1)?$opt_1:"S1";
my $lable2       = (defined $opt_2)?$opt_2:"S2";
my $threads      = (defined $opt_a)?$opt_a:6;
my $step         = (defined $opt_s)?$opt_s:1000000;
my $range        = (defined $opt_r)?$opt_r:3000000;
my $fq1_1	 = $opt_3;
my $fq1_2	 = $opt_4;
my $fq2_1	 = $opt_5;
my $fq2_2	 = $opt_6;
my $dir	         = (defined $opt_7)?$opt_7:"/data/output/bsa_result/";
my $tag       = (defined $opt_t)?$opt_t:"bsa_";

my $Usage = "\n$0 -f <Reference genome> -b <Index> -3 -4 -5 -6 <fastq files>
Input (required):
	-f <FILE>  reference genome file
	-b <FILE>  bowtie2 index [same as reference name]
	-3 <FILE>  pool1 left
	-4 <FILE>  pool1_right
	-5 <FILE>  pool2_left
	-6 <FILE>  pool2_right
        -7 <FILE>  file_prefix
	
Advanced options:	
	-a <INT>   number of threads [6]
	-s <INT>   window step [1000000]
	-r <INT>   window range [3000000]
	-1 <STR>   pool1's name [S1]
        -2 <STR>   pool2's name [S2]
	-7 <STR>   file prefix [/data/output/bsa_result]
	\n";
die $Usage unless ($opt_f && $opt_b && $opt_3 && $opt_4 && $opt_5 && $opt_6 && $opt_7);
################################################################
my $time1 = time();
my $vcf = "$lable1\_$lable2";
my $fai  = "$reference.fai";

my $loc = rindex($fq1_1,"/");
my $tag1 = substr($fq1_1,$loc+1,1);

my $loc = rindex($fq2_1,"/");
my $tag2 = substr($fq2_1,$loc+1,1);
print "*************************** tag1:${tag1},tag2:${tag2} ****************************";

# ----------- index the genome using samtools ---------- #
unless (-e $fai){
	print "  indexing the genome with samtools\n";
	!system "samtools faidx $reference" or die "Something wrong with samtools faidx:$!";
}else{
	print "$fai -- found! indexing skipped!\n";
	!system "samtools faidx $reference" or die "Something wrong with samtools faidx:$!";
}

## check chromosome numbers ##
open CHRNUM,'<',"$reference" or die "Cannot open reference";
my $chrseq_numbers = 0;
while (<CHRNUM>) {
	chomp;
	if (/>/) {
		$chrseq_numbers ++;
	}
	if ($chrseq_numbers == 100) {
		last;
	}
}
close CHRNUM;


# -------- running snpMapper --------------#
print "snpMapper-1.07_forDNABSA.pl -s $tag -f $reference -b $bowtie_index -3 $fq1_1 -4 $fq1_2 -5 $fq2_1 -6 $fq2_2 -a $threads -d 0 -o /data/output/smsnpMapper_out 2> /data/log/snpMapper.log\n";
!system "snpMapper-1.07_forDNABSA.pl -s $tag -f $reference -b $bowtie_index -3 $fq1_1 -4 $fq1_2 -5 $fq2_1 -6 $fq2_2 -a $threads -d 0 -o /data/output/smsnpMapper_out 2>/data/log/snpMapper.log" or die "Something wrong with snpMapper-107_forDNABSA.pl:$!";
print "delta.pl /data/output/smsnpMapper_out/smcandidatesnps_D15d0.txt 0.4 /data/output/smsnpMapper_out/smcandidatesnps_D15d0.4.txt\n";
!system "delta.pl /data/output/smsnpMapper_out/smcandidatesnps_D15d0.txt 0.4 /data/output/smsnpMapper_out/smcandidatesnps_D15d0.4.txt" or die "Something wrong wich delta.pl!";
print "snp_to_vcf.pl -i /data/output/smsnpMapper_out/smcandidatesnps_D15d0.txt -o /data/output/$vcf.vcf\n";
!system "snp_to_vcf.pl -i /data/output/smsnpMapper_out/smcandidatesnps_D15d0.txt -o /data/output/$vcf.vcf" or die "Somerthing wrong with snp2vcf:$! $vcf";
print "Enzyme_ParaFly.pl -v /data/output/$vcf.vcf -s $reference -p $threads -a > /data/log/Enzyme.log\n";
!system "Enzyme_ParaFly.pl -v /data/output/$vcf.vcf -s $reference -p $threads -a > /data/log/Enzyme.log" or die "Something wrong with Enzyme_parafly.pl!";
mkdir "Final_Results"; 
print "after Final_Results $chrseq_numbers\n";
if ($chrseq_numbers <= 30) {
        print "\ndelta_distribution.pl -i /data/output/smsnpMapper_out/smcandidatesnps_D15d0.txt -o /data/output/delta_distribution.txt -r $range -s $step > /data/log/delta_plot.log\n";
	!system "delta_distribution.pl -i /data/output/smsnpMapper_out/smcandidatesnps_D15d0.txt -o /data/output/delta_distribution.txt -r $range -s $step > /data/log/delta_plot.log" or die "Cannot run delta_distribution.pl:$!";
	print "\nstart plot:\n";
	!system "Rscript BSA_permutation_parallel.R /data/output/smsnpMapper_out/smcandidatesnps_D15d0.txt $range $step $threads $dir" or die "ERROR with R_BSA_permutation.R:$!";
}





#system "cp smsnpMapper_out/smcandidatesnps_D15d0.txt Final_Results/";
#system "cp smsnpMapper_out/smcandidatesnps_D15d0.4.txt Final_Results/";
#system "mv Better_enzyme_site.txt /data/output/smsnpMapper_out/";
#system "mv Enzyme_site.txt /data/output/smsnpMapper_out/";


##--- get Enzyme site of which delta value greater than 0.4---##
open BETTER,'<',"/data/output/smsnpMapper_out/Better_enzyme_site.txt" or die;
my (%better_seq,%better_name,$id);
while (<BETTER>) {
        chomp;
        if (/>/) {
                $id = (split />/,(split)[0])[1];
                $better_seq{$id} = '';
                my ($chr,$pos) = (split /:/,$id)[0,2];
                my $newname = "$chr\t$pos";
                $better_name{$newname} = $id;
        }else{
                $better_seq{$id} .= $_;
        }
}
close BETTER;

open ENZYME,'<',"/data/output/smsnpMapper_out/Enzyme_site.txt" or die;
my (%enzyme_seq,%enzyme_name,$id);
while (<ENZYME>) {
        chomp;
        if (/>/) {
                $id = (split />/,(split)[0])[1];
                $enzyme_seq{$id} = '';
                my ($chr,$pos) = (split /:/,$id)[0,2];
                my $newname = "$chr\t$pos";
                $enzyme_name{$newname} = $id;
        }else{
                $enzyme_seq{$id} .= $_;
        }
}
close ENZYME;

open DELTA04,'<',"/data/output/smsnpMapper_out/smcandidatesnps_D15d0.4.txt" or die "Cannot open delta file:$!";
open BETTEROUT,'>',"/data/output/Better_enzyme_site_0.4.txt";
open ENZYMEOUT,'>',"/data/output/Enzyme_site_0.4.txt";
while (<DELTA04>) {
        chomp;
        my ($chr0,$pos0,$pf1,$pf2,$pd) = (split)[0,1,3,4,5];
        my $newname = "$chr0\t$pos0";
        if (exists $better_name{$newname}) {
                print BETTEROUT ">$better_name{$newname}\t$pf1\t$pf2\t$pd\n$better_seq{$better_name{$newname}}\n";
        }elsif (exists $enzyme_name{$newname}) {
                print ENZYMEOUT ">$enzyme_name{$newname}\t$pf1\t$pf2\t$pd\n$enzyme_seq{$enzyme_name{$newname}}\n";
        }
}
close DELTA04;
close BETTEROUT;
close ENZYMEOUT;


my $time2 = time();
my $time = sprintf "%.1f",($time2-$time1)/3600;
$time .= 'h';
print "Pipeline finished: $time\n";


