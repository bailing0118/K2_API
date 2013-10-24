use strict;
use warnings;
use Data::Dumper;
use LWP::UserAgent;
use LWP::Simple qw(get);
use HTTP::Request::Common qw(GET);
use HTTP::Cookies;
use JSON qw(from_json);
use JSON qw(decode_json);

print "Enter a username: ";
my $username = <STDIN>;

print "Enter a password: ";
my $password = <STDIN>;

my $sessionid;

my $cookie_jar = HTTP::Cookies->new(
   file=>'lwp_cookies.txt',
   autosave=>1,
   ignore_discard=>1,
);

my $ua = LWP::UserAgent->new(
   cookie_jar=>$cookie_jar,
);

my $url = GET 'http://mocks.k2.mountain.siriusxm.com/rest/experience.json/module/create/authentication?username='.$username.'&password='.$password.'&api_key=special-key';
#print "Request: ".$url."\n";

my $res = $ua->request($url);

  if ($res->is_success) {
     print $res->content;
   } else {
     print $res->status_line."\n";
   }

my $decoded = from_json($res->content);

#print "response: ".Dumper($decoded);

my @messages = @{$decoded->{'messages'}};

my @moduleset = @{$decoded->{'moduleSet'}{'module'}};


foreach my $code (@messages) {

    print "\n\nCode: ".$code->{'code'}."\n";
    print "Message: ".$code->{'message'}."\n";


    if ($code->{'code'} == 100) {
       print "Success Response Code. PASS!\n";
    }

    else {
       print "Unsuccess Response Code. FAIL!\n";
    }

}
     
     foreach my $c (@moduleset) {


     print "module Area: ".$c->{'moduleArea'}."\n";
     print "module Type: ".$c->{'moduleType'}."\n";
     print "authentication data's session ID: ".$c->{'moduleDetails'}{'authenticationData'}{'sessionID'}."\n";
        
     if ($c->{'moduleDetails'}{'authenticationData'}{'sessionID'} eq "") {
        print "Empty authentication data.  FAIL! \n";
     }

     else {
        print "Valid authentication data. PASS! \n";
        $sessionid = $c->{'moduleDetails'}{'authenticationData'}{'sessionID'};
     }


    }


#AUTHENTICATION COMPLETED, NOW ONTO LIVE CHANNEL REQUEST.
print "\n\nAUTHENTICATION COMPLETED, NOW ONTO LIVE CHANNEL REQUEST.\n";

print "Enter value for format: ";
my $format = <STDIN>;



my $urla = GET 'http://mocks.k2.mountain.siriusxm.com/rest/experience.json/module/create/liveChannelList?format='.$format.'&api_key=special-key';
#print "Request: ".$urla."\n";

my $resa = $ua->request($urla);

  if ($resa->is_success) {
     print $resa->content;
   } else {
     print $resa->status_line."\n";
   }


my $decodeda = from_json($resa->content);

my $errorcount;
$errorcount = 0;

print "\nNOTE: CHANNEL LINEUP RESPONSE WILL ALSO BE OUTPUTED TO CHANNEL_LINEUP_RESPONSE.TXT.\n";

open (FILE, ">\\perl\\projects\\channel_lineup_response.txt");
print FILE Dumper($decodeda);

my @messagesa = @{$decodeda->{'messages'}};

foreach my $b (@messagesa) {

   print "\nMessage Status Code: ".$b->{'code'}."\n";
   print "Message: ".$b->{'message'}."\n";
   if ($b->{'code'} != 100) {
      die("BAD ERROR RESPONSE CODE. ABORTING.\n");
   }
   print "SUCCESSFUL STATUS CODE. PASS!\n\n";   
}


my @moduleseta = @{$decodeda->{'moduleSet'}{'module'}};


foreach my $d (@moduleseta) {

    my @categorylist = @{$d->{'moduleDetails'}{'categoryList'}{'category'}};
    my @channellist = @{$d->{'moduleDetails'}{'channelList'}{'channel'}};
     

    foreach (@categorylist) {
       if (ref($_->{'genre'}) eq 'ARRAY') {
         my @genre = @{$_->{'genre'}};

        foreach (@genre) {
         if (ref($_->{'channel'}) eq 'ARRAY') {
         my @channel = @{$_->{'channel'}};
          print "Genre: ".$_->{'name'}."\n";
          
           
	  foreach my $e (@channel) {
           print $e->{'contentId'}."\n";

           if ($e->{'contentId'} eq "") {
             print "No content ID for channel. \n";  
             $errorcount++;
        }
       }
      }
     }
    }
   }
     if ($errorcount == 0) {
         print "\nALL CHANNELS CONTAIN CONTENT IDS. PASS!\n";
     }   else  {
         print "ERRORS DETECTED: ".$errorcount.". FAIL!\n";
     }

print "\nChannels from channel list: \n";  
    
    foreach (@channellist) {
      print "\nChannel: ".$_->{'contentId'}."\n";

       if($_->{'contentId'} eq "") {
          print "No Content ID for channel ".$_->{'name'}."\n";
          $errorcount++;
       }
          print "Mature Flag: ".$_->{'isMature'}."\n";

       if($_->{'siriusChannelNo'} eq "") {
          print "No Sirius channel number set for channel ".$_->{'name'}."\n";
          $errorcount++;
       }
       if($_->{'xmChannelNo'} eq "") {
          print "No XM channel number set for channel ".$_->{'name'}."\n";
          $errorcount++;
       }
       if($_->{'order'} eq "") {
          print "No order set for channel ".$_->{'name'}."\n";
          $errorcount++;
       }

       print "MySXM Flag: ".$_->{'isMySxm'}."\n";
       

       if($_->{'displayName'} eq "") {
          print "No display name set for channel ".$_->{'name'}."\n";
          $errorcount++;
       }        
           
}

   print "\nTotal error count: ".$errorcount."\n";

   if ($errorcount == 0) {
      print "No error found. PASS! \n";
   }
   
   else {
      print "Test FAIL! \n";
   }

}




 





