#!/usr/bin/env perl
#
# energenie-perl.pl - Perl script to control an Energenie Pi-mote control board.
#
# Version 1.1 (C) 2014 Andrew Rawlins (awr-energenie@fermit.org.uk)

#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
# ChangeLog
# 
#  1.1 - Add training options (Ian Cook - ian@elder-studios.co.uk)
#      - Arrays exist in Perl.
#      - \t -> '    '
#      - Pin numbers are different on pi rev1
#
# 1.0  - Inital Release (Andrew Rawlins - awr-energenie@fermit.org.uk)

# Usage - 
#   Training   : energenie-perl.pl t   [socket-number-except-0]
#   Switch on  : energenie-perl.pl on  [socket-number] 
#   Switch off : energenie-perl.pl off [socket-number] 
#   Demo       : energenie-perl.pl 
#
# socket-number is 1-4, or 0 for all.

use strict;
use warnings;

my $i_have_a_rev2_pi = 0;
my $pin = $i_have_a_rev2_pi ? 27 : 21;

&do_setup;

if (defined @ARGV && @ARGV){
    &do_switch(
             $ARGV[1], 
             $ARGV[0] ne 'off' ? 1 : 0,
             $ARGV[0] eq 't' ? 1 : 0
         );
}
else {
    print "Demo mode\n";
    &do_switch(0, 1);
    sleep(2);
    &do_switch(0, 0);
}

exit 1;

sub do_switch() {
    my $socket = shift;
    my $state  = shift;
    my $train  = shift || 0;
    
    my $map = [ [ 0,1,1 ], [ 1,1,1 ], [ 1,1,0 ], [ 1,0,1 ], [ 1,1,0 ] ];
    
    print "Setting socket " . $socket . " " . ($state ? 'on' : 'off') . "\n" unless $train;
    print "Training socket " . $socket . " for 10 seconds\n" if $train;
    
    &do_gpio(25,0);
        
    &do_gpio($pin,$state);
    &do_gpio(23,$map->[$socket]->[0]);
    &do_gpio(22,$map->[$socket]->[1]);
    &do_gpio(17,$map->[$socket]->[2]);

    # Let the encoder settle - seems to need longer in perl
    # than python.  1 Second does it.
    sleep(1);

    # Enable the modulator
    &do_gpio(25,1);
    # Keep enabled for a period
    sleep($train ? 10 : 1);
    # Disable the modulator
    &do_gpio(25,0);
}

sub do_setup() {
    &do_export([$pin,23,22,17,24,25]);
    &do_gpio(24,0);
}

# Some libraries exist to do the following, this seems to work and allows this to be
# stand alone ...

sub do_export() {
    my $args = shift;
    foreach my $gpio (@{$args}){

        open(my $gpio_ctl, '>', '/sys/class/gpio/export');
        print $gpio_ctl $gpio . "\n";
        close $gpio_ctl;

        open(my $gpio_dir, '>', '/sys/class/gpio/gpio' . $gpio . '/direction') or die "Could not open GPIO $!";
        print $gpio_dir "out\n";
        close $gpio_dir;
    }
}

sub do_gpio() {

    my $gpio = $_[0];
    my $action = $_[1];

    open(my $gpio_val, '>', '/sys/class/gpio/gpio' . $gpio . '/value') or die "Could not open GPIO $!";
    print $gpio_val $action . "\n";
    close $gpio_val

}

