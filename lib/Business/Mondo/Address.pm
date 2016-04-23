package Business::Mondo::Address;

=head1 NAME

Business::Mondo::Address

=head1 DESCRIPTION

A class for a Mondo address, extends L<Business::Mondo::Resource>

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
    address
    city
    country
    postcode
    region
/ ] => (
    is  => 'rw',
    isa => Str,
);

=head1 Operations on an address

=head2 get

=cut

1;

# vim: ts=4:sw=4:et
