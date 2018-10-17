#!/usr/bin/perl

=pod
description: merge all samples' htseq results(raw dead count) to a single file;
author: Yu tong
       	yutong@decodegenomics.com
created date: 20140304
modified date: 
=cut

use strict;
use warnings;
use File::Basename qw(dirname basename);

my $usage = << "USAGE";
description: merge all samples' Htseq results (raw dead count) to a single file;

usage: perl $0 <indir> <samplesnames> <outdir>
USAGE

my ($indir,$samples, $outdir) = @ARGV;
die $usage if (!defined $indir or !defined $samples or !defined $outdir);

my $header = "ID";
my $desc = "";
my (@samples, %results, %descs);
@samples = split /,/,$samples;
my $outname = join "_",@samples;
foreach my $name (@samples) {
	my $file = "$indir/$name.rawCount.txt";

	&showLog("read file $file");
	$header .= "\t$name";
	open GENE, "< $file" or die $!;
	while (<GENE>) {
		chomp;
		next if(/expected_count/ || /gene_id/);
		my ($id,$count) = split /\t/, $_;
		next if ($id =~ /^__/);
		$results{$id}{$name} = $count;
	}
	close GENE;
}

&showLog("output");
open OUT, "> $outdir/$outname.rawCount.xls" or die $!;
print OUT "$header\n";
for my $gene (keys %results) {
	print OUT $gene;
	for (@samples) {
		if (exists $results{$gene}{$_}) {
			print OUT "\t$results{$gene}{$_}";
		} else {
			print "wrong: the $_ not have the $gene,please check!!\n";
		}
	}
	print OUT "\n";
}

&showLog("done");

exit 0;

sub showLog {
	my ($info) = @_;
	my @times = localtime; # sec, min, hour, day, month, year
	print STDERR sprintf("[%d-%02d-%02d %02d:%02d:%02d] %s\n", $times[5] + 1900, $times[4] + 1, $times[3], $times[2], $times[1], $times[0], $info);
}
