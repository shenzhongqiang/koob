package FindBook::Controller::User;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

FindBook::Controller::User - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched FindBook::Controller::User in User.');
}

sub login: Local :Args(0) {
    my ( $self, $c ) = @_;
    my $user = $c->req->params->{username};
    my $pwd = $c->req->params->{password};
    my $url = $c->req->params->{red};
    if($user && $pwd) {
        if($c->authenticate({username => $user, password => $pwd})) {

        }
    }

    $c->stash(template => "src/login.tt");
}


=head1 AUTHOR

Zhongqiang Shen,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
