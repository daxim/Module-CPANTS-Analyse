package Module::CPANTS::Kwalitee::Uses;
use warnings;
use strict;
use File::Spec::Functions qw(catfile);
use Module::ExtractUse;
use Set::Scalar qw();
use Data::Dumper;

our $VERSION = '0.87';

sub order { 100 }

##################################################################
# Analyse
##################################################################

sub analyse {
    my $class=shift;
    my $me=shift;
    
    my $distdir=$me->distdir;
    my $modules=$me->d->{modules};
    my $files=$me->d->{files_array};
    my @tests=grep {m|^x?t\b.*\.t|} @$files;
    $me->d->{test_files} = \@tests;

    my %skip=map {$_->{module}=>1 } @$modules;
    my %uses;

    foreach (@$modules) {
        my $p = Module::ExtractUse->new;
        $p->extract_use(catfile($distdir,$_->{file}));
        $_->{uses} = $p->used;
    }

    # used in modules
    my $p=Module::ExtractUse->new;
    foreach (@$modules) {
        $p->extract_use(catfile($distdir,$_->{file}));
    }

    while (my ($mod,$cnt)=each%{$p->used}) {
        next if $skip{$mod};
        next if $mod =~ /::$/;  # see RT#35092
        $uses{$mod}={
            module=>$mod,
            in_code=>$cnt,
            in_tests=>0,
        };
    }
    
    # used in tests
    my $pt=Module::ExtractUse->new;
    foreach my $tf (@tests) {
        next if -s catfile($distdir,$tf) > 1_000_000; # skip very large test files
        $pt->extract_use(catfile($distdir,$tf));
    }
    while (my ($mod,$cnt)=each%{$pt->used}) {
        next if $skip{$mod};
        if ($uses{$mod}) {
            $uses{$mod}{'in_tests'}=$cnt;
        } else {
            $uses{$mod}={
                module=>$mod,
                in_code=>0,
                in_tests=>$cnt,
            }
        }
    }

    $me->d->{uses}=\%uses;
    return;
}

##################################################################
# Kwalitee Indicators
##################################################################

sub kwalitee_indicators {
    return [
        {
            name=>'use_strict',
            error=>q{This distribution does not 'use strict;' in all of its modules.},
            remedy=>q{Add 'use strict' to all modules.},
            code=>sub {
                my $d       = shift;
                my $modules = $d->{modules};
                my $uses    = $d->{uses};
                return 0 unless $modules && $uses;

                # There are lots of acceptable strict alternatives
                my $strict_equivalents = Set::Scalar->new->insert(qw(
                    strict
                    Any::Moose
                    Class::Spiffy
                    Coat
                    common::sense
                    Dancer
                    Mo
                    Modern::Perl
                    Mojo::Base
                    Moo
                    Moose
                    Moose::Role
                    MooseX::Declare
                    MooseX::Role::Parameterized
                    MooseX::Types
                    Mouse
                    Mouse::Role
                    perl5
                    perl5i::1
                    perl5i::2
                    perl5i::latest
                    Spiffy
                    strictures
                ));

                for my $module (@{ $modules }) {
                    return 0 if $strict_equivalents
                        ->intersection(Set::Scalar->new(keys %{ $module->{uses} }))
                        ->is_empty;
                }
                return 1;
            },
        },
        {
            name=>'use_warnings',
            error=>q{This distribution does not 'use warnings;' in all of its modules.},
            is_extra=>1,
            remedy=>q{Add 'use warnings' to all modules. (This will require perl > 5.6)},
            code=>sub {
                my $d       = shift;
                my $modules = $d->{modules};
                my $uses    = $d->{uses};
                return 0 unless $modules && $uses;

                my $warnings_equivalents = Set::Scalar->new->insert(qw(
                    warnings
                    Any::Moose
                    Class::Spiffy
                    Coat
                    common::sense
                    Dancer
                    Mo
                    Modern::Perl
                    Mojo::Base
                    Moo
                    Moose
                    Moose::Role
                    MooseX::Declare
                    MooseX::Types
                    Mouse
                    Mouse::Role
                    perl5
                    perl5i::1
                    perl5i::2
                    perl5i::latest
                    Spiffy
                    strictures
                ));

                for my $module (@{ $modules }) {
                    return 0 if $warnings_equivalents
                        ->intersection(Set::Scalar->new(keys %{ $module->{uses} }))
                        ->is_empty;
                }
                return 1;
            },
        },
        
        {
            name=>'has_test_pod',
            error=>q{Doesn't include a test for pod correctness (Test::Pod)},
            remedy=>q{Add a test using Test::Pod to check for pod correctness.},
            is_extra=>1,
            code=>sub {
                my $d=shift;
                return 1 if $d->{uses}->{'Test::Pod'};
                return 0;
            },
        },
        {
            name=>'has_test_pod_coverage',
            error=>q{Doesn't include a test for pod coverage (Test::Pod::Coverage)},
            remedy=>q{Add a test using Test::Pod::Coverage to check for POD coverage.},
            is_extra=>1,
            code=>sub {
                my $d=shift;
                return 1 if $d->{uses}->{'Test::Pod::Coverage'};
                return 0;
            },
        },
        {
            name=>'uses_test_nowarnings',
            error=>q{Doesn't use Test::NoWarnings in all the test files},
            remedy=>q{Add Test::NoWarnings to each one of the .t files and increment the test count by 1.},
            is_experimental=>1,
            code=>sub {
                my $d=shift;
                my $tests=$d->{test_files};
                my @public_test_files = grep {/^t/} @$tests;
                my $uses=$d->{uses};
                return 0 unless $tests && $uses;
                
                my ($test_no_warnings)=$uses->{'Test::NoWarnings'};
                return 0 unless $test_no_warnings;
                return 1 if $test_no_warnings->{in_tests} >= @public_test_files;
                return 0;
            },
        },
    ];
}


q{Favourite record of the moment:
  Fat Freddys Drop: Based on a true story};

__END__

=encoding UTF-8

=head1 NAME

Module::CPANTS::Kwalitee::Uses - Checks which modules are used

=head1 SYNOPSIS

Check which modules are actually used in the code.

=head1 DESCRIPTION

=head2 Methods

=head3 order

Defines the order in which Kwalitee tests should be run.

Returns C<100>.

=head3 analyse

C<MCK::Uses> uses C<Module::ExtractUse> to find all C<use> statements in code (actual code and tests).

=head3 kwalitee_indicators

Returns the Kwalitee Indicators datastructure.

=over

=item * use_strict

=item * has_test_pod

=item * has_test_pod_coverage

=item * uses_test_nowarnings

=back

=head1 SEE ALSO

L<Module::CPANTS::Analyse>

=head1 AUTHOR

L<Thomas Klausner|https://metacpan.org/author/domm>

=head1 COPYRIGHT AND LICENSE

Copyright © 2003–2006, 2009 L<Thomas Klausner|https://metacpan.org/author/domm>

You may use and distribute this module according to the same terms
that Perl is distributed under.
