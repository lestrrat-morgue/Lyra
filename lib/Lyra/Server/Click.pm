package Lyra::Server::Click;
use Any::Moose;
use URI;
use AnyEvent;
use namespace::autoclean;

with qw(Lyra::Trait::WithMemcached Lyra::Trait::WithDBI Lyra::Trait::AsyncPsgiApp);

has ad_id_query_key => (
    is => 'ro',
    isa => 'Str',
    default => 'ad',
);

sub process {
    my ($self, $start_response, $env) = @_;

    # This is the CV that gets called at the end
    my %log_info = (
        remote_addr => $env->{REMOTE_ADDR},
        query       => $env->{QUERY_STRING},
    );

    my $cv = AE::cv {
        my ($status, $header, $content) = $_[0]->recv;
        _respond_cb($start_response, $status, $header, $content);
        if ($status eq 302) { # which is success for us
            $self->log_click( \%log_info );
        }
        undef %log_info;
        undef $status;
        undef $header;
        undef $content;
    };


    # check for some conditions
    my ($status, @headers, $content);
    if (! $env->{'psgi.streaming'}) {
        $cv->send( 400 );
        return;
    }

    if ($env->{REQUEST_METHOD} ne 'GET') {
        $cv->send( 400 );
        return;
    }

    # if we got here, then we're just going to redirect to the
    # landing page. 
    my $query = URI->new('http://dummy/?' . ($ENV{QUERY_STRING} || ''))->query_form;
    my $ad_id = $query->{ $self->ad_id_query_key };

    $self->load_ad( $ad_id, $cv );
}

sub _respond_cb {
    my ($start_response, $status, $headers, $content) = @_;
    # immediately return and close connection.
    my $writer = $start_response->( [ $status, $headers ] );
    $writer->writer($content) if $content;
    $writer->close;
}

sub _load_ad_from_memd_cb {
    my ($self, $final_cv, $ad_id, $ad) = @_;

    if ($ad) {
        $final_cv->send( 302, [ Location => $ad->landing_uri ] );
    } else {
        $self->load_ad_from_db( $final_cv, $ad_id );
    }
}

sub _load_ad_from_db_cb {
    my ($self, $final_cv, $ad_id, $rows) = @_;
    if (! defined $rows) {
        confess "PANIC: loading from DB returned undef";
    }

    if (@$rows > 0) {
        # We don't do the caching. let some other guy take care of it
        $final_cv->send( 302, [ Location => $rows->[0]->[0] ] );
    } else {
        $final_cv->send( 404 );
    }
}

# Ad retrieval. Try memcached, if you failed, load from DB
*load_ad = \&load_ad_from_memd;

sub load_ad_from_memd {
    my ($self, $ad_id, $final_cv) = @_;
    $self->cache->get( $ad_id, sub { _load_ad_from_memd_cb( $self, $final_cv, $ad_id, @_ ) } );
}

sub load_ad_from_db {
    my ($self, $final_cv, $ad_id) = @_;

    $self->dbh->exec(
        "SELECT landing_uri FROM table WHERE id = ?",
        $ad_id,
        sub { _load_ad_from_db_cb( $self, $final_cv, $ad_id, $_[1] ) }
    );
}

1;