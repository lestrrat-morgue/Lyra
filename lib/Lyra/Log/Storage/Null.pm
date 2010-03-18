package Lyra::Log::Storage::Null;
use Moose;
use namespace::autoclean;

extends 'Lyra::Log::Storage';

sub store {}

__PACKAGE__->meta->make_immutable();

1;