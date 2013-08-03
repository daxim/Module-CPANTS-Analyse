package Module::CPANTS::Kwalitee::License;
use warnings;
use strict;
use File::Spec::Functions qw(catfile);
use Software::LicenseUtils;

our $VERSION = '0.90_02'; $VERSION = eval $VERSION;

sub order { 100 }

##################################################################
# Analyse
##################################################################

sub analyse {
    my $class=shift;
    my $me=shift;
    my $distdir=$me->distdir;

    # check META.yml
    my $yaml=$me->d->{meta_yml};
    $me->d->{license} = '';
    if ($yaml) {
        if ($yaml->{license} and $yaml->{license} ne 'unknown') {
            $me->d->{license_from_yaml} = $yaml->{license};
            $me->d->{license} = $yaml->{license}.' defined in META.yml';
        }
    }
    my $files = $me->d->{files_hash};

    # check if there's a LICEN[CS]E file
    if (my ($file) = grep {exists $files->{$_}} qw/LICENCE LICENSE/) {
        $me->d->{license} .= " defined in $file";
        $me->d->{external_license_file}=$file;
    }

    # check pod
    my %licenses;
    foreach my $file (grep { /\.p(m|od|l)$/ } keys %$files ) {
        my $path = catfile($distdir, $file);
        next unless -r $path; # skip if not readable
        open my $fh, '<', $path or next;
        my $in_pod = 0;
        my $pod = '';
        my @possible_licenses;
        my @unknown_license_texts;
        while(<$fh>) {
            if (/^=head\d\s+.*\b(?i:LICEN[CS]E|LICEN[CS]ING|COPYRIGHT|LEGAL)\b/) {
                $in_pod = 1;
                $pod = "=head1 LICENSE\n";
            }
            elsif (/^=(?:head\d\s+|cut)\b/) {
                $in_pod = 0;
                push @possible_licenses, Software::LicenseUtils->guess_license_from_pod("$pod\n\n=cut\n");

                push @unknown_license_texts, $pod unless @possible_licenses;
                $pod = '';
            }
            elsif ($in_pod) {
                $pod .= $_;
            }
        }
        if ($pod) {
            push @possible_licenses, Software::LicenseUtils->guess_license_from_pod("$pod\n\n=cut\n");
            push @unknown_license_texts, $pod unless @possible_licenses;
        }
        $me->d->{unknown_license_texts} = join "\n", @unknown_license_texts;

        next unless @possible_licenses;
        $me->d->{license_in_pod} = 1;
        $me->d->{license} ||= "defined in POD ($file)";

        $licenses{$_} = $file for @possible_licenses;
        $files->{$file}{license} = join ',', @possible_licenses;
    }
    if (%licenses) {
        $me->d->{licenses} = \%licenses;
        my @possible_licenses = keys %licenses;
        if (@possible_licenses == 1) {
            my ($type) = @possible_licenses;
            $me->d->{license_type} = $type;
            $me->d->{license_file} = $licenses{$type};
        }
    }

    return;
}

##################################################################
# Kwalitee Indicators
##################################################################

sub kwalitee_indicators{
    return [
         {
            name=>'has_human_readable_license',
            error=>q{This distribution does not have a license defined in the documentation or in a file called LICENSE},
            remedy=>q{Add a section called "LICENSE" to the documentation, or add a file named LICENSE to the distribution.},
            code=>sub {
                my $d = shift;
                return $d->{external_license_file} || $d->{license_in_pod} ? 1 : 0;
            },
            details=>sub {
                my $d = shift;
                return "Neither LICENSE file nor LICENSE section in pod was found.";
            },
        },
        {
            name=>'has_separate_license_file',
            error=>q{This distribution does not have a LICENSE or LICENCE file in its root directory.},
            remedy=>q{This is not a critical issue. Currently mainly informative for the CPANTS authors. It might be removed later.},
            is_experimental=>1,
            code=>sub { shift->{external_license_file} ? 1 : 0 },
            details=>sub {
                my $d = shift;
                return "LICENSE file was found.";
            },
        },
#        {
#            name=>'has_known_license_in_external_license_file',
#            error=>q{This distribution has a LICENSE or LICENCE file in its root directory but the license in it was not recognized by CPANTS.},
#            remedy=>q{Either CPANTS needs to be fixed or your LICENSE file.},
#            is_experimental=>1,
#            code=>sub { 
#                my $d = shift;
#                return 1 if not $d->{external_license_file};
#                return $d->{license_from_external_license_file} ? 1 : 0;
#            },
#        },
        {
            name=>'has_license_in_source_file',
            error=>q{Does not have license information in any of its source files},
            remedy=>q{Add =head1 LICENSE and the text of the license to the main module in your code.},
            code=>sub {
                my $d = shift;
                return $d->{license_in_pod} ? 1 : 0;
            },
            details=>sub {
                my $d = shift;
                return "LICENSE section was not found in the pod.";
            },
        },
    ];
}


q{Favourite record of the moment:
  Lili Allen - Allright, still};

__END__

=encoding UTF-8

=head1 NAME

Module::CPANTS::Kwalitee::License - Checks if there is a license

=head1 SYNOPSIS

Checks if the disttribution specifies a license.

=head1 DESCRIPTION

=head2 Methods

=head3 order

Defines the order in which Kwalitee tests should be run.

Returns C<100>.

=head3 analyse

C<MCK::License> checks if there's a C<license> field C<META.yml>. Additionally, it looks for a file called LICENSE and a POD section namend LICENSE

=head3 kwalitee_indicators

Returns the Kwalitee Indicators datastructure.

=over

=item * has_license 

=item * has_license_in_metayml 


=back

=head2 License information

Pleaces wher the licens information is taken from:

Has a LICENSE file   file_license 1|0

Content of LICENSE file matches License X from Software::License

License in META.yml

License in META.yml matches one of the known licenses

License in source files recognized by Software::LicenseUtils
For each file keep where is was it recognized.

Has license or copyright entry in pod (that might not be recognized by Software::LicenseUtils)

# has_license

=head1 SEE ALSO

L<Module::CPANTS::Analyse>

=head1 AUTHOR

L<Thomas Klausner|https://metacpan.org/author/domm>
and L<Gábor Szabó|https://metacpan.org/author/szabgab>

=head1 COPYRIGHT AND LICENSE

Copyright © 2003–2009 L<Thomas Klausner|https://metacpan.org/author/domm>

Copyright © 2006–2008 L<Gábor Szabó|https://metacpan.org/author/szabgab>

You may use and distribute this module according to the same terms
that Perl is distributed under.
