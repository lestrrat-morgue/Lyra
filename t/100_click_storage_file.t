use strict;
use Test::More;
use AnyEvent;

use_ok "Lyra::Server::Click::Storage::File";

my $store = Lyra::Server::Click::Storage::File->new(
    prefix => __FILE__,
);

# XXX - これだけじゃテストになってません！

my $cv = AE::cv;
foreach my $i (1..100) {
    warn "starting $i";
    $cv->begin();
    $store->store(undef, sub { warn "callback"; $cv->end });
}

$cv->recv;

done_testing();