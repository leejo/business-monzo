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

=head1 ATTRIBUTES

    id

    address

=cut

has [ qw/
    id
/ ] => (
    is  => 'rw',
    isa => Str,
);

has address => (
    is => 'rw',
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

=head1 Operations on an merchant

=head2 get

=cut

1;

# vim: ts=4:sw=4:et
