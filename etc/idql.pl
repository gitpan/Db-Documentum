#! /usr/local/bin/perl -w
# idql.pl
# (c) 2000-2004 MS Roth

# ver 1.0 - July 2000
#           * Initially released with 'An Introduction to Db::Documentum'
# ver 1.1 - October 2000
#           * Updated slightly for and released with Db::documentum 1.4
# ver 1.2 - November 2000
#           * Minor updates to fix results formatting problem
# ver 1.3 - September 2004
#           * Made results column width's only as wide as necessary

use Db::Documentum qw(:all);
use Db::Documentum::Tools qw (:all);
use Term::ReadKey;
$VERSION = "1.3";

logon();

# ===== main loop =====
$cmd_counter = 1;
while (1) {
    print "$cmd_counter> ";
    chomp($cmd = <STDIN>);
    if ($cmd =~ /go$/i) {
        do_DQL($DQL);
        $DQL = "";
        $cmd_counter = 0;
    } elsif ($cmd =~ /quit$/i) {
        do_Quit();
    } else {
        $DQL .= " $cmd";
    }
    $cmd_counter++;
}

sub logon {
    ReadMode 'normal';
    print "\n" x 5;
    print "(c) 2004 MS Roth. Distributed as part of Db::Documentum\n";
    print "Db::Documentum Interactive Document Query Language Editor $VERSION\n";
    print "----------------------------------------------------------------\n";
    print "Enter Docbase Name: ";
    chomp ($DOCBASE = <STDIN>);
    print "Enter User Name: ";
    chomp ($USERNAME = <STDIN>);
    print "Enter Password: ";
    # turn off display
    ReadMode 'noecho';
    chomp ($PASSWD = <STDIN>);
    # turn display back on
    ReadMode 'normal';

    # login
    $SESSION = dm_Connect($DOCBASE,$USERNAME,$PASSWD);
    die dm_LastError() unless $SESSION;

    my $host = dm_LocateServer($DOCBASE);
    print "\nLogon to $DOCBASE\@$host successful. Type 'quit' to quit.\n\n";
}

sub do_DQL {
    my $dql = shift;

    print "\n\n";

    # do query
    $api_stat = dmAPIExec("execquery,$SESSION,F,$dql");

    if ($api_stat) {
        $col_id = dmAPIGet("getlastcoll,$SESSION");

        # get attr count so we know how many columns in result set
        $attr_count = dmAPIGet("get,$SESSION,$col_id,_count");

        if ($attr_count > 0) {
            # get names and lengths of attrs
            my @attr_names = ();
            my @attr_lengths = ();
            my @rows = ();

            for ($i=0; $i<$attr_count; $i++) {
               push(@attr_names,dmAPIGet("get,$SESSION,$col_id,_names[$i]"));
               push(@attr_lengths,length($attr_names[$i]));
            }

            # get rows
            $row_counter = 0;
            while (dmAPIExec("next,$SESSION,$col_id")) {
                my $attr_counter = 0;
                my $attr_string = "";

                foreach my $attrname (@attr_names) {
                    my $value = dmAPIGet("get,$SESSION,$col_id,$attrname");

                    # build delimited string for each row
                    $attr_string .= $value . "::";

                    # update column width is value exceeds current width
                    if (length($value) > $attr_lengths[$attr_counter]) {
                        $attr_lengths[$attr_counter] = length($value);
                    }
                    $ attr_counter++;
                }

                # save delimited row
                push(@rows,$attr_string);
                $row_counter++;
            }
            dmAPIExec("close,$SESSION,$col_id");

            # print attr names
            for ($i=0; $i<$attr_count; $i++) {
                print $attr_names[$i];
                print " " x ($attr_lengths[$i] - length($attr_names[$i]));
                print " ";
            }
            print "\n";

            # print underbars for attr names
            for ($i=0; $i<$attr_count; $i++) {
                print "-" x $attr_lengths[$i];
                print " ";
            }
            print "\n";

            # print results
            foreach my $row (@rows) {

                # split string on delimiter
                my @cols = split('::',$row);
                my $col_count = 0;

                foreach (@cols) {
                    print $_ ;
                    print " " x ($attr_lengths[$col_count] - length($_));
                    print " ";
                    $col_count++;
                }
                print "\n";
            }

            print "\n[$row_counter row(s) affected]\n\n";

        }
    }
    print dm_LastError($SESSION,3,'all');
}


sub do_Quit {
    print "\n\nQuitting!\n\n";
    dmAPIExec("disconnect,$SESSION");
    exit;
}


## -----------------
##      <SDG><
## -----------------

# __EOF__