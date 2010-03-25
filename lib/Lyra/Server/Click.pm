package Lyra::Server::Click;
use Moose;
use AnyEvent;
use Lyra::Extlib;
use URI;
use namespace::autoclean;

with qw(
    Lyra::Trait::AsyncPsgiApp
    Lyra::Trait::WithMongoDB
);

has ad_id_query_key => (
    is => 'ro',
    isa => 'Str',
    default => 'ad',
);

has log_storage => (
    is => 'ro',
    handles => {
        log_click => 'store',
    },
);

sub process {
    my ($self, $start_response, $env) = @_;

    # Stuff that gets logged at the end goes here
    my %log_info = (
        remote_addr => $env->{REMOTE_ADDR},
        query       => $env->{QUERY_STRING},
    );

    # This is the CV that gets called at the end
    my $cv = AE::cv {
        my ($status, $header, $content) = $_[0]->recv;
        respond_cb($start_response, $status, $header, $content);
        if ($status eq 302) { # which is success for us
#            $self->log_click( \%log_info );
        }
        undef %log_info;
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

    # if we got here, then we're just going to redirect to the
    # landing page. 
    my %query = URI->new('http://dummy/?' . ($env->{QUERY_STRING} || ''))->query_form;

    my $ad_id = $query{ $self->ad_id_query_key };

    $self->load_ad( $cv, $ad_id );
}

sub load_ad {
    my ($self, $final_cv, $ad_id) = @_;

    my $cv = AE::cv {
        if (my ($ad) = $_[0]->recv) {
            $final_cv->send( 302, [ Location => $ad->{landing_uri} ] );
        } else {
            $final_cv->send( 404 );
        }
    };

    $self->query_collection( 'ads_byarea', { id => $ad_id }, $cv );
}

1;
