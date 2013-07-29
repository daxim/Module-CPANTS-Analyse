use strict;
use warnings;
use Test::More;

for my $seed (qw(0xd8792d91 0x5be01872)) {
    local $ENV{PERL_HASH_SEED} = $seed;
    my @libs;
    for my $inc (@INC) {
        push @libs, '-I' . $inc;
    }
    my $cmd = join(' ', $^X, @libs, 't/11_hash_random.pl');
    my $content = qx/$cmd/;
    is($content, "4,0\n", "Slave forked script passed 3/3 checks with seed $seed");
}
done_testing;
