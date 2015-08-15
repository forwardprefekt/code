#!/usr/bin/perl
use Statistics::Descriptive;
use Data::Dumper; ## not really needed, just for dumping hash to look at
use Date::Parse;

####################################################
# bitnn.com - 11/16/2012                           # 
# use freely please, let me know if this is useful #
####################################################

# for this script, I am using dnsmasq logs from my openwrt box, so it will 
# be formatted as such. logic will stay the same for whatever you are using. 
# the real goal here is showing probes that occur within a reasonable sttdev of each other.
# my hash will be a local/remote pair, and then an array of access intervals. we will do basic stats on those values.


$logFile = "/var/log/remote.log"; # syslog file to look at.
$max_dev_allowed = 60; # stddev min to print... doing 1 minute intervals stddev
$min_num_connects = 5; # minimum number of connections that we care
$min_interval = 60; # minimum connect interval we care about... so 5 connections in 1 minute doesnt seem significant

open LOG, $logFile; 

%resolves = ();


foreach (<LOG>) {

	if (/dnsmasq/ && /query\[A\]/) { 	# verify its a dnsmasq log, and and a record query

		if (/(... .. ..:..:..) .*query\[A\] (.*) from (.*)/) {
			
			#print "$1 $2 $3\n";

			$ss = str2time($1);

			push @{$resolves{"$3->$2"}}, $ss; 

		}

	}
} 


# change arrays from actual dates to intervals
foreach (keys %resolves) {

	if (scalar(@{$resolves{$_}}) lt 3) { # delete elements we just dont have enough data for
		delete $resolves{$_};
	} else {
		$counter = scalar(@{$resolves{$_}});
		for ( $x = $counter - 1; $x>0; $x-- ) {
			$resolves{$_}[$x] = $resolves{$_}[$x] - $resolves{$_}[$x-1] ;
			if ( $resolves{$_}[x] < $min_interval) {
				splice(@{$resolves{$_}}, $x, 1);
			}
		}
		shift @{$resolves{$_}};
	}

}

foreach (keys %resolves) {

	$stat = Statistics::Descriptive::Full->new();
	$stat->add_data(\@{$resolves{$_}});
	$stddev = $sd = $stat->standard_deviation();
	if ($stddev < $max_dev_allowed) {
		$counter = scalar(@{$resolves{$_}});
		if ($counter > $min_num_connects) {
			print "$_ $counter connections $stddev deviation\n";
		}
	}
}

#print Dumper \%resolves; ## see what all is in our hash
