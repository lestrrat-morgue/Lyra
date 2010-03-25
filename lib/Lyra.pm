package Lyra;
use strict;
use Lyra::Extlib;
use XSLoader;
BEGIN
{
    our $VERSION = '0.00001';
    XSLoader::load __PACKAGE__, $VERSION;
}

sub _NOOP {}

1;

__END__

=head1 NAME

Lyra - High Performance Web Advertisement Publishing Framework

=head1 SETUP

=head2 INSTALL BUILD PREREQUISITES

=over 4

=item Module::Install

=item Module::Install::Bundle::LocalLib (0.00006)

=back

=head2 CREATE EXTLIB

    perl Makefile.PL
    make bundle_local_lib

=head2 CREATE DATABASE

    ./bin/lyra_deploydb --dsn=... --username=.... --password=...

=head2 RUN!

    ./bin/lyra_clickd --dsn=dbi:mysql:....

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

=head1 TODO

Look into MongoDB or CouchDB as the default backend

=head1 COPYRIGHT

Copyright (c) Daisuke Maki 2010
Copyright (c) Kazuhiro Nishikawa 2010

=head1 LICENSE

This program is free software; you can redistribut it and/or modify it
under Artistic License 2.0

http://www.perlfoundation.org/artistic_license_2_0

=cut