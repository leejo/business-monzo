package Business::Mondo::Client;

=head1 NAME

Business::Mondo::Client

=head1 DESCRIPTION

This is a class for the lower level requests to the Mondo API. generally
there is nothing you should be doing with this.

=cut

use Moo;
with 'Business::Mondo::Utils';
with 'Business::Mondo::Version';

use Business::Mondo::Exception;
use Business::Mondo::Transaction;

use MIME::Base64 qw/ encode_base64 /;
use LWP::UserAgent;
use JSON ();
use Carp qw/ carp /;

=head1 ATTRIBUTES

=head2 token

Your Mondo access token, this is required

=head2 api_url

The Mondo url, which will default to https://api.getmondo.co.uk

=cut

has [ qw/ token / ] => (
    is       => 'ro',
    required => 1,
);

has api_url => (
    is       => 'ro',
    required => 0,
    default  => sub {
        return $ENV{MONDO_URL} || $Business::Mondo::API_URL;
    },
);

sub _get_transactions {
    my ( $self,$params ) = @_;

    my $transactions = $self->_api_request( 'GET','transactions' );
    my @transactions;

    foreach my $transaction ( @{ $transactions->{transactions} // [] } ) {

        push(
            @transactions,
            Business::Mondo::Transaction->new(
                client => $self,
                %{ $transaction },
            )
        );

    }

    return @transactions;
}

sub _get_transaction {
    my ( $self,$params ) = @_;

    my $data = $self->_api_request( 'GET',"transactions/" . $params->{id} );

    my $transaction = Business::Mondo::Transaction->new(
        client => $self,
        %{ $data },
    );

    return $transaction;
}

=head1 METHODS

    api_get
    api_post
    api_delete

Make a request to the Mondo API:

    my $data = $Client->api_get( 'foo',\%params );

May return a list of L<Business::Mondo::foo> objects

=cut

sub api_get {
    my ( $self,$path,$params ) = @_;
    return $self->_api_request( 'GET',$path,$params );
}

sub api_post {
    my ( $self,$path,$params ) = @_;
    return $self->_api_request( 'POST',$path,$params );
}

sub api_delete {
    my ( $self,$path,$params ) = @_;
    return $self->_api_request( 'DELETE',$path,$params );
}

sub _api_request {
    my ( $self,$method,$path,$params ) = @_;

    carp( "$method -> $path" )
        if $ENV{MONDO_DEBUG};

    my $ua = LWP::UserAgent->new;
    $ua->agent( $self->user_agent );

    $path = $self->_add_query_params( $path,$params )
        if $method eq 'GET';

    my $req = $self->_build_request( $method,$path );

    if ( $method =~ /POST|PUT|DELETE/ ) {
        if ( $params ) {
            $req->content_type( 'application/json' );
            $req->content( JSON->new->encode( $params ) );

            carp( $req->content )
                if $ENV{MONDO_DEBUG};
        }
    }

    my $res = $ua->request( $req );

    if ( $res->is_success ) {
        my $data = $res->content;

        if ( $res->headers->header( 'content-type' ) =~ m!application/json! ) {
            $data = JSON->new->decode( $data );
        }

        return $data;
    }
    else {

        carp( "RES: @{[ $res->code ]}" )
            if $ENV{MONDO_DEBUG};

        Business::Mondo::Exception->throw({
            message  => $res->content,
            code     => $res->code,
            response => $res->status_line,
        });
    }
}

sub _build_request {
    my ( $self,$method,$path ) = @_;

    my $req = HTTP::Request->new(
        # passing through the absolute URL means we don't build it
        $method => $path =~ /^http/
            ? $path : join( '/',$self->base_url . $self->api_path,$path ),
    );

    carp(
        $method => $path =~ /^http/
            ? $path : join( '/',$self->base_url . $self->api_path,$path ),
    ) if $ENV{MONDO_DEBUG};

    $self->_set_request_headers( $req );

    return $req;
}

sub _set_request_headers {
    my ( $self,$req ) = @_;

    my $auth_string = "Bearer " . $self->token;

    $req->header( 'Authorization' => $auth_string );

    carp( "Authorization: $auth_string" )
        if $ENV{MONDO_DEBUG};

    $req->header( 'Accept' => 'application/json' );
}

sub _add_query_params {
    my ( $self,$path,$params ) = @_;

    if ( my $query_params = $self->normalize_params( $params ) ) {
        return "$path?$query_params";
    }

    return $path;
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
