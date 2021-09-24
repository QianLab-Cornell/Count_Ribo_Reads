use strict;use warnings;
use lib "./";
use START_POS;

my $start_pos=shift;
my $aligned_reads=shift;

my %start_pos;
START_POS($start_pos,\%start_pos);

open(F,$aligned_reads);
my %reads;my %reads1;
my $total=0;
while(my $line=<F>){
	$line=~s/\s+$//;
	my @tps=split(/\t/,$line);
	
	my ($tr_name)=$line=~/(ENS\w{0,3}T\d+)/;
	my $pos=$tps[3]-1+12;
	next unless($start_pos{$tr_name});
	my $len=length($tps[9]);
	
	my $relative=$pos-$start_pos{$tr_name}{'start'};
	$relative=int($relative/3)*3;
	$reads{$tr_name}{$relative}++;
	
	next if($pos<$start_pos{$tr_name}{'start'} or $pos>$start_pos{$tr_name}{'stop'});
	$reads1{$tr_name}++;
	$total++;
}
close(F);

$total/=1000000;

my %mean;my %count;
foreach my $tr_name(keys %reads1){
	
	my $len=$start_pos{$tr_name}{'stop'}-$start_pos{$tr_name}{'start'}+3;
	$len/=3;

	next if($reads1{$tr_name}<16);
	next if(scalar(keys %{$reads{$tr_name}})/$len<0.1);	
	
	for(my $i=-198;$i<$len;$i+=3){
		my $tmp_reads=0;
		unless(exists $reads{$tr_name}{$i}){
		}
		else{
			$tmp_reads=$reads{$tr_name}{$i};
		}
		
		next if($tmp_reads>2000);
		$tmp_reads/=$total;
		
		$mean{$i}+=$tmp_reads;
		$count{$i}++;
	}
}

$aligned_reads=~s/\S+\///;
open(F,">by_codon_aggregation5_$aligned_reads");
for(my $i=-198;$i<1000;$i+=3){
	last if($count{$i}<30);

	my $pos=$i;
	$mean{$pos}/=$count{$pos};
	print F "$pos\t$mean{$pos}\t$count{$pos}\n";
}
close(F);

