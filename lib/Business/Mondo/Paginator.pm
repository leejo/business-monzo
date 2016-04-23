package Business::Mondo::Paginator;

=head1 NAME

Business::Mondo::Paginator

=head1 DESCRIPTION

A class for pagination through Mondo data returned as a list.

=cut

use Moo;
use JSON ();

=head1 ATTRIBUTES

    client
    objects
    class
    links

=cut

has [ qw/ client objects class links / ] => (
    is => 'rw'
);

=head1 PAGER METHODS

    next
    previous

Return the current set of objects and then gets the next/previous page:

    my @objects = $Paginator->next;

=head2 objects

Gets the current set of objects

    my @objects = $Paginator->objects;

=head2 links

Returns a hash that has the NextURL and previousURL within

    my $urls = $Paginator->links

=cut

sub next {
    my ( $self ) = @_;

    if ( my @objects = @{ $self->objects // [] } ) {
        # get the next chunk and return the current chunk
        $self->objects( $self->_objects_from_page( 'next' ) );
        return @objects;
    }

    return;
}

sub previous {
    my ( $self ) = @_;
    return @{ $self->_objects_from_page( 'previous' ) };
}

sub _objects_from_page {

    my ( $self,$page ) = @_;

    # see if we have more data to get
    if ( my $url = $self->links->{$page} ) {

        my $data    = $self->client->api_get( $url );
        my $class   = $self->class;

        my @objects = map {
            $class->new(
                client => $self->client,
                # $_ might be a list of urls or list of hashes
                ( ref( $_ ) ? ( %{ $_ } ) : ( url => $_ ) ),
            )
        } @{ $data->{Items} };

        $self->links({
            next     => $data->{NextURL},
            previous => $data->{PreviousURL},
        });

        return [ @objects ];
    }

    return [];
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
