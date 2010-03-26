package Lyra::Trait::WithMongoDB;
use Moose::Role;
use AnyEvent::MongoDB;
use namespace::autoclean;

has db => (
    is => 'ro',
    isa => 'AnyEvent::MongoDB',
    required => 1,
);

has _collections => (
    is => 'ro',
    isa => 'HashRef',
    default => sub { +{} },
    init_arg => undef
);

sub get_collection {
    my ($self, $name) = @_;

    my $h = $self->_collections;
    my $collection = $h->{$name};
    if (! $collection) {
        $collection = $h->{ $name } = $self->db->get_collection($name);
    }
    return $collection;
}

sub query_collection {
    my ($self, $collection, $query, $cv) = @_;

    $self->db->query('lyra', $collection, $query, sub {
        $cv->send(@{$_[1]});
    });
}

1;

