package FindBook::Controller::Book;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

FindBook::Controller::Book - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash(template => "src/book.tt");
}

sub list :Local :Args(1) {
    my ( $self, $c ) = @_;
    my $id = $c->req->arguments->[0];

    $c->stash(id => $id);
    $c->stash(template => "src/book.tt");
}

=head1 AUTHOR

Zhongqiang Shen,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
