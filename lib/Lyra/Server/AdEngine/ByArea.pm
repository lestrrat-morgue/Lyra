package Lyra::Server::AdEngine::ByArea;
use AnyEvent;
use Lyra::Extlib;
use URI;
use Math::Trig;
use Moose;
use Text::MicroTemplate::File;
use namespace::autoclean;

extends 'Lyra::Server::AdEngine';
with qw(
    Lyra::Trait::AsyncPsgiApp
    Lyra::Trait::WithMemcached
    Lyra::Trait::WithDBI
);

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

has templates_dir => (
    is => 'ro',
    isa => 'Str',
);

has template_file => (
    is => 'rw',
    isa => 'Str',
    default => 'default.js',
);

sub process {
    my ($self, $start_response, $env) = @_;

    # This is the CV that gets called at the end
    my $cv = AE::cv {
        my ($status, $header, $content) = $_[0]->recv;
        respond_cb($start_response, $status, $header, $content);
        #if ($status eq 302) { # which is success for us
        #    $self->log_click( \%log_info );
        #}
        #undef %log_info;
        undef $status;
        undef $header;
        undef $content;
    };

    # check for some conditions
    my ($status, @headers, $content);

    if ($env->{REQUEST_METHOD} ne 'GET') {
        $cv->send( 400 );
        return;
    }

    my %query = URI->new('http://dummy/?' . ($env->{QUERY_STRING} || ''))->query_form;
    my $lat   = $query{ $self->lat_query_key }; 
    my $lng   = $query{ $self->lng_query_key };

    if (! defined $lat || ! defined $lng ) {
        $cv->send( 400 );
        return;
    }

    my @range = _calc_range($self, $lat, $lng, $self->range);

    $self->load_ad( $cv, \@range );
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

    return (
        $lng - $range{lng},
        $lat - $range{lat},
        $lng + $range{lng},
        $lat + $range{lat},
    );
}

our $TEMPLATE;
sub _rendar_ads {
    my( $self, $ads) = @_;

    $ads = [] unless defined $ads;

    $TEMPLATE ||= Text::MicroTemplate::File->new(
        include_path => [$self->templates_dir],
        use_cache    => 1,
    );
   
    return $TEMPLATE->render_file($self->template_file, @$ads);
}

sub _load_ad_from_db_cb {
    my ($self, $final_cv, $rows) = @_;

    if (! defined $rows) {
        confess "PANIC: loading from DB returned undef";
    }

    if (@$rows > 0) {
        $final_cv->send( 200, ['content-type' => 'text/plain'], 'dummy' );
    } else {
        $final_cv->send( 200, ['content-type' => 'text/plain'], 'empty' );
    }
}

*load_ad = \&load_ad_from_db;

sub load_ad_from_db {
    my ($self, $final_cv, $range) = @_;

    # XXX Should we just retrieve id, so that we can use a cached response?
    # what's the cache-hit ratio here? If most ads only appear once per
    # cycle, then caching doesn't mean anything, so leave it as is
    $self->execsql(
        q{SELECT id,title,content FROM lyra_ads_by_area WHERE status = 1 
            AND MBRContains(GeomFromText(LineString(? ?,? ?)),location)},
        @$range,
        sub { 
            if (!$_[1]) {
                warn "Database error: $@";
                return;
            }
            $self->_load_ad_from_db_cb( $final_cv, $_[1] )
        }
    );
}

__PACKAGE__->meta->make_immutable();

1;
