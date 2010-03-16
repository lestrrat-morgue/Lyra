package Lyra::Log::Storage::File;
use Moose;
use AnyEvent;
use AnyEvent::AIO;
use IO::AIO;
use Fcntl;
use POSIX ();
use namespace::autoclean;

extends 'Lyra::Log::Storage';

has prefix => (
    is => 'ro',
    isa => 'Str',
    default => 'click',
);

has groups => (
    is => 'ro',
    isa => 'HashRef',
    default => sub { +{} }
);

sub _noop {};

# filename is <prefix>.<timestamp>.<pid>
# where timestamp is YYYYMMDDhhXX, and it's recycled every 15 minutes.
# so on a given hour, you get YYYYMMDDhh01, 02, 03, 04
sub store {
    my ($self, $args, $cb) = @_;

    my @localtime = localtime();
    my $filename = join('.', 
        $self->prefix,
        POSIX::strftime('%Y%m%d%H', @localtime) . (int($localtime[1] / 15) + 1),
        $$,
        'dat',
    );

    # このCB、本当はいらないんだけど、これがないとテストがうまく書けない・・・
    $cb ||= \&_noop;
    my $buffer = "DUMMY\n";
    my $length = length $buffer;

    aio_open $filename, O_WRONLY|O_CREAT|O_APPEND, 0644, sub {
        my $fh = shift or die "Failed to  open $filename for writing: $!";
        aio_write $fh, -1, $length, $buffer, 0, sub { $cb->($filename) };
    };
}

__PACKAGE__->meta->make_immutable();

1;