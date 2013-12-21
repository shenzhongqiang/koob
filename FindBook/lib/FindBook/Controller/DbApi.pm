package FindBook::Controller::DbApi;
use strict;
use warnings;
use Moose;
use namespace::autoclean;
use Try::Tiny;
use DbBook;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

FindBook::Controller::DbApi - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub get_book :Local :Args(1) {
    my ( $self, $c ) = @_;
    my $isbn = $c->req->arguments->[0];

    my $resp;
    try {
        my $book_hr = DbBook->new->get_book($isbn);
        $c->stash(
            success => 1, 
            msg     => "", 
            book    => $book_hr,
        );
    }
    catch {
        $c->stash(
            success => 0,
            msg     => $_->error,
        );
    };
    $c->forward('View::JSON');
}


=head1 AUTHOR

Zhongqiang Shen,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
