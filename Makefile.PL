use ExtUtils::MakeMaker;

unless ($OS = $^O) {
	   require Config;
	   $OS = $Config::Config{'osname'};
}

if ($OS =~ /Win/i) {

    # *** Windows NT users should look here ***

	# DM_HOME:
	# Path to Documentum installation directory.
	$DM_HOME = "c:\\program files\\documentum";

	# DM_LIB:
	# Path to Documentum libraries (dmcl32.lib or dmcl40.lib).
	#
	# *** EDMS 98 ***
	# The dmcl32.lib is probably already in this directory.
	#
	# *** 4i ***
	# The dmcl40.lib can be found on your 4i server in:
	#       <DOCUMENTUM>/share/clients/win/32.
	# I suggest putting it here for simplicity.
	$DM_LIB = "$DM_HOME\\shared";

	# DM_INCLUDE:
	# Path to dmapp.h and required MS .h files.
	# dmapp.h is not in DM_HOME/shared by default; I suggest putting it here
	# for simplicity.
	#
	# *** EDMS 98 ***
	# If you are using EDMS 98, you can find dmapp.h on the DocPage Builder CD in:
	#   <cd>:\docpage builder\samples\server\unix\c.
	#
	# *** 4i ***
	# If you are using 4i, you can find dmapp.h on your server's hard drive in:
	#   <DOCUMENTUM>/share/sdk/include.
	#
    # Note the use of the literal double-quote.  Paths with spaces tend to throw
    # MakeMaker.
	$DM_INCLUDE = "-I\"$DM_HOME\\shared\"";

    # DM_CLIENT_LIBS:
    # The Documentum link library.
    # Again, note the use of the literal double-quote.
    #
    # *** EDMS 98 ***
	# Use the following library directive if you are linking for EDMS 98.
	# Make sure the dmcl32.lib is in your path or in the DM_HOME\shared directory.
	# Make sure you are using the dmapp.h file for EDMS 98.
	#$DM_CLIENT_LIBS = "-L\"$DM_LIB\" -ldmcl32.lib";
    #
	# *** 4i ***
	# Use the following library directive if you are linking for Documentum 4i.
	# Make sure the dmcl40.lib is in your path or in the DM_HOME\shared directory.
	# Make sure you are using the dmapp.h file for 4i.
	$DM_CLIENT_LIBS = "-L\"$DM_LIB\" -ldmcl40.lib";

	# CPP_LIBS:
	# Path to MS libs.
	# Again, note the use of double-quotes.
	$CPP_LIBS = "-L\"d:\\program files\\microsoft visual studio\\vc98\\lib\"";

	# CPP_INCS:
	# Path to MS .h files.
	# Again, note the use of double-quotes.
    $CPP_INCS = "-I\"d:\\program files\\microsoft visual studio\\vc98\\mfc\\src\"";

    # Not used for Win32 make.
	$LD_LIBS = "";
	$DM_RPC_LIBS = "";
	$OS_LIBS = "";

} elsif ( ($OS =~ /solaris/i) or ($OS =~ /aix/i) or ($OS =~ /hpux/i) ) {

    # *** Unix users (Solaris, AIX, and HP/UX) should look here ***

	# The path to your Documentum client installation.
	$DM_HOME = '/usr/local/documentum';

	# If you've organized your Documentum libraries in the standard unix-y
	# bin, lib, include fashion, then you should be all set.  Otherwise you
	# may have to tweak these.

	# Path to documentum client libraries.
	$DM_LIB = "$DM_HOME/lib";

	# Path to directory where dmapp.h lives.
	$DM_INCLUDE = "-I$DM_HOME/include";

	$DM_CLIENT_LIBS = "-L$DM_LIB -ldmapi -ldmupper -ldmlower -ldmcommon -ldmupper -lcompat";
	$DM_RPC_LIBS = "-L$DM_LIB -lnwrpc -lnwstcp";
	$OS_LIBS = "-lsocket -lnsl -lintl";
	$CPP_LIBS = "-lC";
	$LD_LIBS = "-ldl";
	$CPP_INC = "";

} else {

    # Otherwise you're out of luck.  Documentum doesn't support you, so how
    # can we?
	die "$OS is not a supported platform for Db::Documentum (or for Documentum in general).\n";
}

print "Configuring Db::Documentum for $OS...\n";

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
	'NAME'	=> 'Db::Documentum',
	'VERSION_FROM' => 'Documentum.pm',
	'LIBS'	=> ["$LD_LIBS $DM_CLIENT_LIBS $DM_RPC_LIBS $CPP_LIBS $OS_LIBS"],

# UNIX:
# You can also link against the shared client library if you want.  You'll need
# to have libC.so, libdmcl.so, and libc.so in your LD_LIBRARY_PATH.  This
# slows things down a little bit, but drastically decreases the size of the
# Documentum.so library.  Uncomment the LIBS expression below and comment out
# the one above if you want to use the shared libraries.
#    'LIBS'	=> ["-lC -ldmcl -lc"],

	'DEFINE'	=> '-DSQLNETV2 -DSYSV -D$OS -DOS_UNIX',
	'INC'	=> "$DM_INCLUDE $CPP_INCS",

	# This is just here to make 'make dist' easier to run.
	'dist' => { COMPRESS=>"gzip", SUFFIX=>"gz" }
);
