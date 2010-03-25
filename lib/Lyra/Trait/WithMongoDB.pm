package Lyra::Trait::WithMongoDB;
use Moose::Role;
use Coro;
use Coro::AnyEvent;
use MongoDB;
use namespace::autoclean;

has db => (
    is => 'ro',
    isa => 'MongoDB::Database',
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
    async_pool {
        my $cursor = $_[1]->query( $_[2] );
        $_[0]->send( $cursor->all );
    } $cv, $self->get_collection($collection), $query;
}

1;

