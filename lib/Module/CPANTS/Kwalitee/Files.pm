package Module::CPANTS::Kwalitee::Files;
use warnings;
use strict;
use File::Find::Rule::VCS;
use File::Spec::Functions qw(catdir catfile abs2rel splitdir);
use File::stat;
use File::Basename;
use Data::Dumper;

our $VERSION = '0.90_01';

sub order { 15 }

##################################################################
# Analyse
##################################################################

my $large_file = 200_000;

sub analyse {
    my $class=shift;
    my $me=shift;
    my $distdir=$me->distdir;

    my $file_find_rule = File::Find::Rule::VCS->file()->relative();
    my $dir_find_rule = File::Find::Rule::VCS->directory()->relative();
    if ($me->d->{is_local_distribution}) {
        $file_find_rule->ignore_vcs();
        $dir_find_rule->ignore_vcs();
    }

    my @files = $file_find_rule->in($distdir);
    my @dirs  = $dir_find_rule->in($distdir);
    #my $unixy=join('/',splitdir($File::Find::name));

    # Respect no_index if possible
    my $no_index_re = $class->_make_no_index_regex($me);

    my $size = 0;
    my %files;
    foreach my $name (@files) {
        my $path = catfile($distdir, $name);
        $files{$name}{size} += -s $path || 0;
        $size += $files{$name}{size};
    }

    #die Dumper \%files;
    $me->d->{size_unpacked}=$size;

    # find symlinks
    my @symlinks;
    foreach my $f (@dirs, @files) {
        my $p = catfile($distdir,$f);
        if (-l $p) {
            push(@symlinks,$f);
        }
    }

    # above checks should be done even with files to be ignored
    if ($no_index_re) {
        my %ignored_files;
        for my $name (@files) {
            (my $name_to_test = $name) =~ s|\\|/|g;
            $name_to_test =~ s|/$||;
            if ($name_to_test =~ qr/$no_index_re/) {
                $ignored_files{$name} = 1;
                next;
            }
        }
        @files = grep { !$ignored_files{$_} } @files;
        $me->d->{ignored_files_array} = [sort keys %ignored_files];
    }

    # store stuff
    $me->d->{files}=scalar @files;
    $me->d->{files_array}=\@files;
    $me->d->{files_hash}=\%files;
    $me->d->{dirs}=scalar @dirs;
    $me->d->{dirs_array}=\@dirs;
    $me->d->{symlinks}=scalar @symlinks;
    $me->d->{symlinks_list}=join(';',@symlinks);

    # find special files
    my %reqfiles;
    my @special_files=(qw(Makefile.PL Build.PL META.yml META.json MYMETA.yml MYMETA.json dist.ini cpanfile SIGNATURE MANIFEST test.pl LICENSE LICENCE));
    map_filenames($me, \@special_files, \@files);

    # find more complex files
    my %regexs=(
        file_changelog=>qr{^chang|history}i,
        file_readme=>qr{^readme(?:\.(?:txt|md))?}i,
    );
    while (my ($name,$regex)=each %regexs) {
        $me->d->{$name}=join(',',grep {$_=~/$regex/} @files);
    }
    
    # find special dirs
    my @special_dirs=(qw(lib t xt));
    foreach my $dir (@special_dirs){
        my $db_dir="dir_".$dir;
        $me->d->{$db_dir}=((grep {$_ eq "$dir"} @dirs)?1:0);
    }
    
    # get mtime
    my $mtime=0;
    foreach (@files) {
        next if /\//;
        my $to_stat=catfile($distdir,$_);
        next unless -e $to_stat; # TODO hmm, warum ist das kein File?
        my $stat=stat($to_stat);
        $files{$_}{mtime} = my $thismtime=$stat->mtime;
        $mtime=$thismtime if $mtime<$thismtime;
    }
    $me->d->{newest_file_epoch}=$mtime;
    # $me->d->{released}=scalar localtime($mtime);

    # check STDIN in Makefile.PL and Build.PL 
    # objective: convince people to use prompt();
    # http://www.perlfoundation.org/perl5/index.cgi?cpan_packaging
    {
        foreach my $file ('Makefile.PL', 'Build.PL') {
            (my $handle = $file) =~ s/\./_/;
            $handle = "stdin_in_" . lc $handle;
            my $path = catfile($me->distdir,$file);
            next if not -e $path;
            if (open my $fh, '<', $path) {
                if (grep {/<STDIN>/} <$fh>) {
                    $me->d->{$handle} = 1;
                }
            }
        } 
    } 
    return;
}

