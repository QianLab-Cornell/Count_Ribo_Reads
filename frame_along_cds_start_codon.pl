use strict;use warnings;
use lib "./";
use START_POS;

my $start_pos=shift;
my $read=shift;

my %start_pos;my %cdna;
START_POS($start_pos,\%start_pos);

my $proc=0;
open(F,$read);
my %mean;my %mean_count;
while(my $line=<F>){
	$proc++;
	if($proc%10==0){
		print STDERR "processing mRNAs:$proc\r";
	}
	
	$line=~s/\s+$//;
	my @tps=split(/,/,$line);
	my $name=shift @tps;	
	next unless(exists $start_pos{$name});

	for(my $i=$start_pos{$name}{'start'}-150;$i<$start_pos{$name}{'stop'}-3;$i+=3){
		
		next if($i<0);
		
		my $total_read=0;my %frame;
		for(my $j=$i;$j<$i+3;$j++){
			$total_read+=$tps[$j];
			
			my $distance=$j-$i;
			my $frame=$distance%3;
			$frame{$frame}+=$tps[$j];
		}
		next if($total_read<10);
		
		my $relative_pos=$i-$start_pos{$name}{'start'};
		
		foreach my $frame(keys %frame){
	#		unless($frame{$frame}){
	#			$frame{$frame}=0;
	#		}
			$frame{$frame}/=$total_read;
			$mean{$relative_pos}{$frame}+=$frame{$frame};
			$mean_count{$relative_pos}{$frame}++;
		}
	}
}
close(F);
print "\n";

$read=~s/^\S+\///;
open(F,">frame_start_$read");
foreach my $pos(sort {$a<=>$b} keys %mean){
	next if($pos>1500);
	foreach my $frame(keys %{$mean{$pos}}){
		$mean{$pos}{$frame}/=$mean_count{$pos}{$frame};
		print F "$pos\t$frame\t$mean{$pos}{$frame}\n";
	}
}

close(F);
