package Db::Documentum::Tools;

use Carp;
use Exporter;
use Socket;
use Sys::Hostname;
use Db::Documentum qw(:all);
require 5.004;

@ISA = qw(Exporter);
@EXPORT = qw();
$VERSION = '0.1';
$error = "";

@EXPORT_OK = qw(
	dm_Connect
	dm_KrbConnect
	dm_LastError
	dm_LocateServer
	all
	ALL
);

%EXPORT_TAGS = (
	ALL => [qw( dm_Connect dm_KrbConnect dm_LastError dm_LocateServer)],
	all => [qw( dm_Connect dm_KrbConnect dm_LastError dm_LocateServer)]
);

# Connects to the given docbase with the given parameters, and
# returns a session identifer.
sub dm_Connect ($$$;$$) {
	my($docbase,$username,$password,$user_arg_1,$user_arg_2) = @_;
	my($session) = dmAPIGet("connect,$docbase,$username,$password,
							$user_arg_1,$user_arg_2");
	$session;
}

# Returns documentum error information.
sub dm_LastError (;$$$) {
	my($session,$level,$number) = @_;
	my($return_data);
	$session = 'apisession' unless ($session);
	$level = '3' unless ($level);	# Set a default level to report.
	$number = 'all' unless ($number);
	my($message_text) = dmAPIGet("getmessage,$session,$level");
	if ($number eq "all") {
		$return_data = $message_text;
	} else {
		my(@message_list) = split('\n',$message_text);
		for ($i = 0 ; $i < $number ; $i++) {
			$return_data .= sprintf("%s\n",$message_list[$i]);
		}
	}
	$return_data;
}

#
# dm_KrbConnect - Obtains a documentum client session using a K4 session
# 				  ticket.  Requires a compatible dm_check_password utility
#                 on the server side.
sub dm_KrbConnect ($) {
	my($docbase) = @_;
	my($service) = 'documentum';
	my($time) = time();
	my($nonce_prefix) = "KERBEROS_V4_NONCE__";
	my($nonce_data) = "${nonce_prefix}${time}";

	# Find the documentum server we're going to be connecting to from
	# whatever docbroker we're going to find.
	my($server_hostname) = dm_LocateServer($docbase);
	if (! $server_hostname) {
		# dm_LocateServer sets Documentum::Tools::error for us.
		return;
	}

	# We need the address as a four byte packed string for krb_mk_priv.
	my($server_inaddr) = inet_aton($server_hostname);
	if(! $server_inaddr) {
		${'error'} = "Unable to obtain server address.\n";
	}
	
	my($client_hostname) = hostname();
	if (! $client_hostname) {
		${'error'} = "Unable to obtain local hostname.";
		return;
	}

	# We need the address as a four byte packed string for krb_mk_priv.
	my($client_inaddr) = inet_aton($client_hostname);
	if(! $client_inaddr) {
		${'error'} = "Unable to obtain local address.\n";
	}

	my($realm) = Krb4::realmofhost($server_hostname);
	if (! $realm) {
		${'error'} = "Unable to determine realm of host $server_hostname: ";
		${'error'} .= Krb4::get_err_txt($Krb4::error);
		${'error'} .= " [$Krb4::error]\n";
		return;
	}
	my($phost) = Krb4::get_phost($server_hostname,$realm,$service);
	if (! $phost) {
		${'error'} = "Unable to determine instance for host $server_hostname in realm $realm: ";
		${'error'} .= Krb4::get_err_txt($Krb4::error);
		${'error'} .= " [$Krb4::error]\n";
		return;
	}
	my($ticket) = Krb4::mk_req($service,$phost,$realm,200);
	if (! $ticket) {
		${'error'} = "Unable to obtain a ticket: ";
		${'error'} .= Krb4::get_err_txt($Krb4::error);
		${'error'} .= " [$Krb4::error]\n";
		return;
	}
	my($ticket_data) = $ticket->dat;

	my($creds) = Krb4::get_cred($service,$phost,$realm);
	if (! $creds) {
		${'error'} = "Unable to obtain credential data: ";
		${'error'} .= Krb4::get_err_txt($Krb4::error);
		${'error'} .= " [$Krb4::error]\n";
		return;
	}
	my($username) = $creds->pname;
	my($session_key) = $creds->session;
	my($key_schedule) = Krb4::get_key_sched($session_key);
	
	if (! $key_schedule) {
		${'error'} = "Unable to obtain encryption key schedule: ";
		${'error'} .= Krb4::get_err_txt($Krb4::error);
		${'error'} .= " [$Krb4::error]\n";
		return;
	}

	# Construct a nonce for this session.  Here we will use the time
	# encrypted with the session key.
	my($nonce) = Krb4::mk_priv($nonce_data,$key_schedule,$session_key,
									$client_inaddr,$server_inaddr);

#	print STDERR "session_key: $session_key\n";
#	print STDERR "time: $time\n";
#	print STDERR "key_schedule: $key_schedule\n";
#	print STDERR "client_inaddr: $client_inaddr\n";
#	print STDERR "client_addr:", inet_aton($client_inaddr), "\n";
#	print STDERR "server_inaddr: $server_inaddr\n";
#	print STDERR "server_addr:", inet_aton($server_inaddr), "\n";
#	print STDERR "nonce_data: $nonce_data\n";
#	print STDERR "nonce: $nonce\n";
	
	if (! $nonce) {
		${'error'} = "Unable to obtain encrypt nonce: ";
		${'error'} .= Krb4::get_err_txt($Krb4::error);
		${'error'} .= " [$Krb4::error]\n";
		return;
	}
#	print STDERR Krb4::get_err_txt($Krb4::error), "\n";

	# uuencode ticket data, then encode it with URI-style encoding
	my($ticket_data_encoded) = pack "u", $ticket_data;
	$ticket_data_encoded =~ s/([^A-Za-z0-9])/uc sprintf("%%%02x",ord($1))/eg;

	# Same thing for nonce.
	my($nonce_encoded) = pack "u", $nonce;
	$nonce_encoded =~ s/([^A-Za-z0-9])/uc sprintf("%%%02x",ord($1))/eg;

#	print "nonce_encoded: $nonce_encoded\n";

	# Okay.  Now we've got an encoded service ticket for this session.  
	# Send it as our password to the documentum server for
	# validation.  We include the nonce as both additional
	# params, because connect doesn't seem the pass the first one properly.
	my($session_id) = dmAPIGet("connect,$docbase,$username,$ticket_data_encoded,,$nonce_encoded");
	if (! $session_id) {
		${'error'} = "Unable to obtain a docbase session id:\n";
		${'error'} .= dm_LastError();
		return;
	} else {
		return $session_id;
	}
}

# Find the active server for a given docbase.

sub dm_LocateServer ($) {
	my($docbase) = @_;
	my($locator) = dmAPIGet("getservermap,apisession,$docbase");

	if (! $locator) {
		${'error'} = "Unable to get a locator object for docbase [$docbase]\n";
		return;
	}

	my($hostname) = dmAPIGet("get,apisession,$locator,i_host_name");

	if (!$hostname) {
		${'error'} = "Unable to get	a hostname (attr i_host_name) from docbroker for docbase [$docbase]\n";
		return;
	} else {
		return $hostname;
	}
}

1;
__END__

=head1 NAME

Db::Documentum::Tools - Support functions for Db::Documentum.

=head1 SYNOPSIS

	use Db::Documentum::Tools;
	use Db::Documentum::Tools qw(:all);
	$session_id = dm_Connect($docbase);

	$error_msg = dm_LastError($session_id,$level,$number);
	$error_msg = dm_LastError();
	$error_msg = dm_LastError($session_id);
	$error_msg = dm_LastError($session_id,1);

	$session_id = dm_KrbConnect($docbase);

	$hostname = dm_LocateServer($docbase);

=head1 DESCRIPTION

See the README that comes with this package.  These routines are likely
to change.

=head1 LICENSE

The Documentum perl extension may be redistributed under the same terms as Perl.
The Documentum EDMS is a commercial product.  The product name, concepts,
and even the mere thought of the product are the sole property of
Documentum, Inc. and its shareholders.

=head1 AUTHOR

Brian W. Spolarich, ANS Communications, C<briansp@ans.net>

=head1 SEE ALSO

Db::Documentum, perl(1)

=cut
