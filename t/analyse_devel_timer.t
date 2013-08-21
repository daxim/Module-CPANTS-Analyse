use strict;
use warnings;
use Test::More tests => 13;

use Module::CPANTS::Analyse;
use File::Spec::Functions;
my $a=Module::CPANTS::Analyse->new({
    dist=>'t/eg/Devel-Timer-0.02.tar.gz',
    _dont_cleanup=>$ENV{DONT_CLEANUP},
});

my $rv=$a->unpack;
is($rv,undef,'unpack ok');

$a->analyse;

my $d=$a->d;

is($d->{files},12,'files');
is($d->{size_packed},10646,'size_packed');
is(ref($d->{modules}),'ARRAY','modules is ARRAY');
my $modcount=grep {$_->{module} eq 'Devel::Timer'} @{$d->{modules}};
is($modcount,1,'module');
is(ref($d->{prereq}),'ARRAY','prereq is ARRAY');
is(ref($d->{uses}),'HASH','uses is HASH');
is($d->{uses}{'Test::More'}{in_tests},3,'uses');
ok($d->{file_meta_yml},'has_yaml');
ok($d->{metayml_is_parsable},'metayml_is_parsable');
ok(!$d->{metayml_parse_error},'metayml_parse_error was not set');
ok(!$d->{license},'no license');
ok(!$d->{needs_compiler}, 'does not need compiler');

#use Data::Dumper;
#diag(Dumper $d);

