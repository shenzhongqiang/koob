package FindBook::Controller::DbApi;
use strict;
use warnings;
use Moose;
use namespace::autoclean;
use JSON;
use Encode;
use Try::Tiny;
use Request;

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

    my $url = "https://api.douban.com/v2/book/isbn/$isbn";
    my $resp;
    try {
        $resp = Request::send_request($url);

        my $data_hr = JSON->new->decode($resp);
        my %book;
        $book{isbn} = $isbn;
        $book{rating} = $data_hr->{rating}->{average} || 0.0;
        $book{img_url} = $data_hr->{image};
        $book{pubdate} = $data_hr->{pubdate} || "";
        $book{title} = $data_hr->{title};
        $book{author_intro} = $data_hr->{author_intro} || "";
        my $translator_ar = $data_hr->{translator};
        if(defined $translator_ar) {
            $book{translator} = join(",", @$translator_ar);
        }
        if(defined $data_hr->{pages}) {
            $book{pages} = $data_hr->{pages};
        }
        $book{publisher} = $data_hr->{publisher} || "";
        my $author_ar = $data_hr->{author};
        if(defined $author_ar) {
            $book{author} = join(",", @$author_ar);
        }
        $book{description} = $data_hr->{summary};
        
        foreach(keys %book) {
            my $key = $_;
            my $val = $book{$key};
            $book{$key} = decode("utf-8", $val);
        }
        $c->stash(
            success => 1, 
            msg     => "", 
            book    => \%book
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
