package Db::Documentum;

use strict;
use Carp;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $AUTOLOAD);

use Exporter;
require DynaLoader;
require AutoLoader;

@ISA = qw(Exporter DynaLoader);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT = qw();
$VERSION = '0.92';

@EXPORT_OK = qw(
	dmAPIInit
	dmAPIDeInit
	dmAPIGet
	dmAPISet
	dmAPIExec
	ALL
	all
);

%EXPORT_TAGS = (
	ALL => [qw( dmAPIInit dmAPIDeInit dmAPIGet dmAPISet dmAPIExec )],
	all => [qw( dmAPIInit dmAPIDeInit dmAPIGet dmAPISet dmAPIExec )]
);

sub AUTOLOAD {
    # This AUTOLOAD is used to 'autoload' constants from the constant()
    # XS function.  If a constant is not found then control is passed
    # to the AUTOLOAD in AutoLoader.

    my $constname;
    ($constname = $AUTOLOAD) =~ s/.*:://;
    my $val = constant($constname, @_ ? $_[0] : 0);
    if ($! != 0) {
	if ($! =~ /Invalid/) {
	    $AutoLoader::AUTOLOAD = $AUTOLOAD;
	    goto &AutoLoader::AUTOLOAD;
	}
	else {
		croak "Your vendor has not defined Db::Documentum macro $constname";
	}
    }
    eval "sub $AUTOLOAD { $val }";
    goto &$AUTOLOAD;
}

bootstrap Db::Documentum $VERSION;

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

Db::Documentum - Perl extension for Documentum Client Libraries.

=head1 SYNOPSIS

	use Db::Documentum;
	use Db::Documentum qw(:all);

	$scalar = dmAPIInit();

	$string = dmAPIGet(<method>);
	$string = dmAPIGet("connect,docbase,username,password");

	$scalar = dmAPIExec(<method>);
	$scalar = dmAPIExec("create,current,dm_document");

	$scalar = dmAPISet(<method>,<value>);
	$scalar = dmAPISet("set,current,last,object_name","My Document");

	$scalar = dmAPIDeInit();


=head1 DESCRIPTION

The B<Db::Documentum> module provides a perl5 modular interface to the 
client libraries for the Documentum Enterprise Document Management
System (EDMS).  You must have already obtained the necessary libraries and
purchased the necessary licenses from documentum before you can build
this module.  For more information on Documentum EDMS, see 
I<http://www.documentum.com/>

This module provides an interface to the five listed API functions
above.  For most purposes, these are the only functions you need to
use, as the bulk of the API is implemented as server methods accessed
by one of the API commands.  The API commands differ only in what
their return value is expected to be.  B<dmAPIExec> is expected to
return a scalar (1 or 0) which can be evaluated to determine success (1 for
success).  B<dmAPISet> also return a scalar, but takes two arguments,
the method argument and the value to use.  B<dmAPIGet> takes a single
argument and returns a string containing the results.  This string,
which may contain an object or query collection identifier can be used later 
with other method calls.

This module by default does not import all of its symbols into the calling
package's namespace.  Therefore, the Documentum API commands must be
called with the fully-qualified package path:

	Db::Documentum::dmAPIGet

To use the module functions without having to supply the module name,
use the second form of the "use" statement shown above:

	use Db::Documentum qw(:all);

That said, check your Documentum documentation for complete information
on how to interact with the Documentum server.

=head1 WARRANTY

There is none, implied, expressed, or otherwise.  I'm providing this gratis, 
out of the goodness of my tiny little heart.  If it breaks, you get what you 
pay for.  Talk to Documentum about supporting a Perl interface. :-)

=head1 LICENSE

The Documentum perl extension may be redistributed under the same terms as Perl.
The Documentum EDMS is a commercial product.  The product name, concepts,
and even the mere thought of the product are the sole property of 
Documentum, Inc. and its shareholders.

=head1 AUTHOR

Brian W. Spolarich, ANS Communications, C<briansp@ans.net>

=head1 SEE ALSO

perl(1).

=cut
