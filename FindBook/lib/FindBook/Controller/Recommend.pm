package FindBook::Controller::Recommend;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

FindBook::Controller::Recommend - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my @catalogs = $c->model('FindBookDB::Tag')->search(undef, {order_by => 'catalog', distinct => 'catalog'})->get_column('catalog')->all;
    my @book_rows = $c->model('FindBookDB::Book')->search(undef, {order_by => {-desc => 'id'}});
    my @books;
    foreach(@book_rows) {
        my $book_hr = $c->forward('/book/list_book_summary', [$_]);
        push(@books, $book_hr);
    }
    $c->stash(
        template => "src/recommend.tt",
        catalogs => \@catalogs,
        books    => \@books,
    );
}

sub catalog :Local :Args(1) {
    my ( $self, $c ) = @_;
    my $catalog = $c->req->arguments->[0];

    my @catalogs = $c->model('FindBookDB::Tag')->search(undef, {order_by => 'catalog', distinct => 'catalog'})->get_column('catalog')->all;
    my @subcats = $c->model('FindBookDB::Tag')->search({catalog => $catalog}, {order_by => 'id'})->get_column('subcat')->all;
    my @book_rows = $c->model('FindBookDB::Book')->search({'tag.catalog' => $catalog}, {join => 'tag'});
    my @books;
    foreach(@book_rows) {
        my $book_hr = $c->forward('/book/list_book_summary', [$_]);
        push(@books, $book_hr);
    }
    $c->stash(
        template => "src/recommend.tt",
        catalogs => \@catalogs,
        subcats  => \@subcats,
        catalog  => $catalog,
        books    => \@books,
    );
}

sub subcat :Local :Args(1) {
    my ( $self, $c ) = @_;
    my $subcat = $c->req->arguments->[0];

    my $tag_row = $c->model('FindBookDB::Tag')->find({subcat => $subcat});
    my $catalog = $tag_row->catalog;
    my @catalogs = $c->model('FindBookDB::Tag')->search(undef, {order_by => 'catalog', distinct => 'catalog'})->get_column('catalog')->all;
    my @subcats = $c->model('FindBookDB::Tag')->search({catalog => $catalog}, {order_by => 'id'})->get_column('subcat')->all;
    my @book_rows = $tag_row->books;
    my @books;
    foreach(@book_rows) {
        my $book_hr = $c->forward('/book/list_book_summary', [$_]);
        push(@books, $book_hr);
    }
    $c->stash(
        template => "src/recommend.tt",
        catalogs => \@catalogs,
        subcats  => \@subcats,
        catalog  => $catalog,
        subcat   => $subcat,
        books    => \@books,
    );
}

=head1 AUTHOR

Zhongqiang Shen,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
