# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; $numtests = 9 ; print "1..$numtests\n"; }
END {print "not ok 1 # Module load.\n" unless $loaded;}
use Db::Documentum qw(:all);
$loaded = 1;
print "ok 1 # Module load.\n";

######################### End of black magic.

sub dm_LastError {
    my($session,$level) = @_;
    $level = '3' unless ($level);       # Set a default level to report.
    $session = 'apisession' unless ($session);
    my($message_text) = dmAPIGet("getmessage,$session,$level");
    my(@message_list) = split('\n',$message_text);
    my($return_data) = sprintf("%s\n",$message_list[0]);
    $return_data;
}

$counter = 2;
print "Enter the path to your DMCL_CONFIG file: "; chomp ($dmcl_config = <STDIN>);
print "Docbase name: "; chomp ($docbase = <STDIN>);
print "Username: "; chomp ($username = <STDIN>);
print "Password: "; chomp ($password = <STDIN>);

if (-r $dmcl_config) { $ENV{'DMCL_INI'} = $dmcl_config; } 
else { die "Can't find DMCL_INI '$dmcl_config': $!.  Exiting."; }

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

# Test DM client library initialization.
$result = dmAPIInit();
if (! $result) {
   print "not ";
}
print "ok $counter # DM client library initialization (dmAPIInit()).\n";
$counter++;

# Test DM client connect.
$result = dmAPIGet("connect,$docbase,$username,$password");
if (! $result) {
   print "not ";
}
if (! $result) {
	print dm_LastError();
}

print "ok $counter # DM client connection (dmAPIGet((connect)).\n";
$counter++;

# Test DM object creation.
$result = dmAPIGet("create,current,dm_document");
if (! $result) {
   print "not ";
}
print "ok $counter # DM object creation (dmAPIGet(create)).\n";
$counter++;

# Test DM set
$result = dmAPISet("set,current,last,object_name","Perl Module Test");
if (! $result) {
   print "not ";
}
print "ok $counter # DM attribute set (dmAPISet(set)).\n";
$counter++;

# Test DM exec
$result = dmAPIExec("link,current,last,/Temp");
if (! $result) {
   print "not ";
}
print "ok $counter # DM object link (dmAPIExec(link)).\n";
$counter++;

# Test DM save
$result = dmAPIExec("save,current,last");
if (! $result) {
   print "not ";
}
print "ok $counter # DM save (dmAPIExec(save)).\n";
$counter++;

# Test DM disconnect
$result = dmAPIExec("disconnect,current");
if (! $result) {
   print "not ";
}
print "ok $counter # DM disconnect (dmAPIExec(disconnect)).\n";
$counter++;

# Test DM client library teardown
$result = dmAPIDeInit();
if (! $result) {
   print "not ";
}
print "ok $counter # DM client library teardown (dmAPIDeInit()).\n";
$counter++;
