use strict;
use warnings;
use Test::More;

for my $seed ( qw( 0xd8792d91 0x5be01872 )){
    local $ENV{PERL_HASH_SEED} = $seed;
    my @libs; 
    for my $inc ( @INC ){
        push @libs, '-I' . $inc;
    }
    my $content = do {
        open my $fh, '-|', $^X, @libs, 't/11_hash_random.tscript' or die;
        local $/ = undef;
        <$fh>
    };
    is( $content, "4,0\n", "Slave forked script passed 4/4 checks with seed $seed" );
    
}
done_testing;
