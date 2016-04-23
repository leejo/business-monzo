package Business::Mondo::Resource;

=head1 NAME

Business::Mondo::Resource

=head1 DESCRIPTION

This is a base class for Mondo resource classes, it implements common
behaviour. You shouldn't use this class directly, but extend it instead.

=cut

use Moo;
use Carp qw/ confess carp /;
use JSON ();
use Try::Tiny;

=head1 ATTRIBUTES

    client
    url
    url_no_id

=cut

has client => (
    is       => 'ro',
    isa      => sub {
        confess( "$_[0] is not a Business::Mondo::Client" )
            if ref $_[0] ne 'Business::Mondo::Client';

        $Business::Mondo::Resource::client = $_[0];
    },
    required => 1,
);

has [ qw/ url / ] => (
    is      => 'rw',
    lazy    => 1,
    default => sub {
        my ( $self ) = @_;
        join( '/',$self->url_no_id,$self->id )
    },
);

has [ qw/ url_no_id / ] => (
    is      => 'rw',
    lazy    => 1,
    default => sub {
        my ( $self ) = @_;
        return join(
            '/',
            $self->client->api_url,
            lc( ( split( ':',ref( $self ) ) )[-1] ) . 's',
        );
    },
);

=head1 METHODS

=head2 to_hash

Returns a hash representation of the object.

    my %data = $transaction->to_hash;

=head2 to_json

Returns a json string representation of the object.

    my $json = $transaction->to_json;

=head2 get

Populates the object with its attributes (calls the API)

    $transaction->get

This is for when you have instantiated an object with the id, so calling the API
will retrieve the full details for the entity.

If the data returned from Mondo contains attributes not available on the object
then warnings will be raised for those attributes that couldn't be set - if you
see any of these please raise an issue against the dist as these are likely due
to updates to the Mondo API.

=cut

sub to_hash {
    my ( $self ) = @_;

    my %hash = %{ $self };
    delete( $hash{client} );
    return %hash;
}

sub to_json {
    my ( $self ) = @_;
    return JSON->new->canonical->encode( { $self->to_hash } );
}

# for JSON encoding modules
sub TO_JSON { shift->to_hash; }

sub get {
    my ( $self,$sub_key ) = @_;

    my $data = $self->client->api_get( $self->url );

    $data = $data->{$sub_key} if $sub_key;

    foreach my $attr ( keys( %{ $data } ) ) {
        try { $self->$attr( $data->{$attr} ); }
        catch {
            carp( "Couldn't set $attr on @{[ ref( $self ) ]}: $_" );
        };
    }

    return $self;
}

=head1 AUTHOR

Lee Johnson - C<leejo@cpan.org>

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. If you would like to contribute documentation,
features, bug fixes, or anything else then please raise an issue / pull request:

    https://github.com/leejo/business-mondo

=cut

1;

# vim: ts=4:sw=4:et