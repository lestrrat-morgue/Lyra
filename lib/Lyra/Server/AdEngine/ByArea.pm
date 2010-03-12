package Lyra::Server::AdEngine::ByArea;
use Math::Round;
use Math::Trig;
use Moose;
use namespace::autoclean;

with qw(Lyra::Trait::AsyncPsgiApp Lyra::Trait::WithMemcached Lyra::Trait::WithDBI);
# 1. 緯度経度から範囲をきめて矩形を作成(2点の緯度経度を作成）
# 2. DBに登録してあるカラム（RTree-Index）に作成した条件（矩形）でSELECT
# 3. SELECTした結果をXMLなりJSで返す

has lat_query_key => (
    is => 'ro',
    isa => 'Str',
    default => 'lat',
);

has lng_query_key => (
    is => 'ro',
    isa => 'Str',
    default => 'lng',
);

has range => => (
    is => 'ro',
    isa => 'Int',
    default => 2000, # 2km
);

sub process {
    my ($self, $start_response, $env) = @_;

    my %query = URI->new('http://dummy/?' . ($env->{QUERY_STRING} || ''))->query_form;
    my $lat   = $query{ $self->lat_query_key }; 
    my $lng   = $query{ $self->lng_query_key };
    my $range = $self->_calc_range($lat, $lng, $self->range);

    $self->dbh->exec(
        qq{SELECT id,title,content WHERE lyra_ads_by_area status = 1 AND
            MBRContains(GeomFromText('LineString(? ?,? ?'),location)},
        ( @{$range->{end}}, @{$range->{start}} ),
        sub {
            # ここで処理
 
            # ログ取りのためのディスパッチ
        }
    );
}

sub _calc_range {
    my ($self, $lat, $lng, $range) = @_;

    my @lat = split '\.', $lat;
    my %distance = (
        lat => sprintf('%.1f', 40054782 / (360*60*60)),
        lng => sprintf('%.1f', 6378150 * 
            cos($lat[0]/180*pi) * 2 * pi / (360*60*60)),
    ); 

    my %range;
    for my $key qw(lat lng) {
        $range{$key} = 
            sprintf('%.9f', (1/3600) * ($range/$distance{$key}));
    } 

    return +{
        start => [
            $lng - $range{lng},
            $lat - $range{lat},
        ],
        end   => [
            $lng + $range{lng},
            $lat + $range{lat},
        ],
    };
}

sub _convert_to_msec {
    my ($self, $coordinate) = @_;
    my @coordinate = split '\.', $coordinate;
    $coordinate[1] *= 10 if length($coordinate[1]) == 5;
    return int($coordinate[0] * 3600000 + $coordinate[1] * 3.6);
}

sub _convert_to_degree {
    my ($self, $coordinate) = @_;
    my $degree = $coordinate / 3600000;
    return nearest(0.000001, $degree);
}

__PACKAGE__->meta->make_immutable();

1;
