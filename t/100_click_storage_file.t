use strict;
use Test::More;
use AnyEvent;

use_ok "Lyra::Log::Storage::File";

my $store = Lyra::Log::Storage::File->new(
    prefix => __FILE__,
);

# XXX - これだけじゃテストになってません！

my $filename;
my $cv = AE::cv { unlink $filename };
foreach my $i (1..100) {
    $cv->begin();
    $store->store(undef, sub {
        $filename ||= shift;
        $cv->end;
    });
}

$cv->recv;

done_testing();