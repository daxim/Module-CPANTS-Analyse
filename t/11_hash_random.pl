use strict;
use warnings;
use Data::Dump qw/dump/;

my $td = {
    dist  => 't/eg/PPI-HTML-1.07.tar.gz',
    error => {
        'metayml_conforms_spec_current' => [
            '1.4',
            sort
            'Missing mandatory field, \'url\' (meta-spec -> url) [Validation: 1.4]',
            'Missing mandatory field, \'version\' (meta-spec -> version) [Validation: 1.4]',
            'Expected a list structure (author) [Validation: 1.4]'
        ],
    },
};
require Module::CPANTS::Analyse;
my $a = Module::CPANTS::Analyse->new({
    dist          => $td->{dist},
    _dont_cleanup => $ENV{DONT_CLEANUP},
});
my $rv = $a->unpack;

$a->analyse;
$a->calc_kwalitee;

my $d     = $a->d;
my $kw    = $a->d->{kwalitee};
my $left  = $d->{error}->{metayml_conforms_spec_current};
my $right = $td->{error}->{metayml_conforms_spec_current};

my ($pass, $fail) = (0, 0);

for my $i (0 .. $#{$left}) {
    if ($left->[$i] ne $right->[$i]) {
        $fail++;
    } else {
        $pass++;
    }
}
print "$pass,$fail\n";
