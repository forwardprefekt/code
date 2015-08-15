##Mostly ripped from perldoc   
# Distribute freely! / bitnn.com

use Net::XMPP::Client::GTalk    ;
    use Data::Dump qw( dump )       ;

    my $username  = '' ; #no gmail.com
    my $password  = '' ;

    
    my $ob = new Net::XMPP::Client::GTalk(
        USERNAME   =>  $username         ,
        PASSWORD   =>  $password         ,
    );

    $hostname = `hostname`;
    chop($hostname);

    my $limit = 25;
    my $require_run = 1 ;
    my $iteration   = 1 ;
    while( $require_run ) {

        my $message = $ob->wait_for_message( 60 ) ;

        unless( $message ) {
            print "GOT NO MESSAGE - waiting longer\n" ;
        }

        if( $message->{ error } ) {
            print "ERROR \n" ;
            next             ;
        } else {
            dump( $message ) ;
        }


        if( $message->{ message } eq 'HELP' ) {
          $helper = "SET LIMIT:HOSTNAME 25\nEXEC:HOSTNAME COMMAND\nROLLCALL\nEXIT\nPING:HOSTNAME\n";
          $ob->send_message( $message->{ from }, "$hostname: $helper " );
        }


        if( $message->{ message } eq 'exit' ) {
            print "Asked to exit by " . $message->{ from } . "\n" ;
            $message->{ message } = 'Exiting ... ' ;
            $ob->send_message( $message->{ from }, "$hostname: sayonara " );
            $require_run = 0 ;
        }

        if( $message->{ message } =~ /^SET LIMIT:(.*?) (.*)/ ) {
          if ($1 eq $hostname) {
            $limit = $2;
            $ob->send_message( $message->{ from }, "$hostname: Limit changed to: $limit" );
          }
        }


        if( $message->{ message } =~ /^PING:(.*)/ ) {
          if ($1 eq $hostname) {
            $limit = $2;
            $ob->send_message( $message->{ from }, "$hostname: HELLO!" );
          }
        }

        if( $message->{ message } =~ /^ROLLCALL/ ) {
          $ob->send_message( $message->{ from }, "$hostname" );
        }

        if( $message->{ message } =~ /^EXEC:(.*?) (.*)/ ) {
                print "$1 $hostname\n";
          if ($1 eq $hostname) {
            print "Attempting exec $2";
            @result = `$2`;
                if (scalar(@result) <= $limit) {
                  $ob->send_message( $message->{ from },$hostname . join("",@result) );
              } else {
                  $ob->send_message( $message->{ from }, "$hostname: Result exceeds limit: $limit" );
              }
            }
        }

        my @online_buddies = @{ $ob->get_online_buddies() } ;
        $iteration++ ;
    }


    exit() ;
