package Business::Mondo;

=head1 NAME

Business::Mondo - Perl library for interacting with the Mondo API
(https://api.getmondo.co.uk)

=for html
<a href='https://travis-ci.org/G3S/business-mondo?branch=master'><img src='https://travis-ci.org/G3S/business-mondo.svg?branch=master' alt='Build Status' /></a>
<a href='https://coveralls.io/r/G3S/business-mondo?branch=master'><img src='https://coveralls.io/repos/G3S/business-mondo/badge.png?branch=master' alt='Coverage Status' /></a>

=head1 VERSION

0.01

=head1 DESCRIPTION

Business::Mondo is a library for easy interface to the Mondo banking API,
it implements all of the functionality currently found in the service's API
documentation: https://getmondo.co.uk/doc

B<You should refer to the official Mondon API documentation in conjunction>
B<with this perldoc>, as the official API documentation explains in more depth
some of the functionality including required / optional parameters for certain
methods.

Please note this library is very much a work in progress, as is the Mondo API.

=head1 SYNOPSIS

    # agency API:
    my $mondo = Business::Mondo->new(
        token => $token,
    );

=head1 ERROR HANDLING

Any problems or errors will result in a Business::Mondo::Exception
object being thrown, so you should wrap any calls to the library in the
appropriate error catching code (TryCatch in the below example):

    use TryCatch;

    try {
        ...
    }
    catch ( Business::Mondo::Exception $e ) {
        # error specific to Business::Mondo
        ...
        say $e->message;  # error message
        say $e->code;     # HTTP status code
        say $e->response; # HTTP status message

        # ->request may not always be present
        say $e->request->{path}    if $e->request
        say $e->request->{params}  if $e->request
        say $e->request->{headers} if $e->request
        say $e->request->{content} if $e->request
    }
    catch ( $e ) {
        # some other failure?
        ...
    }

You can view some useful debugging information by setting the MONDO_DEBUG
env varible, this will show the calls to the Mondo endpoints as well as a
stack trace in the event of exceptions:

    $ENV{MONDO_DEBUG} = 1;

=cut

use Moo;
with 'Business::Mondo::Version';

use Carp qw/ confess /;

use Business::Mondo::Client;

=head1 ATTRIBUTES

=head2 token

Your Mondo access token, this is required

=head2 api_url

The Mondo url, which will default to https://api.getmondo.co.uk

=head2 client

A Business::Mondo::Client object, this will be constructed for you so
you shouldn't need to pass this

=cut

has [ qw/ token / ] => (
    is       => 'ro',
    required => 1,
);

has api_url => (
    is       => 'ro',
    required => 0,
    default  => sub { $Business::Mondo::API_URL },
);

has client => (
    is       => 'ro',
    isa      => sub {
        confess( "$_[0] is not a Business::Mondo::Client" )
            if ref $_[0] ne 'Business::Mondo::Client';
    },
    required => 0,
    lazy     => 1,
    default  => sub {
        my ( $self ) = @_;

        return Business::Mondo::Client->new(
            token   => $self->token,
            api_url => $self->api_url,
        );
    },
);

=head1 METHODS

In the following %query_params refers to the possible query params as shown in
the Mondo API documentation. For example: limit=100.

    # transactions in the previous month
    my @transactions = $mondo->transactions(
        since => DateTime->now->subtract( months => 1 ),
    );

=head2 transaction

    my $Transaction = $mondo->transaction(
        id     => $id,
        expand => 'merchant'
    );

Get a transaction. Will return a L<Business::Mondo::Transaction> object

=head2 transactions

    $mondo->transactions( %query_params );

Get a list of transactions. Will return a list of L<Business::Mondo::Transaction>
objects. Note you must supply an account_id in the params hash;

=head2 accounts

    $mondo->accounts;

Get a list of accounts. Will return a list of L<Business::Mondo::Account>
objects

=cut

sub transactions {
    my ( $self,%params ) = @_;
    return $self->client->_get_transactions( \%params );
}

sub transaction {
    my ( $self,%params ) = @_;

    if ( my $expand = delete( $params{expand} ) ) {
        $params{'expand[]'} = $expand;
    }

    return $self->client->_get_transaction( \%params );
}

sub accounts {
    my ( $self ) = @_;
    return $self->client->_get_accounts;
}

=head1 EXAMPLES

See the t/002_end_to_end.t test included with this distribution. you can run
this test against the Mondo emulator (this is advised, don't run it against a
live endpoint).

=head1 SEE ALSO

L<Business::Mondo::Client>

L<Business::Mondo::Transaction>

L<Business::Mondo::Account>

L<Business::Mondo::Merchant>

L<Business::Mondo::Address>

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
