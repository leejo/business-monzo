package Business::Monzo::Utils;

=head1 NAME

Business::Monzo::Utils

=head1 DESCRIPTION

A role containing Monzo utilities.

=cut

use strict;
use warnings;

use Moo::Role;

=head1 METHODS

=head2 normalize_params

Normalizes the passed params hash into a string for use in queries to the
Monzo API. If a second true value is passed this will includes RFC5849
encoding and will convert DateTime objects into the corresponding ISO8601
string

    my $query_string = $self->normalize_params( \%params,$rfc_encode );

=cut

sub normalize_params {
    my ( $self,$params,$rfc_encode ) = @_;

    return '' if ( ! $params || ! keys( %{ $params } ) );

    return join( '&',
        map { $_->[0] . '=' . $_->[1]  }
        map { $rfc_encode
            ? [ _rfc5849_encode( $_ ),_rfc5849_encode( $params->{$_} ) ]
            : [ $_,$params->{$_} ]
        }
        sort { $a cmp $b }
        keys( %{ $params } )
    );
}

sub _rfc5849_encode {
    my ( $str ) = @_;

    if ( ref( $str ) eq 'DateTime' ) {
        $str = $str->iso8601;
    }

    $str =~ s#([^-.~_a-z0-9])#sprintf('%%%02X', ord($1))#gei;
    return $str;
}

sub _params_as_array_string {
    my ( $self,$key,$params ) = @_;

    my %modded_params = map {
        +"$key\[$_\]" => ref( $params->{$_} ) eq 'DateTime'
            ? $params->{$_}->iso8601 : $params->{$_}
    } keys %{ $params };

    return %modded_params;
}

=head1 AUTHOR

Lee Johnson - C<leejo@cpan.org>

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. If you would like to contribute documentation,
features, bug fixes, or anything else then please raise an issue / pull request:

    https://github.com/leejo/business-monzo

=cut

1;

# vim: ts=4:sw=4:et
