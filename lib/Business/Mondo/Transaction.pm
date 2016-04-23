package Business::Mondo::Transaction;

=head1 NAME

Business::Mondo::Transaction

=head1 DESCRIPTION

A class for a Mondo transaction, extends L<Business::Mondo::Resource>

=cut

use Moo;
extends 'Business::Mondo::Resource';
with 'Business::Mondo::Utils';

use Types::Standard qw/ :all /;
use Business::Mondo::Merchant;
use Data::Currency;
use DateTime::Format::DateParse;

=head1 ATTRIBUTES

The Transaction class has the following attributes (with their type).

    id (Str)
    description (Str)
    notes (Str)
    account_balance (Int)
    amount (Int)
    metadata (HashRef)
    is_load (Bool)
    settled (Bool)
    merchant (Business::Mondo::Merchant)
    currency (Data::Currency)
    created (DateTime)

Note that if a HashRef or Str is passed to ->merchant it will be coerced
into a Business::Mondo::Merchant object. When a Str is passed to ->currency
this will be coerced to a Data::Currency object, and when a Str is passed
to ->created this will be coerced to a DateTime object.

=cut

has [ qw/ id description notes / ] => (
    is  => 'ro',
    isa => Str,
);

has [ qw/ account_balance amount / ] => (
    is  => 'ro',
    isa => Int,
);

has [ qw/ metadata / ] => (
    is  => 'ro',
    isa => HashRef,
);

has [ qw/ is_load settled / ] => (
    is  => 'ro',
    isa => Bool,
);

has merchant => (
    is      => 'ro',
    isa     => Maybe[InstanceOf['Business::Mondo::Merchant']],
    coerce  => sub {
        my ( $args ) = @_;

        if ( ref( $args ) eq 'HASH' ) {
            $args = Business::Mondo::Merchant->new(
                client => $Business::Mondo::Resource::client,
                %{ $args },
            );
        } elsif ( ! ref( $args ) ) {
            $args = Business::Mondo::Merchant->new(
                client => $Business::Mondo::Resource::client,
                id     => $args,
            );
        }

        return $args;
    },
);

has currency => (
    is      => 'ro',
    isa     => Maybe[InstanceOf['Data::Currency']],
    coerce  => sub {
        my ( $args ) = @_;

        if ( ! ref( $args ) ) {
            $args = Data::Currency->new({
                code => $args,
            });
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

=head1 Operations on an transaction

=head2 get

=cut

sub get {
    shift->SUPER::get( 'transaction' );
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
