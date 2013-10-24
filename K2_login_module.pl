use strict;
use warnings;
use Data::Dumper;
use LWP::Simple qw(get);
use JSON qw(from_json);
use JSON qw(decode_json);


print "Enter a username: ";
my $username = <STDIN>;

print "Enter a password: ";
my $password = <STDIN>;


my $url = 'http://mocks.k2.mountain.siriusxm.com/rest/experience.json/module/create/authentication?username='.$username.'&password='.$password.'&api_key=special-key';
print "Request: ".$url."\n";
my $decoded = from_json(get($url));

print "response: ".Dumper($decoded);

my @messages = @{$decoded->{'messages'}};

my @moduleset = @{$decoded->{'moduleSet'}};


foreach my $code (@messages) {

    print "Code: ".$code->{'code'}."\n";
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
     }

}
 





