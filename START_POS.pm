package START_POS;
use strict;use warnings;
use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw (START_POS);

sub START_POS{
	my $file=shift;
	my $ref_hash=shift;
	open(F,"gzip -dc $file|");
	while(my $line=<F>){
		$line=~s/\s+$//;
		my @tps=split(/\t/,$line);
		$$ref_hash{$tps[0]}{'start'}=$tps[2];
		$$ref_hash{$tps[0]}{'stop'}=$tps[5];
		$$ref_hash{$tps[0]}{'cds_len'}=$tps[5]-$tps[2]+3;
		$$ref_hash{$tps[0]}{'tr_len'}=$tps[3];
	}
	
	close(F);
}
1;

