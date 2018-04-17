#!/usr/bin/env perl
#
# energenie.pl - Perl script to demonstrate the control
#                of an Energenie Pi-mote control board.
#
# Version 1.0 (C) 2014 Andrew Rawlins (awr-energenie@fermit.org.uk)
#
# Usage - Ensure you call do_setup at the start, after that call
#         do_switch passing the socket number and state (ON or OFF).
#
#         You will need to program the sockets with the remote 
#         control before using this script.

use strict;
use warnings;

&do_setup;

&do_switch(0, "ON");
sleep(2);
&do_switch(0, "OFF");

exit 1;

sub do_switch() {

	my $socket = $_[0];
	my $state = $_[1];

	print "Setting socket " . $socket . " to state " . $state . "\n";

	if ($socket eq 1) {	
		if ($state eq "ON") {
			&do_gpio(27,1);
			&do_gpio(23,1);
			&do_gpio(22,1);
			&do_gpio(17,1);
		} else {
			&do_gpio(27,0);
			&do_gpio(23,1);
			&do_gpio(22,1);
			&do_gpio(17,1);
		}
	}
	
	if ($socket eq 2) {
		if ($state eq "ON") {
			&do_gpio(27,1);
			&do_gpio(23,1);
			&do_gpio(22,1);
			&do_gpio(17,0);
		} else {
			&do_gpio(27,0);
			&do_gpio(23,1);
			&do_gpio(22,1);
			&do_gpio(17,0);
		}
	}

	if ($socket eq 3) {
		if ($state eq "ON") {
			&do_gpio(27,1);
			&do_gpio(23,1);
			&do_gpio(22,0);
			&do_gpio(17,1);
		} else {
			&do_gpio(27,0);
			&do_gpio(23,1);
			&do_gpio(22,0);
			&do_gpio(17,1);
		}
	}

	if ($socket eq 4) {
		if ($state eq "ON") {
			&do_gpio(27,1);
			&do_gpio(23,1);
			&do_gpio(22,0);
			&do_gpio(17,0);
		} else {
			&do_gpio(27,0);
			&do_gpio(23,1);
			&do_gpio(22,0);
			&do_gpio(17,0);
		}
	}

	# No socket has the ID of 0 so we use this for all sockets
	if ($socket eq 0) {
		if ($state eq "ON") {
			&do_gpio(27,1);
			&do_gpio(23,0);
			&do_gpio(22,1);
			&do_gpio(17,1);
		} else {
			&do_gpio(27,0);
			&do_gpio(23,0);
			&do_gpio(22,1);
			&do_gpio(17,1);
		}
	}
	
	# Let the encoder settle - seems to need longer in perl
	# than python.  1 Second does it.
	sleep(1);

	# Enable the modulator
	&do_gpio(25,1);
	# Keep enabled for a period
	sleep(1);
	# Disable the modulator
	&do_gpio(25,0);

}

sub do_setup() {
	
	&do_export(27);	#D3 
	&do_export(23); #D2
	&do_export(22); #D1
	&do_export(17); #D0
	&do_export(24); #OOK/FSK
	&do_export(25); #CE Modulator

}

# Some libraries exist to do the following, this seems to work and allows this to be
# stand alone ...

sub do_export() {

	my $gpio = $_[0];

	open(my $gpio_ctl, '>', '/sys/class/gpio/export');
	print $gpio_ctl $gpio . "\n";
	close $gpio_ctl;

	open(my $gpio_dir, '>', '/sys/class/gpio/gpio' . $gpio . '/direction') or die "Could not open GPIO $!";
	print $gpio_dir "out\n";
	close $gpio_dir;

}

sub do_gpio() {

	my $gpio = $_[0];
	my $action = $_[1];

	open(my $gpio_val, '>', '/sys/class/gpio/gpio' . $gpio . '/value') or die "Could not open GPIO $!";
	print $gpio_val $action . "\n";
	close $gpio_val

}

