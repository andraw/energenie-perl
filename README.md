# energenie-perl
Control an Energenie Pi-mote control board from within Perl.

## Usage

Usage should be self explanatory. Ensure you call do_setup at the start of your script and ensure all of the sub-routines from the example are in your code. It is then a matter of calling do_switch with two parameters, first the socket number you wish to use (0 for all) and then either ON or OFF depending on what action you wish the socket to perform.

## Version History
1.0 - Initial Release (Andrew Rawlins - awr-energenie@fermit.org.uk)
1.1 - Add training options, Code tidying, Support for rev 1 Pi (Ian Cook - ian@elder-studios.co.uk)

## Requirements
None, other than make sure the sockets are working with the remote control beforehand. The code will need to be run as root or set-uid.

