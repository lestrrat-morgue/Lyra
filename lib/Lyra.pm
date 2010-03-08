package Lyra;
use strict;
our $VERSION = '0.00001';

__END__

=head1 NAME

Lyra - XXX

=head1 SETUP

=head2 INSTALL BUILD PREREQUISITES

=over 4

=item Module::Install

=item Module::Install::Bundle::LocalLib (0.00006)

=back

=head2 CREATE EXTLIB

    perl Makefile.PL
    make bundle_local_lib

=head2 RUN!

    ./bin/lyra_clickd --dbh_dsn=dbi:mysql:....

=head1 lyra_clickd

Records a click.

=head2 ARCHITECTURE

    ---------------     ---------
    | lyra_clickd |---> | Ad DB |
    ---------------     ---------
              | |       ---------------------------
              | ------> | Ad Cache (Common Cache) |
              |         ---------------------------
              |         -------------------------
              --------> | Click log (file? DB?) |
                        -------------------------

=cut