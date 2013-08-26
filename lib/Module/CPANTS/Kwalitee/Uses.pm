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

    # NOTE: all files in xt/ should be ignored because they are
    # for authors only and their dependencies may not be (and
    # often are not) listed in meta files.
    my @tests=grep {m|^t\b.*\.t|} @$files;
    $me->d->{test_files} = \@tests;

    my %skip=map {$_->{module}=>1 } @$modules;
    my %uses;

    foreach (@$modules) {
        my $p = Module::ExtractUse->new;
        my $file = catfile($distdir,$_->{file});
        $p->extract_use($file) if -f $file;
        $_->{uses} = $p->used;
    }

    # used in modules
    my $p=Module::ExtractUse->new;
    foreach (@$modules) {
        my $file = catfile($distdir,$_->{file});
        $p->extract_use($file) if -f $file;
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
        my $file = catfile($distdir,$tf);
        $pt->extract_use($file) if -f $file && -s $file < 1_000_000; # skip very large test files
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

=back

=head1 SEE ALSO

L<Module::CPANTS::Analyse>

=head1 AUTHOR

L<Thomas Klausner|https://metacpan.org/author/domm>

=head1 COPYRIGHT AND LICENSE

Copyright © 2003–2006, 2009 L<Thomas Klausner|https://metacpan.org/author/domm>

You may use and distribute this module according to the same terms
that Perl is distributed under.
