use ExtUtils::MakeMaker;

print "\n\n\nWelcome to the Db::Documentum installation process.\n";
print "---------------------------------------------------\n\n";

unless ($OS = $^O) {
	   require Config;
	   $OS = $Config::Config{'osname'};
}
print "Configuring Db::Documentum for $OS...\n\n";

##################################################################
# *** Windows NT users should look here ***
##################################################################
if ($OS =~ /Win/i) {

    print "Select a flavor:\n";
    print "\t1) to build the module for EDMS98, or\n";
    print "\t2) to build the module for Documentum 4i\n";
    print "==>";
    chomp($ans = <STDIN>);
    if ($ans =~ /1/) {
        $dmcl = 'dmcl32.lib';
    } else {
        $dmcl = 'dmcl40.lib';
    }

	# Path to Documentum installation directory.
	$DM_HOME = "c:\\program files\\documentum";

    print "\n\n---------------------------------------------------\n";
    print "Documentum install directory:\n\n";
    print "Enter the path to the Documentum Installation directory:\n";
    print "\t[$DM_HOME] ==>";
    chomp($ans = <STDIN>);
    if ($ans =~ /\w+/) {
        $DM_HOME = $ans;
    } else {
        ## noop;
    }


	# Path to Documentum library (dmcl32.lib or dmcl40.lib).
	$DM_LIB = "$DM_HOME\\shared";

    print "\n\n\n---------------------------------------------------\n";
    print "$dmcl library file:\n\n";
    if ($dmcl =~ /32/) {
        print "The $dmcl library file is probably already located in the\n";
        print "$DM_LIB directory.\n";
    } else {
        print "The $dmcl library file is located in the share\\clients\\win\\32\n";
        print "directory on e-Content Server. I recommend copying it to the \n";
        print "$DM_LIB directory for simplicity.\n";
    }
              
    print "\nEnter the path to the $dmcl library file:\n\t[$DM_LIB] ==>";
    chomp($ans = <STDIN>);
    if ($ans =~ /\w+/) {
        $DM_LIB = $ans;
    } else {
        ## noop;
    }

    # check for dmcl library file
    if (! -e "$DM_LIB\\$dmcl") {
        warn "\n*** WARNING *** Could not find $DM_LIB\\$dmcl.\nThe module will not make without " .
             "$dmcl.\nPlease copy $dmcl to the $DM_LIB directory.\n";
    }

	# Path to dmapp.h.
	$DM_INCLUDE = "$DM_HOME\\shared";

    print "\n\n\n---------------------------------------------------\n";
    print "dmapp.h header file:\n\n";

    if ($dmcl =~ /32/) {
        print "The dmapp.h header file is located in the\n";
        print "docpage builder\\samples\\server\\unix\\c directory of the \n";
        print "DocPage Builder CD.\n";
    } else {
        print "The dmapp.h header file is located in the \\share\\sdk\\include\n";
        print "directory on the e-Content Server.\n";
    }

    print "I recommend copying it to the $DM_INCLUDE \n";
    print "directory for simplicity.\n";
              
    print "\nEnter the path to the dmapp.h header file:\n\t[$DM_INCLUDE] ==>";
    chomp($ans = <STDIN>);
    if ($ans =~ /\w+/) {
        $DM_INCLUDE = $ans;
    } else {
        ## noop;
    }

    # check for api header file
    if (! -e "$DM_INCLUDE\\dmapp.h") {
        warn "\n*** WARNING *** Could not find $DM_INCLUDE\\dmapp.h.\nThe module will not make without " .
             "dmapp.h.\nPlease copy dmapp.h to the $DM_INCLUDE directory.\n";
    }
    
    # get the CPP include and lib paths from the environment
    my $inc = $ENV{INCLUDE};
    warn "\n*** WARNING *** No INCLUDE environment variable found.  You may need to run VCVARS32.BAT" .
         " before running nmake.\n" unless $inc;    
    $inc = "-I\"" . join("\" -I\"",split(";",$inc)) . "\"";
    
    my $lib = $ENV{LIB};
    warn "\n*** WARNING *** No LIB environment variable found.  You may need to run VCVARS32.BAT" .
         " before running nmake.\n" unless $lib;
    $lib = "-L\"" . join("\" -L\"",split(";",$lib)) . "\"";
                
    # build all nmake parameters
    $CPP_INCS = $inc;
    $DM_INCLUDE = "-I\"$DM_INCLUDE\"";
	$CPP_LIBS = $lib;
	$DM_CLIENT_LIBS = "-L\"$DM_LIB\" -l$dmcl";
    # Not used for Win32 nmake
	$LD_LIBS = "";
	$DM_RPC_LIBS = "";
	$OS_LIBS = "";
}

##################################################################
# *** Unix users (Solaris, AIX, and HP/UX) should look here ***
##################################################################
elsif ( ($OS =~ /solaris/i) or ($OS =~ /aix/i) or ($OS =~ /hpux/i) ) {

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
}

##################################################################
# Otherwise you're out of luck.  Documentum doesn't support you, so
# how can we?
##################################################################
else {
	die "$OS is not a supported platform for Db::Documentum (or for Documentum in general).\n";
}

# print config summary
print "\n\n\n---------------------------------------------------\n";
print "Config summary:\n\n";
print "DM_INCLUDE = $DM_INCLUDE\n";
print "CPP_INCS = $CPP_INCS\n";
print "DM_CLIENT_LIBS = $DM_CLIENT_LIBS\n";
print "CPP_LIBS = $CPP_LIBS\n";
print "LD_LIBS = $LD_LIBS\n";
print "DM_RPC_LIBS = $DM_RPC_LIBS\n";
print "OS_LIBS = $OS_LIBS\n\n";

# write makefile

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

	# This makes 'make ppd' happy
	($] ge '5.005')
	? (
	    'AUTHOR'   => 'M. Scott Roth (michael.s.roth@saic.com)',
	    'ABSTRACT_FROM' => 'Documentum.pm',
	  )
	: (),

	# This is just here to make 'make dist' easier to run.
	'dist' => { COMPRESS=>"gzip", SUFFIX=>"gz" }
);

# __EOF__