use ExtUtils::MakeMaker;

# The path to your Documentum client libraries.
$DM_HOME = '/usr/local/documentum';

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
    'DEFINE'	=> '-DSQLNETV2 -DSYSV -Dsolaris -DOS_UNIX',
    'INC'	=> "-I$DM_INCLUDE"
);
