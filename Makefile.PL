use ExtUtils::MakeMaker;

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

$DM_CLIENT_LIBS = "-L$DM_LIB -ldmapi -ldmupper -ldmlower -ldmcommon -ldmupper 
                   -lcompat";
$DM_RPC_LIBS = "-L$DM_LIB -lnwrpc -lnwstcp";
$OS_LIBS = "-lsocket -lnsl -lintl";
$CPP_LIBS = "-lC";
$LD_LIBS = "-ldl";

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

    'DEFINE'	=> '-DSQLNETV2 -DSYSV -Dsolaris -DOS_UNIX',
    'INC'	=> "-I$DM_INCLUDE"
);
