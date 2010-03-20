package Lyra::Worker::Renderer;
use Moose;
use Text::MicroTemplate::File;
use namespace::autoclean;

has template => (
    is => 'ro',
    isa => 'Text::MicroTemplate::File',
    lazy_build => 1,
);

has templates_dir => (
    is => 'ro',
    isa => 'Str',
    default => 'templates',
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
    my ($self, $data) = @_;

    my $output = $self->template->render_file(
        $self->template_file, 
        $data->{click_uri},
        @{$data->{ads}}
    );

    return [ 200, [ "Content-Type" => "text/plain" ], [ $output ] ];
}

__PACKAGE__->meta->make_immutable();