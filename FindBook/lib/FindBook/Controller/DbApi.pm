package FindBook::Controller::DbApi;
use strict;
use warnings;
use Moose;
use namespace::autoclean;
use LWP::UserAgent;
use Exception;
use JSON;
use Encode;

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
    my $resp = $c->forward('send_request', [$url]);
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
    $c->stash(%book);
    $c->forward('View::JSON');
}

sub send_request :Private {
    my ( $self, $c ) = @_;
    my $url = $c->req->args->[0];

    my $ua = LWP::UserAgent->new;
    $ua->agent("Mozilla/5.0 (X11; Linux i686) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.79 Safari/535.11");
    $ua->timeout(10);
    $ua->env_proxy;
    
    for(my $i = 0; $i < 5; $i++) {
        my $resp = $ua->get($url);
        if($resp->is_success) {
            return $resp->decoded_content;
        }
    }

#    Exception::error_send_request($url);
    $c->error("error sending request to below url:\n$url\n");
}

=head1 AUTHOR

Zhongqiang Shen,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
