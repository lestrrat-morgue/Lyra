package t::Lyra::Test::Fixture::TestDB;
use Moose;
use namespace::autoclean;

has adserver_uri => (
    is => 'ro',
    isa => 'Str',
    default => 'http://127.0.0.1/'
);

sub deploy {
    my ($self, $schema) = @_;

    my $master_rs = $schema->resultset('AdsMaster');

    # XXX use some other method if you want to bulk insert 
    $master_rs->create(
        {
            id => 'test_ad001',
            landing_uri => $self->adserver_uri . 'test_ad001'
        }
    );
}

__PACKAGE__->meta->make_immutable();

1;