package FindBook::Controller::Recommend;
use Moose;
use namespace::autoclean;
use List::Util qw[min max];

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
    my $page_no = $c->req->params->{page_no} || 1;

    my @catalogs = $c->model('FindBookDB::Tag')->search(undef, {order_by => 'catalog', distinct => 'catalog'})->get_column('catalog')->all;
    my $book_count = $c->model('FindBookDB::Book')->count;
    my $pages = int(($book_count - 1) / 10) + 1;
    my $url = $c->uri_for_action("/recommend/index");
    
    my $labels_ar = get_page_labels($pages, $page_no);
    my @urls = map {$c->forward('make_link', [$url, $_]) } @$labels_ar;
    my $prev_page_no = $page_no <= 1 ? 0 : $page_no - 1;
    my $next_page_no = $page_no >= $pages ? 0 : $page_no + 1;
    my $prev_page_url = $c->forward('make_link', ['/recommend/index', $prev_page_no]);
    my $next_page_url = $c->forward('make_link', ['/recommend/index', $next_page_no]);
    my @book_rows = $c->model('FindBookDB::Book')->search(undef, {order_by => {-desc => 'rating'}, page => $page_no, rows => 10});
    my @books;
    foreach(@book_rows) {
        my $book_hr = $c->forward('/book/list_book_summary', [$_]);
        push(@books, $book_hr);
    }
    $c->stash(
        template      => "src/recommend.tt",
        catalogs      => \@catalogs,
        books         => \@books,
        page_no       => $page_no,
        prev_page_url => $prev_page_url,
        next_page_url => $next_page_url,
        page_urls     => \@urls,
    );
}

sub catalog :Local :Args(1) {
    my ( $self, $c ) = @_;
    my $catalog = $c->req->arguments->[0];
    my $page_no = $c->req->params->{page_no} || 1;

    my @catalogs = $c->model('FindBookDB::Tag')->search(undef, {order_by => 'catalog', distinct => 'catalog'})->get_column('catalog')->all;
    my @subcats = $c->model('FindBookDB::Tag')->search({catalog => $catalog}, {order_by => 'id'})->get_column('subcat')->all;
    my $book_count = $c->model('FindBookDB::BookTag')->search({'tag.catalog' => $catalog}, {join => 'tag'})->count;
    my $pages = int(($book_count - 1) / 10) + 1;
    my $url = $c->uri_for_action('recommend/catalog', $catalog);

    my $labels_ar = get_page_labels($pages, $page_no);
    my @urls = map {$c->forward('make_link', [$url, $_]) } @$labels_ar;
    my $prev_page_no = $page_no <= 1 ? 0 : $page_no - 1;
    my $next_page_no = $page_no >= $pages ? 0 : $page_no + 1;
    my $prev_page_url = $c->forward('make_link', [$url, $prev_page_no]);
    my $next_page_url = $c->forward('make_link', [$url, $next_page_no]);
    my @book_rows = $c->model('FindBookDB::Book')->search({'tag.catalog' => $catalog}, {
        join => {'book_tags' => 'tag'}, 
        order_by => {-desc => 'rating'}, 
        page => $page_no, 
        rows => 10,
    });
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
        pages    => $pages,
        page_no  => $page_no,
        prev_page_url => $prev_page_url,
        next_page_url => $next_page_url,
        page_urls     => \@urls,
    );
}

sub subcat :Local :Args(1) {
    my ( $self, $c ) = @_;
    my $subcat = $c->req->arguments->[0];
    my $page_no = $c->req->params->{page_no} || 1;

    my $book_count = $c->model('FindBookDB::Book')->search({'tag.subcat' => $subcat}, {join => {'book_tags' => 'tag'}})->count;
    my $pages = int(($book_count - 1) / 10) + 1;
    my $url = $c->uri_for_action('recommend/subcat', $subcat);

    my $labels_ar = get_page_labels($pages, $page_no);
    my @urls = map {$c->forward('make_link', [$url, $_]) } @$labels_ar;
    my $prev_page_no = $page_no <= 1 ? 0 : $page_no - 1;
    my $next_page_no = $page_no >= $pages ? 0 : $page_no + 1;
    my $prev_page_url = $c->forward('make_link', [$url, $prev_page_no]);
    my $next_page_url = $c->forward('make_link', [$url, $next_page_no]);

    my $tag_row = $c->model('FindBookDB::Tag')->find({subcat => $subcat});
    if(!defined $tag_row) {
        my $error = "没有找到\"$subcat\"相关的书单哦";
        $c->stash(error => $error, template => "src/error.tt");
        return;
    }
    my $catalog = $tag_row->catalog;
    my @catalogs = $c->model('FindBookDB::Tag')->search(undef, {order_by => 'catalog', distinct => 'catalog'})->get_column('catalog')->all;
    my @subcats = $c->model('FindBookDB::Tag')->search({catalog => $catalog}, {order_by => 'id'})->get_column('subcat')->all;
    my @book_rows = $c->model('FindBookDB::Book')->search({'tag.subcat' => $subcat}, {
        join => {'book_tags' => 'tag'},
        order_by => {-desc => 'rating'}, 
        page => $page_no, 
        rows => 10,
    });
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
        pages    => $pages,
        page_no  => $page_no,
        prev_page_url => $prev_page_url,
        next_page_url => $next_page_url,
        page_urls     => \@urls,
    );
}

sub make_link :Private {
    my ( $self, $c ) = @_;
    my $base_url = $c->req->args->[0];
    my $label = $c->req->args->[1];
    
    my $url_hr;
    if($label =~ /^\d+$/) {
        my $url = "$base_url?page_no=$label";
        $url_hr = {
            url => $url,
            label => $label,
        };
    }
    else {
        $url_hr = {
            url   => '',
            label => $label,
        };
    }
    return $url_hr;
}

sub get_page_labels {
    my $pages = shift;
    my $page_no = shift;
    
    my $link_count = 9;
    my @labels;
    my $start = max(1, $page_no - int($link_count / 2));
    my $end = min($start + $link_count - 1, $pages);
    $start = max(1, $end - $link_count + 1);
    
    if($start < 4) {
        foreach(1 .. $start - 1) {
            push(@labels, $_);
        }
    }
    else {
        push(@labels, 1);
        push(@labels, "...");
    }

    foreach($start .. $end) {
        push(@labels, $_);
    }

    if($pages < $end + 3) {
        foreach($end + 1 .. $pages) {
            push(@labels, $_);
        }
    }
    else {
        push(@labels, "...");
        push(@labels, $pages);
    }
    return \@labels;
}



=head1 AUTHOR

Zhongqiang Shen,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
