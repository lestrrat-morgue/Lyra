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
    my $count = 1;
    my @ads = map {
        $_->{id} ||= sprintf('test_ads_by_area%03d', $count++);
        $_->{landing_uri} ||= "http://127.0.0.1/$_->{id}";
        $_;
    } (
        {
            title => 'オペラシティ',
            content => '最寄り駅は初台です',
            status => 1,
            location => \q|GeomFromText('POINT(139.685945 35.683616)')|,
        },
        {
            title => 'NTT東日本',
            content => '最寄り駅は初台です',
            status  => 1,
            location => \q|GeomFromText('POINT(139.678481 35.689265)')|,
        },
        {
            title => '幡ヶ谷駅',
            content => '初台のとなりです',
            status => 1,
            location => \q|GeomFromText('POINT(139.674506 35.678603)')|,
        },
        {
            title => '明治大学',
            content => '最寄り駅は明大前です',
            status => 1,
            location => \q|GeomFromText('POINT(139.641874 35.675566)')|,
        }
    );

    foreach my $ad (@ads) {
        $master_rs->create( $ad );
    }
}

__PACKAGE__->meta->make_immutable();

1;
