package FindBook::Controller::Book;
use Moose;
use namespace::autoclean;
use JSON;
use Encode;
use Exception;
use POSIX qw/floor/;

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
    my $num = $c->req->params->{num} || 100;

    if(!$c->user_exists) {
        my $book_url = $c->uri_for_action("/book/index");
        my $cb_url = $c->uri_for_action("/user/login", {callback => $book_url});
        $c->res->redirect($cb_url);
        return;
    }

    my @tag_rows = $c->model('FindBookDB::Tag')->all;
    my %tags;
    foreach my $row (@tag_rows) {
        my $catalog = $row->catalog;
        my $subcat = $row->subcat;
        if(!defined $tags{$catalog}) {
            my @subcats = ($subcat);
            $tags{$catalog} = \@subcats;
        }
        else {
            my $subcat_ar = $tags{$catalog};
            push(@$subcat_ar, $subcat);
        }
    }

    my $json_tags = JSON->new->encode(\%tags);

    my @book_rows = $c->model('FindBookDB::Book')->search(undef, {order_by => {-desc => 'id'}, rows => $num})->all;
    my @all_books;
    foreach my $row (@book_rows) {
        my $book_hr = $c->forward('list_book_summary', [$row]);
        push(@all_books, $book_hr);
    }
    $c->stash(
        tags      => $json_tags,
        all_books => \@all_books,
        template  => "src/book.tt",
    );
}

sub list :Local :Args(1) {
    my ( $self, $c ) = @_;
    my $isbn = $c->req->arguments->[0];
    
    my $book_row = $c->model('FindBookDB::Book')->find({isbn => $isbn});
    if(!defined $book_row) {
        my $error = "没有找到这本书哦";
        $c->stash(error => $error, template => "src/error.tt");
        return;
    }
    my $book_hr = $c->forward('list_book', [$book_row]);
    $c->stash(book => $book_hr);
    $c->stash(template => "src/book_list.tt");
}

sub add :Local :Args(0) {
    my ( $self, $c ) = @_;
    
    if(!$c->user_exists) {
        my $book_url = $c->uri_for_action("/book/index");
        my $cb_url = $c->uri_for_action("/user/login", {callback => $book_url});
        $c->res->redirect($cb_url);
        return;
    }

    my $catalog = $c->req->params->{catalog};
    my $subcat = $c->req->params->{subcat};
    my $isbn = $c->req->params->{isbn};
    my $title = $c->req->params->{title};
    my $rating = $c->req->params->{rating};
    my $author = $c->req->params->{author};
    my $translator = $c->req->params->{translator};
    my $publisher = $c->req->params->{publisher};
    my $pubdate = $c->req->params->{pubdate};
    my $pages = $c->req->params->{pages};
    my $pic = $c->req->params->{pic};
    my $desc = $c->req->params->{description};
    my $author_intro = $c->req->params->{author_intro};
    
    my $tag_row = $c->model('FindBookDB::Tag')->find({catalog => $catalog, subcat => $subcat});
    my $book_row = $c->model('FindBookDB::Book')->find({isbn => $isbn});
    if(defined $book_row) {
        $c->session->{error} = "Book $isbn already exists";
        $c->res->redirect('/error');
        return;
    }

    $book_row = $c->model('FindBookDB::Book')->create({
        isbn        => $isbn,
        title       => $title,
        rating      => $rating,
        author      => $author,
        translator  => $translator,
        publisher   => $publisher,
        pubdate     => $pubdate,
        pages       => $pages,
        pic         => $pic,
        description => $desc,
        author_intro=> $author_intro,
    });
    $c->model('FindBookDB::BookTag')->create({
        book_id => $book_row->id,
        tag_id  => $tag_row->id,
    });
    
    $c->res->redirect('/book');
}

sub del :Local :Args(1) {
    my ( $self, $c ) = @_;
    
    if(!$c->user_exists) {
        my $book_url = $c->uri_for_action("/book/index");
        my $cb_url = $c->uri_for_action("/user/login", {callback => $book_url});
        $c->res->redirect($cb_url);
        return;
    }

    my $isbn = $c->req->arguments->[0];
    
    $c->model('FindBookDB::BookTag')->search({
        'book.isbn' => $isbn,
    },
    {
        join => 'book',
    })->delete;
    $c->model('FindBookDB::Book')->find({
        isbn => $isbn,
    })->delete;
    my $index_url = $c->uri_for_action('/book/index');
    $c->res->redirect('/book');
}

sub list_book :Private {
    my ( $self, $c ) = @_;
    my $book_row = $c->req->args->[0];
    
    my $tag_row = $book_row->tags->first;
    my $rating = $book_row->rating || 0;
    $rating = rating_as_string($rating);
    my @desc_para = split /\n/, $book_row->description;
    my @auth_para = split /\n/, $book_row->author_intro;
    my $summary = get_desc_summary($book_row->description);
    return {
        id      => $book_row->id,
        catalog => $tag_row->catalog,
        subcat  => $tag_row->subcat,
        isbn    => $book_row->isbn,
        title   => $book_row->title,
        rating  => $rating,
        author  => $book_row->author,
        translator => $book_row->translator,
        publisher  => $book_row->publisher,
        pubdate    => $book_row->pubdate,
        pages      => $book_row->pages,
        pic        => $book_row->pic,
        summary     => $summary,
        description => \@desc_para,
        author_intro=> \@auth_para,
    };
}

sub list_book_summary :Private {
    my ( $self, $c ) = @_;
    my $book_row = $c->req->args->[0];
    
    my $summary = get_desc_summary($book_row->description);
    my @producer;
    if(defined $book_row->author && $book_row->author) {
        push(@producer, $book_row->author);
    }
    if(defined $book_row->translator && $book_row->translator) {
        push(@producer, $book_row->translator);
    }
    if(defined $book_row->publisher && $book_row->publisher) {
        push(@producer, $book_row->publisher);
    }
    if(defined $book_row->pubdate && $book_row->pubdate) {
        push(@producer, $book_row->pubdate);
    }
    
    my $rating = $book_row->rating || 0;
    $rating = rating_as_string($rating);
    my $producer = join(" / ", @producer);
    my $tag_row = $book_row->tags->first;
    return {
        id      => $book_row->id,
        catalog => $tag_row->catalog,
        subcat  => $tag_row->subcat,
        title   => $book_row->title,
        producer => $producer,
        rating  => $rating,
        pic     => $book_row->pic,
        isbn    => $book_row->isbn,
        summary => $summary,
    };
}

sub get_desc_summary {
    my $desc = shift;
    
    my $str = decode("utf-8", $desc);
    my $len_short = length($str);
    my $len_long = length($desc);
    my $summary;
    if($len_short > 0 && $len_long / $len_short > 1.5) {
        $summary = encode("utf-8", substr($str, 0, 122));
    }
    else {
        $summary = encode("utf-8", substr($str, 0, 244));
    }
    
    return $summary;
}

sub rating_as_string {
    my $float = shift;

    $float = $float / 2;
    my $norm = floor($float * 2) * 5;
    my $str = sprintf("%02d", $norm);
    return $str;
}

=head1 AUTHOR

Zhongqiang Shen,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
