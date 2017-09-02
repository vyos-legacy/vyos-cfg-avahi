#!/usr/bin/perl

use Getopt::Long;
use POSIX;
use File::Compare;

use lib '/opt/vyatta/share/perl5';
use Vyatta::Config;

use warnings;
use strict;

my $executable = '/opt/vyatta/sbin/mdns-repeater';
my $pid_file = '/var/run/mdns-repeater.pid';

sub stop_daemon {
    my $cmd = "start-stop-daemon -q --stop --oknodo --pidfile $pid_file";
    system($cmd);
}

sub restart_daemon {
    stop_daemon();
    my $config = new Vyatta::Config;
    my $path = 'service mdns repeater';
    $config->setLevel($path);
    my @interfaces = $config->returnValues('interface');
    if (scalar(@interfaces) < 2) {
        print "You must configure at least two valid interfaces.\n";
        exit 1;
    }
    if (scalar(@interfaces) > 5) {
        print "Cannot configure more than five interfaces.\n";
        exit 1;
    }
    my $args = join(' ', @interfaces);
    my $cmd = "start-stop-daemon -q --start --exec \"${executable}\" -- ${args} -p \"${pid_file}\"";
    system($cmd);
}

my ($update, $stop);

GetOptions(
    "update!"   => \$update,
    "stop!"     => \$stop,
);

if ($update) {
    restart_daemon();
    exit 0;
}

if ($stop) {
    stop_daemon();
    exit 0;
}

exit 1;

# end of file
