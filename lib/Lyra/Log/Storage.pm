package Lyra::Log::Storage;
use Moose;
use namespace::autoclean;

sub store { die "store() is not implemented in $_[0]" }

__PACKAGE__->meta->make_immutable();

1;