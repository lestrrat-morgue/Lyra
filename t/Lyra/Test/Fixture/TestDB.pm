package t::Lyra::Test::Fixture::TestDB;
use Moose;
use namespace::autoclean;

has adserver_uri => (
    is => 'ro',
    isa => 'Str',
    default => 'http://127.0.0.1/'
);

sub deploy {
    my ($self, $mongodb) = @_;

    # XXX use some other method if you want to bulk insert 
    my $count = 1;
    my @ads = map {
        $_->{id} ||= sprintf('test_ads_by_area%03d', $count++);
        $_->{landing_uri} ||= "http://127.0.0.1/$_->{id}";
        $_->{status} = 1 unless exists $_->{status};
        $_;
    } (
        {
            title => 'オペラシティ',
            content => '最寄り駅は初台です',
            location => [ 139.685945, 35.683616 ],
        },
        {
            title => 'NTT東日本',
            content => '最寄り駅は初台です',
            location => [ 139.678481, 35.689265 ],
        },
        {
            title => '幡ヶ谷駅',
            content => '初台のとなりです',
            location => [ 139.674506, 35.678603 ],
        },
        {
            title => '明治大学',
            content => '最寄り駅は明大前です',
            location => [ 139.641874, 35.675566 ],
        },
        {
            title => '渋谷駅',
            content => '南口の使いにくさは異常です',
            location => [ 139.703946, 35.657775 ],
        },
        {
            title => '三軒茶屋駅',
            content => 'こちらのハナマサの魚は結構質がいいですね',
            location => [ 139.700174, 35.656826 ],
        },
    );

    my $collection = $mongodb
        ->get_database('lyra')
        ->get_collection('ads_byarea')
    ;

    $collection->remove();
    $collection->batch_insert( \@ads );
    $collection->ensure_index( { location => "2d" } );
}

__PACKAGE__->meta->make_immutable();

1;
