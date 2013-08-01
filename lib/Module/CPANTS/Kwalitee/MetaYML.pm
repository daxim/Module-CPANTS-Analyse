package Module::CPANTS::Kwalitee::MetaYML;
use warnings;
use strict;
use File::Spec::Functions qw(catfile);
use CPAN::Meta::YAML;
use CPAN::Meta::Validator;
use List::Util qw/first/;

our $VERSION = '0.88';

sub order { 10 }

my $CURRENT_SPEC = '1.4';
my $JSON_CLASS;

##################################################################
# Analyse
##################################################################

sub analyse {
    my $class=shift;
    my $me=shift;
    my $distdir=$me->distdir;
    my $meta_yml=catfile($distdir,'META.yml');

    # META.yml is not always the most preferred meta file,
    # but test it anyway because it may be broken sometimes.
    if (-f $meta_yml) {
        eval {
            open my $fh, '<:utf8', $meta_yml or die $!;
            my $yaml = do { local $/; <$fh> };
            my $meta = CPAN::Meta::YAML->read_string($yaml) or die CPAN::Meta::YAML->errstr;
            # Broken META.yml may return a "YAML 1.0" string first.
            # eg. M/MH/MHASCH/Date-Gregorian-0.07.tar.gz
            $me->d->{meta_yml}=first { ref $_ eq ref {} } @$meta;
            $me->d->{metayml_is_parsable}=1;
        };
        if ($@) {
            $me->d->{error}{metayml_is_parsable}=$@;
        }
    } else {
        $me->d->{error}{metayml_is_parsable}="META.yml was not found";
    }

    # If there's no META.yml, or META.yml has some errors,
    # check META.json.
    if (!$me->d->{meta_yml}) {
        unless ($JSON_CLASS) {
            for (qw/JSON::XS JSON::PP/) {
                if (eval "require $_; 1;") {
                    $JSON_CLASS = $_;
                    last;
                }
            }
        }

        my $meta_json = catfile($distdir,'META.json');
        if ($JSON_CLASS && -f $meta_json) {
            eval {
                open my $fh, '<:utf8', $meta_json or return;
                my $json = do { local $/; <$fh> };
                my $meta = $JSON_CLASS->new->utf8->decode($json);
                $me->d->{meta_yml} = $meta;
                $me->d->{metayml_is_parsable} = 1;
            };
            if ($@) {
                $me->d->{error}{metajson_is_parsable} = $@;
            }
        }
    }

    # If we still don't have meta data, try MYMETA.yml as we may be
    # testing a local distribution.
    if (!$me->d->{meta_yml}) {
        my $mymeta_yml = catfile($distdir, 'MYMETA.yml');
        if (-f $mymeta_yml) {
            eval {
                open my $fh, '<:utf8', $mymeta_yml or die $!;
                my $yaml = do { local $/; <$fh> };
                my $meta = CPAN::Meta::YAML->read_string($yaml) or die CPAN::Meta::YAML->errstr;
                $me->d->{meta_yml}=first { ref $_ eq ref {} } @$meta;
                $me->d->{metayml_is_parsable} = 1;
            };
        }
    }

    # Should we still try MYMETA.json?
}

##################################################################
# Kwalitee Indicators
##################################################################

