use utf8;
use strict;
use Module::Build;

my $build = Module::Build->new(
    dist_author => 'Lars Dɪᴇᴄᴋᴏᴡ <daxim@cpan.org>',
    module_name => 'Module::CPANTS::Analyse',
    license     => 'perl',
    requires    => {
        'Class::Accessor'           => '0.19',
        'Archive::Any'              => '0.06',
        'Archive::Tar'              => '1.48', #depends on IO::Compress without memory leak
        'CPAN::DistnameInfo'        => '0.06',
        'Pod::Simple::Checker'      => '2.02',
        'YAML::Any'                 => 0,
        'Module::ExtractUse'        => '0.18',
        'Module::Pluggable'         => '2.96',
        'IO::Capture'               => '0.05',
        'Array::Diff'               => '0.04',
        'version'                   => '0.73',
        'List::MoreUtils'           => '0',
        'File::Find::Rule'          => '0',
        'Readonly'                  => '0',
        'Software::License'         => '0.003',
        'File::Slurp'               => '0',
        'Text::CSV_XS'              => '0.45',
        'LWP::Simple'               => 0,
        'perl'                      => 5.006,
        'Test::CPAN::Meta::YAML::Version' => '0',
        'ExtUtils::Manifest'        => 0,
        'Set::Scalar'               => 0,
        'File::chdir'               => 0,
        'Module::Signature'         => 0,
    },
    build_requires => {
        'Test::More'                => '0',
        'Test::Deep'                => '0',
        'Test::Warn'                => '0.11', #less problems with new Sub::Uplevel
        'Test::NoWarnings'          => '0',
        'Cwd'                       => '0',
    },
    configure_requires => {
        'Module::Build'             => '0.4',
    },
    meta_merge => {
        resources => {
            homepage => 'http://cpants.perl.org',
            repository => 'https://github.com/daxim/Module-CPANTS-Analyse',
            bugtracker => 'https://rt.cpan.org/Dist/Display.html?Name=Module-CPANTS-Analyse',
            },
        keywords => [
            'CPANTS','kwalitee',
        ],
    },
    script_files=>[qw(bin/cpants_lint.pl)],
    create_makefile_pl=>'traditional',
);


$build->add_to_cleanup('Debian_CPANTS.txt');
$build->create_build_script;

