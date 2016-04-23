package Business::Mondo::Account;

=head1 NAME

Business::Mondo::Account

=head1 DESCRIPTION

A class for a Mondo account, extends L<Business::Mondo::Resource>

=cut

use Moo;
extends 'Business::Mondo::Resource';
with 'Business::Mondo::Utils';

use Types::Standard qw/ :all /;
use Business::Mondo::Address;
use Business::Mondo::Exception;

=head1 ATTRIBUTES

The Account class has the following attributes (with their type).

    id (Str)
    description (Str)
    created (DateTime)

Note that when a Str is passed to ->created this will be coerced
to a DateTime object.

=cut

has [ qw/ id description / ] => (
    is  => 'ro',
    isa => Str,
);

has created => (
    is      => 'ro',
    isa     => Maybe[InstanceOf['DateTime']],
    coerce  => sub {
        my ( $args ) = @_;

        if ( ! ref( $args ) ) {
            $args = DateTime::Format::DateParse->parse_datetime( $args );
        }

        return $args;
    },
);

=head1 Operations on an account

None at present

=cut

sub url {
    Business::Mondo::Exception->throw({
        message => "Mondo API does not currently support getting account data",
    });
}

sub get {
    Business::Mondo::Exception->throw({
        message => "Mondo API does not currently support getting account data",
    });
}

=head1 SEE ALSO

L<Business::Mondo>

L<Business::Mondo::Client>

=head1 AUTHOR

Lee Johnson - C<leejo@cpan.org>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. If you would like to contribute documentation,
features, bug fixes, or anything else then please raise an issue / pull request:

    https://github.com/leejo/business-mondo

=cut

1;

# vim: ts=4:sw=4:et