sub kwalitee_indicators{
    return [
        {
            name=>'metayml_is_parsable',
            error=>q{The META.yml file of this distribution could not be parsed by the version of CPAN::Meta::YAML.pm CPANTS is using.},
            remedy=>q{If you don't have one, add a META.yml file. Else, upgrade your YAML generator so it produces valid YAML.},
            code=>sub { shift->{metayml_is_parsable} ? 1 : 0 },
            details=>sub {
                my $d = shift;
                $d->{error}{metayml_is_parsable};
            },
        },
        {
            name=>'metayml_has_license',
            error=>q{This distribution does not have a license defined in META.yml.},
            remedy=>q{Define the license if you are using in Build.PL. If you are using MakeMaker (Makefile.PL) you should upgrade to ExtUtils::MakeMaker version 6.31.},
            is_extra=>1,
            code=>sub { 
                my $d=shift;
                my $yaml=$d->{meta_yml};
                ($yaml->{license} and $yaml->{license} ne 'unknown') ? 1 : 0 },
            details=>sub {
                my $d = shift;
                my $yaml = $d->{meta_yml};
                return "No META.yml." unless $yaml;
                return "No license was found in META.yml." unless $yaml->{license};
                return "Unknown license was found in META.yml.";
            },
        },
        {
            name=>'metayml_has_provides',
            is_experimental=>1,
            error=>q{This distribution does not have a list of provided modules defined in META.yml.},
            remedy=>q{Add all modules contained in this distribution to the META.yml field 'provides'. Module::Build does this automatically for you.},
            code=>sub { 
                my $d=shift;
                return 1 if $d->{meta_yml} && $d->{meta_yml}{provides};
                return 0;
            },
            details=>sub {
                my $d = shift;
                return "No META.yml." unless $d->{meta_yml};
                return q{No "provides" was found in META.yml.};
            },
        },
        {
            name=>'metayml_conforms_to_known_spec',
            error=>q{META.yml does not conform to any recognised META.yml Spec.},
            remedy=>q{Take a look at the META.yml Spec at http://module-build.sourceforge.net/META-spec-current.html and change your META.yml accordingly.},
            code=>sub {
                my $d=shift;
                return check_spec_conformance($d);
            },
            details=>sub {
                my $d = shift;
                return "No META.yml." unless $d->{meta_yml};
                return join "; ", @{$d->{error}{metayml_conforms_to_known_spec}};
            },
        },
    {
            name=>'metayml_conforms_spec_current',
            is_extra=>1,
            error=>qq{META.yml does not conform to the Current META.yml Spec ($CURRENT_SPEC).},
            remedy=>q{Take a look at the META.yml Spec at http://module-build.sourceforge.net/META-spec-current.html and change your META.yml accordingly.},
            code=>sub {
                my $d=shift;
                return check_spec_conformance($d,$CURRENT_SPEC,1);
            },
            details=>sub {
                my $d = shift;
                return "No META.yml." unless $d->{meta_yml};
                return join "; ", @{$d->{error}{metayml_conforms_spec_current}};
            },
        },
        {
            name=>'metayml_declares_perl_version',
            error=>q{This distribution does not declare the minimum perl version in META.yml.},
            is_extra=>1,
            remedy=>q{If you are using Build.PL define the {requires}{perl} = VERSION field. If you are using MakeMaker (Makefile.PL) you should upgrade ExtUtils::MakeMaker to 6.48 and use MIN_PERL_VERSION parameter. Perl::MinimumVersion can help you determine which version of Perl your module needs.},
            code=>sub { 
                my $d=shift;
                my $yaml=$d->{meta_yml};
                return ref $yaml->{requires} eq ref {} && $yaml->{requires}{perl} ? 1 : 0;
            },
            details=>sub {
                my $d = shift;
                my $yaml = $d->{meta_yml};
                return "No META.yml." unless $yaml;
                return q{No "requires" was found in META.yml.} unless ref $yaml->{requires} eq ref {};
                return q{No "perl" subkey was found in META.yml.} unless $yaml->{requires}{perl};
            },
        },
    ];
}

sub check_spec_conformance {
    my ($d,$version,$check_current)=@_;

    my $report_version= $version || 'known';
    my $yaml=$d->{meta_yml};
    unless ($yaml && ref $yaml eq ref {} && %$yaml) {
        my $errorname='metayml_conforms_'.($check_current?'spec_current':'to_known_spec');
        $d->{error}{$errorname} = [$report_version, 'META.yml is missing/empty'];
        return 0;
    }

    my $spec = CPAN::Meta::Validator->new($yaml);
    $spec->{spec} = $version if $version;

    if (!$spec->is_valid) {
        my @errors;
        foreach my $e ($spec->errors) {
            next if $e=~/specification URL/ && $check_current;
            push @errors,$e;
        }
        if (@errors) {
            my $errorname='metayml_conforms_'.($check_current?'spec_current':'to_known_spec');
            $d->{error}{$errorname} = [$report_version, sort @errors];
            return 0;
        }
    }
    return 1;
}

q{Barbies Favourite record of the moment:
  Nine Inch Nails: Year Zero};

__END__

=encoding UTF-8

=head1 NAME

Module::CPANTS::Kwalitee::MetaYML - Checks data availabe in META.yml

=head1 SYNOPSIS

Checks various pieces of information in META.yml

=head1 DESCRIPTION

=head2 Methods

=head3 order

Defines the order in which Kwalitee tests should be run.

Returns C<10>. MetaYML should be checked earlier than Files to
handle no_index correctly.

=head3 analyse

C<MCK::MetaYML> checks C<META.yml>.

=head3 kwalitee_indicators

Returns the Kwalitee Indicators datastructure.

=over

=item * metayml_is_parsable

=item * metayml_has_license

=item * metayml_conforms_to_known_spec

=item * metayml_conforms_spec_current

=item * metayml_declares_perl_version

=back

=head3 check_spec_conformance

    check_spec_conformance($d,$version);

Validates META.yml using Test::CPAN::Meta.

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
