# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; $numtests = 7 ; print "1..$numtests\n"; }
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
    $message_text;
}

$counter = 2; $success = 1;

if (! $ENV{'DMCL_CONFIG'}) {
	print "Enter the path to your DMCL_CONFIG file: "; chomp ($dmcl_config = <STDIN>);
	if (-r $dmcl_config) { $ENV{'DMCL_CONFIG'} = $dmcl_config; } 
	else { die "Can't find DMCL_CONFIG '$dmcl_config': $!.  Exiting."; }
} 

print "Using '$ENV{'DMCL_CONFIG'}' as client config.\n";
print "Docbase name: "; chomp ($docbase = <STDIN>);
print "Username: "; chomp ($username = <STDIN>);
print "Password: "; chomp ($password = <STDIN>);

# Here's the bulk of our test suite.

# Test DM client connect.
do_it("connect,$docbase,$username,$password",NULL,"dmAPIGet",
		"DM client connection");
# Test DM object creation.
do_it("create,current,dm_document",NULL,"dmAPIGet","DM object creation");
# Test DM set
do_it("set,current,last,object_name","Perl Module Test","dmAPISet",
		"DM attribute set");
# Test DM exec
do_it("link,current,last,/Temp",NULL,"dmAPIExec","DM object link");
# Test DM save
do_it("save,current,last",NULL,"dmAPIExec","DM save.");
# Test DM disconnect
do_it("disconnect,current",NULL,"dmAPIExec","DM disconnect.");

if ($success == $numtests) {
	print "\nAll tests completed successfully.\n";
} else {
	print "\nAll tests complete.  ", $numtests - $success, " of $numtests tests failed.\n";
	print "If tests fail and the above error output is not helpful check your server logs.\n"; 
}

sub do_it ($$$$) {
	my($method,$value,$function,$description) = @_;
	my($result);

	if ($function eq 'dmAPIGet') {
		$result = dmAPIGet($method);
	} elsif ($function eq 'dmAPIExec') {
		$result = dmAPIExec($method);
	} elsif ($function eq 'dmAPISet') {
		$result = dmAPISet($method,$value);
	} else {
		die "$0: Unknown function: $function";
	}

	if (! $result) { print "not "; }
	print "ok $counter # $description [$function()]\n";

	if ($result) { 
		$success++; 
	} else { 
		print dm_LastError("current");	
	}
	$counter++;
}
