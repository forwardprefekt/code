#!/usr/bin/perl

# Simple script looking for collisions in the http://www.nsrl.nist.gov/Downloads.htm dataset
# find repeating md5 and unique based on sha1. I didnt find anything... bug?


$|=1; #no buffering...
use Bloom::Filter;

$hashcount = 148403782; # wc -l on source file

my $md5_filter = Bloom::Filter-> new( error_rate => 0.01, capacity => $hashcount);
my $md5sha1_filter = Bloom::Filter-> new( error_rate => 0.01, capacity => $hashcount);
open(my $fh, '-|', 'zcat hashlist.gz') or die $!;

#headers
#"SHA-1","MD5","CRC32","FileName","FileSize","ProductCode","OpSystemCode","SpecialCode"

$x=0;
while  (my $line = <$fh>) {
	$x++;
	if ($x % 1000 == 0 ) { print "."; } #impatient	
	@vals = split(/,/,$line);
	$md5=@vals[1];
	$sha=@vals[0];


	if ( $md5_filter->check( $md5 )) {
		if ( $md5sha1_filter->check($md5 . $sha)) {
			#identical
		} else {
			print($line);
		}
	} else {
		$md5_filter->add($md5);
		$md5sha1_filter->add($md5 . $sha);
	}

}
