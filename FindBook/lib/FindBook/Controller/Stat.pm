package FindBook::Controller::Stat;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

FindBook::Controller::Stat - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub begin :Private {
    my ( $self, $c ) = @_;
    if(!$c->user_exists) {
        my $stat_url = $c->uri_for_action("/stat/index");
        my $cb_url = $c->uri_for_action("/user/login", {callback => $stat_url});
        $c->res->redirect($cb_url);
        return;
    }
}

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    
    my $num = $c->req->params->{num} || 100;
    my @keywords;
    my @clicks;
    my @kw_rows = $c->model('FindBookDB::Keyword')->search(undef, {order_by => {-desc => "ts"}, rows => $num})->all;
    my @ct_rows = $c->model('FindBookDB::Clicktrack')->search(undef, {order_by => {-desc => "ts"}, rows => $num})->all;
    foreach(@kw_rows) {
        my %kw = $_->get_columns();
        push(@keywords, \%kw);
    }

    foreach(@ct_rows) {
        my %ct = $_->get_columns();
        push(@clicks, \%ct);
    }
    
    $c->stash(
        template => "src/stat.tt",
        keywords => \@keywords,
        clicks   => \@clicks,
    );
}


=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
