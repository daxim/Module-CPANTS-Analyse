use strict;
use warnings;
use Test::More tests => 2;

use Module::CPANTS::Analyse;
use File::Spec::Functions;
use Test::Deep;
my $a=Module::CPANTS::Analyse->new({
    dist=>'t/eg/Acme-DonMartinOther-0.06.tar.gz',
    _dont_cleanup=>$ENV{DONT_CLEANUP},
});

my $rv=$a->unpack;
is($rv,undef,'unpack ok');

$a->analyse;
$a->calc_kwalitee;

my $kw=$a->d->{kwalitee};
my $expected = {
           'has_buildtool' => 1,
           'has_readme' => 1,
           'manifest_matches_dist' => 1,
           'metayml_declares_perl_version' => 0,
           'metayml_is_parsable' => 1,
           'proper_libs' => 1,
           'has_changelog' => 1,
           'use_strict' => 1,
           'kwalitee' => 27,
           'no_stdin_for_prompting' => 1,
           'has_tests' => 1,
           'has_manifest' => 1,
           'no_symlinks' => 1,
           'buildtool_not_executable' => 1,
           'metayml_has_license' => 0,
           'no_generated_files' => 0,
           'has_meta_yml' => 1,
           'metayml_conforms_spec_current' => 0,
           'use_warnings' => 0,
           'no_large_files' => 1,
           'has_tests_in_t_dir' => 1,
           'metayml_conforms_to_known_spec' => 0,
           'has_separate_license_file' => 0,
           'has_license_in_source_file' => 0,
           'metayml_has_provides'=>0,
         };

$expected->{kwalitee} = ignore;
cmp_deeply($kw, superhashof($expected), 'kwalitee fits');

#use Data::Dumper;
#diag(Dumper $kw);
#diag(Dumper $a->d);

