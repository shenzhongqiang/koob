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
    my $cb_url = $c->req->params->{callback} || $c->uri_for_action("/index");
    my $url = $c->uri_for_action("/user/login", {callback => $cb_url});

    if(!defined $user && !defined $pwd) {
        $c->stash(url => $url, template => "src/login.tt");
        return;
    }

    if($user && $pwd) {
        if($c->authenticate({username => $user, password => $pwd})) {
            print "redirect to $cb_url\n";
            $c->res->redirect($cb_url);
            print "redirect done: $cb_url\n";
            return;
        }
        else {
            $c->stash(error => "Bad username or password");
        }
    }
    else {
        $c->stash(error => "Empty username or password");
    };

    $c->stash(url => $url, template => "src/login.tt");
}


=head1 AUTHOR

Zhongqiang Shen,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
