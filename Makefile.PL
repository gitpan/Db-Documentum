use ExtUtils::MakeMaker;

unless ($OS = $^O) {
	   require Config;
	   $OS = $Config::Config{'osname'};
}
# Windows NT users should look here.
if ($OS =~ /Win/i) {
	# Path to Documentum installation directory.  Note the use of the ugly
	# DOS-style truncation of 'program files' to 'progra~1'. The space 
	# between 'program' and 'files' throws MakeMaker.
	$DM_HOME = "c:\\progra~1\\documentum";
	# Path to dmcl32.lib
	$DM_LIB = "$DM_HOME\\shared";
	# Path to dmapp.h.  This file is not here by default.  In fact, 
	# it is not even installed by default.  It is found on the DocPage 
	# Builder CD in the
	# <cd>:\docpage builder\samples\server\unix\c directory.  
	# I suggest putting it here for simplicity.
	$DM_INCLUDE = "$DM_HOME\\shared";
	$DM_CLIENT_LIBS = "-L$DM_LIB -ldmcl32.lib";
	# The remaining variables are not used for the NT build of Db::Documentum.
	$DM_RPC_LIBS = "";
	$OS_LIBS = "";
	$CPP_LIBS = "";
	$LD_LIBS = "";
# Unix users (Solaris, AIX, and HP/UX) should look here.
} elsif ( ($OS =~ /solaris/i) or ($OS =~ /aix/i) or ($OS =~ /hpux/i) ) {
	# The path to your Documentum client installation.
	#$DM_HOME = '/usr/local/documentum';
	$DM_HOME = '/afs/ans.net/@sys/pkg/dmcl-3.15';
	# If you've organized your Documentum libraries in the standard unix-y
	# bin, lib, include fashion, then you should be all set.  Otherwise you
	# may have to tweak these.
	# Path to documentum client libraries.
	$DM_LIB = "$DM_HOME/lib";
	# Path to directory where dmapp.h lives.
	$DM_INCLUDE = "$DM_HOME/include";
	$DM_CLIENT_LIBS = "-L$DM_LIB -ldmapi -ldmupper -ldmlower -ldmcommon -ldmupper -lcompat";
	$DM_RPC_LIBS = "-L$DM_LIB -lnwrpc -lnwstcp";
	$OS_LIBS = "-lsocket -lnsl -lintl";
	$CPP_LIBS = "-lC";
	$LD_LIBS = "-ldl";
# Otherwise you're out of luck.  Documentum doesn't support you, so how
# can we?
} else {
	die "$OS is not a supported platform for Db::Documentum (or for Documentum in general).\n";
}

print "Configuring Db::Documentum for $OS...\n";
   
##
##

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
	'NAME'	=> 'Db::Documentum',
	'VERSION_FROM' => 'Documentum.pm', 
	'LIBS'	=> ["$LD_LIBS $DM_CLIENT_LIBS $DM_RPC_LIBS $CPP_LIBS $OS_LIBS"],   

# You can also link against the shared client library if you want.  You'll need
# to have libC.so, libdmcl.so, and libc.so in your LD_LIBRARY_PATH.  This
# slows things down a little bit, but drastically decreases the size of the
# Documentum.so library.  Uncomment the LIBS expression below and comment out
# the one above if you want to use the shared libraries.
#    'LIBS'	=> ["-lC -ldmcl -lc"],   

	'DEFINE'	=> '-DSQLNETV2 -DSYSV -D$OS -DOS_UNIX',
	'INC'	=> "-I$DM_INCLUDE",

	# This is just here to make 'make dist' easier to run.
	'dist' => { COMPRESS=>"gzip", SUFFIX=>"gz" }
);
