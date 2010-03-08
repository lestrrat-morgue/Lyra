package Lyra;
use strict;
our $VERSION = '0.00001';

__END__

=head1 NAME

Lyra - XXX

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