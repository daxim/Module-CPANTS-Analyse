use strict;
use warnings;
use Test::More;
use Test::NoWarnings;
use Test::Deep;

use Module::CPANTS::Analyse;
#use File::Spec::Functions;
use Data::Dumper    qw(Dumper);
$Data::Dumper::Sortkeys = 1;

my @tests = (
    {
        dist => 't/eg/Text-CSV_XS-0.40.tgz',
        kwalitee => {
           'has_buildtool' => 1,
           'has_readme' => 1,
           'manifest_matches_dist' => 1,
           'metayml_declares_perl_version' => 0,
           'metayml_is_parsable' => 1,
           'proper_libs' => 1,
           'has_changelog' => 1,
           'use_strict' => 1,
           'kwalitee' => 40,
           'no_stdin_for_prompting' => 1,
           'has_tests' => 1,
           'has_manifest' => 1,
           'no_symlinks' => 1,
           'buildtool_not_executable' => 1,
           'metayml_has_license' => 1,
           'no_generated_files' => 1,
           'has_meta_yml' => 1,
           'metayml_conforms_spec_current' => 1,
           'use_warnings' => 1,
           'no_large_files' => 1,
           'has_tests_in_t_dir' => 1,
           'metayml_conforms_to_known_spec' => 1,
           'has_separate_license_file' => 0,
           'has_license_in_source_file' => 1,
           'metayml_has_provides'=>0,
        },
        error => {},
    },
    {
        dist =>  't/eg/Pipe-0.03.tar.gz',
        kwalitee => {
           'has_buildtool' => 1,
           'has_readme' => 1,
           'manifest_matches_dist' => 0,
           'metayml_declares_perl_version' => 0,
           'metayml_is_parsable' => 0,
           'proper_libs' => 1,
           'has_changelog' => 1,
           'use_strict' => 1,
           'kwalitee' => 29,
           'no_stdin_for_prompting' => 1,
           'has_tests' => 1,
           'has_manifest' => 1,
           'no_symlinks' => 1,
           'buildtool_not_executable' => 1,
           'metayml_has_license' => 0,
           'no_generated_files' => 1,
           'has_meta_yml' => 0,
           'metayml_conforms_spec_current' => 0,
           'use_warnings' => 1,
           'no_large_files' => 1,
           'has_tests_in_t_dir' => 1,
           'metayml_conforms_to_known_spec' => 0,
           'has_separate_license_file' => 0,
           'has_license_in_source_file' => 1,
           'metayml_has_provides'=>0,
        },
        error => {
            'metayml_conforms_spec_current'  => ['1.4', sort
                'META.yml is missing/empty',
            ],
            'metayml_conforms_to_known_spec' => ['known', sort
                'META.yml is missing/empty',
            ],
            'manifest_matches_dist' => [
                                        'MANIFEST (27) does not match dist (26):',
                                        'Missing in MANIFEST: ',
                                        'Missing in Dist: META.yml'
                                      ],
        },
    },
    {
        dist => 't/eg/PPI-HTML-1.07.tar.gz',
        kwalitee => {
           'has_buildtool' => 1,
           'has_readme' => 1,
           'manifest_matches_dist' => 1,
           'metayml_declares_perl_version' => 1,
           'metayml_is_parsable' => 1,
           'proper_libs' => 1,
           'has_changelog' => 1,
           'use_strict' => 1,
           'kwalitee' => 37,
           'no_stdin_for_prompting' => 1,
           'has_tests' => 1,
           'has_manifest' => 1,
           'no_symlinks' => 1,
           'buildtool_not_executable' => 1,
           'metayml_has_license' => 1,
           'no_generated_files' => 1,
           'has_meta_yml' => 1,
           'metayml_conforms_spec_current' => 0,
           'use_warnings' => 0,
           'no_large_files' => 1,
           'has_tests_in_t_dir' => 1,
           'metayml_conforms_to_known_spec' => 1,
           'has_separate_license_file' => 1,
           'has_license_in_source_file' => 1,
           'metayml_has_provides'=>0,
         },
        error => {
           'metayml_conforms_spec_current' => [
                                                '1.4',
                                                sort
                                                'Missing mandatory field, \'url\' (meta-spec -> url) [Validation: 1.4]',
                                                'Missing mandatory field, \'version\' (meta-spec -> version) [Validation: 1.4]',
                                                'Expected a list structure (author) [Validation: 1.4]'
                                              ],
        },
    },
    {
        dist => 't/eg/App-Wack-0.05.tar.gz',
        kwalitee => {
           'has_buildtool' => 1,
           'has_readme' => 1,
           'manifest_matches_dist' => 1,
           'metayml_declares_perl_version' => 0,
           'metayml_is_parsable' => 1,
           'proper_libs' => 1,
           'has_changelog' => 1,
           'use_strict' => 1,
           'kwalitee' => 38,
           'no_stdin_for_prompting' => 1,
           'has_tests' => 1,
           'has_manifest' => 1,
           'no_symlinks' => 1,
           'buildtool_not_executable' => 1,
           'metayml_has_license' => 1,
           'no_generated_files' => 1,
           'has_meta_yml' => 1,
           'metayml_conforms_spec_current' => 1,
           'use_warnings' => 1,
           'no_large_files' => 1,
           'has_tests_in_t_dir' => 1,
           'metayml_conforms_to_known_spec' => 1,
           'has_separate_license_file' => 0,
           'has_license_in_source_file' => 1,
           'metayml_has_provides'=>1,
        },
        error => {
        },
    },
    {
        dist => 't/eg/Term-Title-0.03.tar.gz',
        kwalitee => {
           'has_buildtool' => 1,
           'has_separate_license_file' => 1,
           'has_readme' => 1,
           'manifest_matches_dist' => 1,
           'metayml_declares_perl_version' => 1,
           'metayml_is_parsable' => 1,
           'proper_libs' => 1,
           'has_changelog' => 1,
           'use_strict' => 1,
           'kwalitee' => 40,
           'no_stdin_for_prompting' => 1,
           'has_license_in_source_file' => 1,
           'has_tests' => 1,
           'has_manifest' => 1,
           'no_symlinks' => 1,
           'buildtool_not_executable' => 1,
           'metayml_has_license' => 1,
           'metayml_has_provides' => 1,
           'no_generated_files' => 1,
           'has_meta_yml' => 1,
           'metayml_conforms_spec_current' => 1,
           'use_warnings' => 1,
           'no_large_files' => 1,
           'has_tests_in_t_dir' => 1,
           'metayml_conforms_to_known_spec' => 1,
         },
        error => {
        },
    },
    {
        dist => 't/eg/Parse-Fedora-Packages-0.02.tar.gz',
        kwalitee => {
           'has_buildtool' => 1,
           'has_separate_license_file' => 0,
           'has_readme' => 1,
           'manifest_matches_dist' => 1,
           'metayml_declares_perl_version' => 0,
           'metayml_is_parsable' => 1,
           'proper_libs' => 1,
           'has_changelog' => 1,
           'use_strict' => 1,
           'kwalitee' => 38,
           'no_stdin_for_prompting' => 1,
           'has_license_in_source_file' => 1,
           'has_tests' => 1,
           'has_manifest' => 1,
           'no_symlinks' => 1,
           'buildtool_not_executable' => 1,
           'metayml_has_license' => 1,
           'metayml_has_provides' => 1,
           'no_generated_files' => 1,
           'has_meta_yml' => 1,
           'metayml_conforms_spec_current' => 1,
           'use_warnings' => 1,
           'no_large_files' => 1,
           'has_tests_in_t_dir' => 1,
           'metayml_conforms_to_known_spec' => 1,
         },
        error => {
        },
    },
    {
        dist => 't/eg/Capture-Tiny-0.05.tar.gz',
        kwalitee => {
           'has_buildtool' => 1,
           'has_separate_license_file' => 1,
           'has_readme' => 1,
           'manifest_matches_dist' => 1,
           'metayml_declares_perl_version' => 1,
           'metayml_is_parsable' => 1,
           'proper_libs' => 1,
           'has_changelog' => 1,
           'use_strict' => 1,
           'kwalitee' => 41,
           'no_stdin_for_prompting' => 1,
           'has_license_in_source_file' => 1,
           'has_tests' => 1,
           'has_manifest' => 1,
           'no_symlinks' => 1,
           'buildtool_not_executable' => 1,
           'metayml_has_license' => 1,
           'metayml_has_provides' => 1,
           'no_generated_files' => 1,
           'has_meta_yml' => 1,
           'metayml_conforms_spec_current' => 1,
           'use_warnings' => 1,
           'no_large_files' => 1,
           'has_tests_in_t_dir' => 1,
           'metayml_conforms_to_known_spec' => 1,
         },
        error => {
        },
    },
);

plan tests => 1 + 3 * @tests;

foreach my $t (@tests) {
    my $a=Module::CPANTS::Analyse->new({
        dist=> $t->{dist},
        _dont_cleanup=>$ENV{DONT_CLEANUP},
        #opts => { verbose=>1 },  # enable for debugging
        });

    my $rv=$a->unpack;
    is($rv,undef,'unpack ok');

    $a->analyse;
    $a->calc_kwalitee;

    my $d=$a->d;
    my $kw=$a->d->{kwalitee};
    $t->{kwalitee}{kwalitee} = ignore; # another Test::Deep import
    cmp_deeply($kw, superhashof($t->{kwalitee}), "kwalitee of $t->{dist}")
        or diag(Dumper $kw);
    cmp_deeply($d->{error}, superhashof($t->{error}), "error of $t->{dist}")
        or diag(Dumper $d->{error});
    #diag(Dumper $d);
}

