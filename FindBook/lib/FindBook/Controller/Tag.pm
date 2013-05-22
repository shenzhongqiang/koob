package FindBook::Controller::Tag;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

FindBook::Controller::Tag - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    
    my @tag_rows = $c->model('FindBookDB::Tag')->all;
    my @all_tags;
    foreach my $row (@tag_rows) {
        my $tag_hr = list_single_tag($row);
        push(@all_tags, $tag_hr);
    }
    $c->stash(all_tags => \@all_tags);
    $c->stash(template => "src/tag.tt");
}

sub list :Local :Args(1) {
    my ( $self, $c ) = @_;
    my $id = $c->req->arguments->[0];

    $c->stash(id => $id);
    $c->stash(template => "src/tag.tt");
}

sub add :Local :Args(0) {
    my ( $self, $c ) = @_;
    
    my $catalog = $c->req->params->{catalog};
    my $subcat = $c->req->params->{subcat};
    
    my $tag_row = $c->model('FindBookDB::Tag')->find({catalog => $catalog, subcat => $subcat});
    if(defined $tag_row) {
        TagAlreadyExists->throw(catalog => $catalog, subcat => $subcat);
    }
    $c->model('FindBookDB::Tag')->create({
        catalog => $catalog,
        subcat  => $subcat,
    });
    $c->forward('/tag/index');
}

sub del :Local :Args(1) {
    my ( $self, $c ) = @_;
    
    my $id = $c->req->arguments->[0];
    
    $c->model('FindBookDB::Tag')->find({
        id => $id,
    })->delete;
    $c->forward('/tag/index');
}

sub list_single_tag {
    my $tag_row = shift;

    return {
        id      => $tag_row->id,
        catalog => $tag_row->catalog,
        subcat  => $tag_row->subcat,
    };
}

=head1 AUTHOR

Zhongqiang Shen,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