sub map_filenames {
    my ($me, $special_files, $files) = @_;
    my %ret;
    foreach my $file (@$special_files){
        (my $db_file=$file)=~s/\./_/g;
        $db_file="file_".lc($db_file);
        $me->d->{$db_file}=((grep {$_ eq "$file"} @$files)?1:0);
        $ret{$db_file}=$file;
    }
    return %ret;
}

sub _make_no_index_regex {
    my ($class, $me) = @_;

    my $meta = $me->d->{meta_yml};
    return unless $meta && ref $meta eq ref {};

    my $no_index = $meta->{no_index} || $meta->{private};
    return unless $no_index && ref $no_index eq ref {};

    my %map = (
        file => '\z',
        directory => '/',
    );
    my @ignore;
    for my $type (qw/file directory/) {
        next unless $no_index->{$type};
        my $rest = $map{$type};
        my @entries = ref $no_index->{$type} eq ref []
            ? @{ $no_index->{$type} }
            : ( $no_index->{$type} );
        push @ignore, map {"^$_$rest"} @entries;
    }
    return unless @ignore;

    $me->d->{no_index} = join ';', sort @ignore;
    return '(?:' . (join '|', @ignore) . ')';
}

##################################################################
# Kwalitee Indicators
##################################################################

sub kwalitee_indicators {
  return [
    {
        name=>'has_readme',
        error=>q{The file "README" is missing from this distribution. The README provides some basic information to users prior to downloading and unpacking the distribution.},
        remedy=>q{Add a README to the distribution. It should contain a quick description of your module and how to install it.},
        code=>sub { shift->{file_readme} ? 1 : 0 },
        details=>sub {
            my $d = shift;
            return "README was not found.";
        },
    },
    {
        name=>'has_manifest',
        error=>q{The file "MANIFEST" is missing from this distribution. The MANIFEST lists all files included in the distribution.},
        remedy=>q{Add a MANIFEST to the distribution. Your buildtool should be able to autogenerate it (eg "make manifest" or "./Build manifest")},
        code=>sub { shift->{file_manifest} ? 1 : 0 },
        details=>sub {
            my $d = shift;
            return "MANIFEST was not found.";
        },
    },
    {
        name=>'has_meta_yml',
        error=>q{The file "META.yml" is missing from this distribution. META.yml is needed by people maintaining module collections (like CPAN), for people writing installation tools, or just people who want to know some stuff about a distribution before downloading it.},
        remedy=>q{Add a META.yml to the distribution. Your buildtool should be able to autogenerate it.},
        code=>sub {
            my $d = shift;
            return 1 if $d->{file_meta_yml};
            return 1 if $d->{is_local_distribution} && $d->{file_mymeta_yml};
            return 0;
        },
        details=>sub {
            my $d = shift;
            return "META.yml was not found.";
        },
    },
    {
        name=>'has_buildtool',
        error=>q{Makefile.PL and/or Build.PL are missing. This makes installing this distribution hard for humans and impossible for automated tools like CPAN/CPANPLUS/cpanminus.},
        remedy=>q{Add a Makefile.PL (for ExtUtils::MakeMaker/Module::Install) or a Build.PL (for Module::Build and its friends), or use a distribution builder such as Dist::Zilla, Dist::Milla, Minilla.},
        code=>sub {
            my $d=shift;
            return 1 if $d->{file_makefile_pl} || $d->{file_build_pl};
            return 0;
        },
        details=>sub {
            my $d = shift;
            return "Neither Makefile.PL nor Build.PL was found.";
        },
    },
    {
        name=>'has_changelog',
        error=>q{The distribution hasn't got a Changelog (named something like m/^chang(es?|log)|history$/i. A Changelog helps people decide if they want to upgrade to a new version.},
        remedy=>q{Add a Changelog (best named 'Changes') to the distribution. It should list at least major changes implemented in newer versions.},
        code=>sub { shift->{file_changelog} ? 1 : 0 },
        details=>sub {
            my $d = shift;
            return "Any Changelog file was not found.";
        },
    },
    {
        name=>'no_symlinks',
        error=>q{This distribution includes symbolic links (symlinks). This is bad, because there are operating systems that do not handle symlinks.},
        remedy=>q{Remove the symlinks from the distribution.},
        code=>sub {shift->{symlinks} ? 0 : 1},
        details=>sub {
            my $d = shift;
            return "The following symlinks were found: ".$d->{symlinks_list};
        },
    },
    {
        name=>'has_tests',
        error=>q{This distribution doesn't contain either a file called 'test.pl' or a directory called 't'. This indicates that it doesn't contain even the most basic test-suite. This is really BAD!},
        remedy=>q{Add tests!},
        code=>sub {
            my $d=shift;
            # TODO: make sure if .t files do exist in t/ directory.
            return 1 if $d->{file_test_pl} || $d->{dir_t};
            return 0;
        },
        details=>sub {
            my $d = shift;
            return q{Neither "test.pl" nor "t/" directory was not found.};
        },
    },
    {
        name=>'has_tests_in_t_dir',
        is_extra=>1,
        error=>q{This distribution contains either a file called 'test.pl' (the old test file) or is missing a directory called 't'. This indicates that it uses the old test mechanism or it has no test-suite.},
        remedy=>q{Add tests or move tests.pl to the t/ directory!},
        code=>sub {
            my $d=shift;
            # TODO: make sure if .t files do exist in t/ directory.
            return 1 if !$d->{file_test_pl} && $d->{dir_t};
            return 0;
        },
        details=>sub {
            my $d = shift;
            return q{"test.pl" was found.} if $d->{file_test_pl};
            return q{"t/" directory was not found.};
        },
    },
    {
        name=>'no_stdin_for_prompting',
        error=>q{This distribution is using direct call from STDIN instead of prompt(). Make sure STDIN is not used in Makefile.PL or Build.PL. See http://www.perlfoundation.org/perl5/index.cgi?cpan_packaging},
        is_extra=>1,
        remedy=>q{Use the prompt() method from ExtUtils::MakeMaker/Module::Build.},
        code=>sub {
            my $d=shift;
            if ($d->{stdin_in_makefile_pl}||$d->{stdin_in_build_pl}) {
                return 0;
            }
            return 1;
        },
        details=>sub {
            my $d = shift;
            return "<STDIN> was found in Makefile.PL" if $d->{stdin_in_makefile_pl};
            return "<STDIN> was found in Build.PL" if $d->{stdin_in_build_pl};
        },
    },
    {
        name=>'no_large_files',
        error=>qq{This distribution has at least one file larger than $large_file bytes)},
        remedy=>q{No remedy for that.},
        is_experimental=>1,
        code=>sub {
            my $d=shift;
            my @errors = map { "$_:$d->{files_hash}{$_}{size}" }
                         grep { $d->{files_hash}{$_}{size} > $large_file }
                         keys %{ $d->{files_hash} };
            if (@errors) {
                $d->{error}{no_large_files} = join "; ", @errors;
                return 0;
            }
            return 1;
        },
        details=>sub {
            my $d = shift;
            return "The following files were found: " . $d->{error}{no_large_files};
        },
    },
];
}


q{Favourite record of the moment:
  Fat Freddys Drop: Based on a true story};


__END__

=encoding UTF-8

=head1 NAME

Module::CPANTS::Kwalitee::Files - Check for various files

=head1 SYNOPSIS

Find various files and directories that should be part of every self-respecting distribution.

=head1 DESCRIPTION

=head2 Methods

=head3 order

Defines the order in which Kwalitee tests should be run.

Returns C<15>, as data generated by C<MCK::Files> is used by all other tests.

=head3 map_filenames

get db_filenames from real_filenames

=head3 analyse

C<MCK::Files> uses C<File::Find> to get a list of all files and dirs in a dist. It checks if certain crucial files are there, and does some other file-specific stuff.

=head3 get_files

The subroutine used by C<File::Find>. Unfortunantly, it depends on some global values.

=head3 kwalitee_indicators

Returns the Kwalitee Indicators datastructure.

=over

=item * extractable

=item * extracts_nicely

=item * has_readme

=item * has_manifest

=item * has_meta_yml

=item * has_buildtool

=item * has_changelog 

=item * no_symlinks

=item * has_tests

=item * has_tests_in_t_dir

=item * buildfile_not_executable

=item * has_example (optional)

=item * no_generated_file

=item * has_version_in_each_file

=item * no_stdin_for_prompting

=item * no_large_files

=item * portable_filenames

=item * no_dot_underscore_files

=back

=head1 SEE ALSO

L<Module::CPANTS::Analyse>

=head1 AUTHOR

L<Thomas Klausner|https://metacpan.org/author/domm>

=head1 COPYRIGHT AND LICENSE

Copyright © 2003–2006, 2009 L<Thomas Klausner|https://metacpan.org/author/domm>

You may use and distribute this module according to the same terms
that Perl is distributed under.
