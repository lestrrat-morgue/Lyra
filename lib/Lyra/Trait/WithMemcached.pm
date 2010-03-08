package Lyra::Trait::WithMemcached;
use Moose::Role;
use Cache::Memcached::AnyEvent;
use namespace::autoclean;

has cache => (
    is => 'ro',
    isa => 'Cache::Memcached::AnyEvent',
    lazy_build => 1,
);

has cache_servers => (
    is => 'ro',
    isa => 'ArrayRef',
    default => sub { [ '127.0.0.1:11211' ] },
);

has cache_compress_threshold => (
    is => 'ro',
    isa => 'Int',
    default => 10_000
);

has cache_namespace => (
    is => 'ro',
    isa => 'Str',
    default => 'clicking.clicks.'
);

sub _build_cache {
    my $self = shift;
    return Cache::Memcached::AnyEvent->new(
        servers => $self->cache_servers,
        compress_threshold => $self->cache_compress_threshold,
        namespace => $self->cache_namespace,
    );
}

1;
