use strict;use warnings;
use lib "./";
use START_POS;

my $start_pos=shift; #position of start codon
my $align=shift;


my %start_pos;
START_POS($start_pos,\%start_pos);

print "reading align file\n";
open(F,$align);
my %reads;my $count=0;
my %mismatch;
while(my $line=<F>){

	$count++;
	if($count%100000==0){
		print STDERR $count,"\r";
	}

	$line=~s/\s+$//;
	my @tps=split(/\t/,$line);
	next unless($tps[1] eq '0');
	next unless(exists $start_pos{$tps[2]});

	my $pos=$tps[3]-1;

	$reads{$tps[2]}{$pos}++;
	
	if($tps[13] eq 'NM:i:1' or $tps[13] eq 'NM:i:2'){
		$mismatch{$tps[2]}{$pos}++;
	}
	elsif($tps[13] eq 'NM:i:0'){
	}
	else{
		next;
	}
}
close(F);

print "\n";
print "rpkm calculating\n";

my $total_reads=0;my %read_tr;my %site_count;
foreach my $tr_name(keys %reads){
	foreach my $pos(keys %{$reads{$tr_name}}){
		unless(exists $mismatch{$tr_name}{$pos}){
			$mismatch{$tr_name}{$pos}=0;
		}

		my $fraction=$mismatch{$tr_name}{$pos}/$reads{$tr_name}{$pos};
		if($reads{$tr_name}{$pos}>100 and $fraction>0.5){
			next;
		}
		$site_count{$tr_name}++;
		$read_tr{$tr_name}+=$reads{$tr_name}{$pos};
		$total_reads+=$reads{$tr_name}{$pos};
	}

}

$align=~s/\S+\///;
open(F,">rpkm_rna_$align");
foreach my $tr_name(keys %read_tr){
	next if($site_count{$tr_name}<5);	
	my $rpkm=$read_tr{$tr_name}/($total_reads*$start_pos{$tr_name}{'tr_len'})*1000000000;
	print F "$tr_name\t$rpkm\n";
}
close(F);