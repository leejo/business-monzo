package Business::Mondo::Merchant;

=head1 NAME

Business::Mondo::Merchant

=head1 DESCRIPTION

A class for a Mondo merchant, extends L<Business::Mondo::Resource>

=cut

use Moo;
extends 'Business::Mondo::Resource';
with 'Business::Mondo::Utils';

use Types::Standard qw/ :all /;
use Business::Mondo::Address;
use Business::Mondo::Exception;

=head1 ATTRIBUTES

The Merchant class has the following attributes (with their type).

    id (Str)
    group_id (Str)
    logo (Str)
    emoji (Str)
    name (Str)
    category (Str)
    address (Business::Mondo::Address)
    created (DateTime)

Note that if a HashRef or Str is passed to ->address it will be coerced
into a Business::Mondo::Address object. When a Str is passed to ->created
this will be coerced to a DateTime object.

=cut

has [ qw/ id group_id logo emoji name category / ] => (
    is  => 'ro',
    isa => Str,
);

has address => (
    is => 'ro',
    isa => Maybe[InstanceOf['Business::Mondo::Address']],
    coerce  => sub {

        my ( $args ) = @_;

        if ( ref ( $args ) eq 'HASH' ) {
            $args = Business::Mondo::Address->new(
                client => $Business::Mondo::Resource::client,
                %{ $args },
            );
        }

        return $args;
    },
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

=head1 Operations on an merchant

None at present

=cut

sub get {
    Business::Mondo::Exception->throw({
        message => "Mondo API does not currently support getting merchant data",
    });
}

=head1 SEE ALSO

L<Business::Mondo>

L<Business::Mondo::Resource>

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
