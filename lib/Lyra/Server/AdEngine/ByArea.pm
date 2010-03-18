package Lyra::Server::AdEngine::ByArea;
use AnyEvent;
use Lyra;
use URI;
use Math::Trig;
use Moose;
use Moose::Util::TypeConstraints;
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

class_type 'URI';
coerce 'URI'
    => from 'Str'
    => via { URI->new($_) }
;
has click_uri => (
    is => 'ro',
    isa => 'URI',
    required => 1,
    coerce => 1,
);

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

has template => (
    is => 'ro',
    isa => 'Text::MicroTemplate::File',
    lazy_build => 1,
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

sub _build_template {
    my $self = shift;
    return Text::MicroTemplate::File->new(
        include_path => [$self->templates_dir],
        use_cache    => 1,
    );
}

sub process {
    my ($self, $start_response, $env) = @_;

    if ($env->{REQUEST_METHOD} ne 'GET') {
        respond_cb( $start_response, 400 );
        return;
    }

    # This is the CV that gets called at the end
    my $cv = AE::cv {
        my ($ads) = $_[0]->recv;

        my $output = $self->template->render_file(
            $self->template_file, 
            $self->click_uri,
            @$ads
        );
        respond_cb($start_response,
            200,
            [ 'Content-Type' => 'text/javascript; charset=UTF-8' ],
            $output,
        );

            my $store = $self->impression_log_storage;
            foreach my $ad (@$ads) {
                $store->store( 
                    join("\t", @$ad) . "\n"
                );
            }
    };

    my %query = URI->new('http://dummy/?' . ($env->{QUERY_STRING} || ''))->query_form;
    my $lat   = $query{ $self->lat_query_key }; 
    my $lng   = $query{ $self->lng_query_key };

    if (! defined $lat || ! defined $lng ) {
        respond_cb( $start_response, 400 );
        return;
    }

    my @range = Lyra::Util::calc_range( $lat, $lng, $self->range );

    $self->execsql(
        q{SELECT id,title,content,uuid() FROM lyra_ads_by_area WHERE status = 1 
            AND MBRContains(GeomFromText(?),location)},
        sprintf( 'LineString(%f %f,%f %f)', @range ),
        sub { 
            if (!$_[1]) {
                warn "Database error: $@";
                return;
            }

            $cv->send( $_[1] );
        }
    );
}

__PACKAGE__->meta->make_immutable();

1;
