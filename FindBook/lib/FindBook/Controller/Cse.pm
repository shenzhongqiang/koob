package FindBook::Controller::Cse;
use strict;
use warnings;
use Moose;
use LWP::UserAgent;
use Try::Tiny;
use JSON;
use namespace::autoclean;
use Request;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

FindBook::Controller::Cse - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched FindBook::Controller::Cse in Cse.');
}


sub get_search_result :Private {
    my ( $self, $c ) = @_;
    my $q = $c->req->args->[0];
    my $page_no = $c->req->args->[1],
    my $num = $c->req->args->[2];
    
    my $url = build_url($q, $page_no, $num);
    my $resp;
    try {
        $resp = Request::send_request($url);
    }
    catch {
        $url = build_url($q, 10, $num);
        $resp = Request::send_request($url);
    };

    my $result_hr = $c->forward('parse_result', [$resp, $q, $page_no]);
    return $result_hr;
}


sub parse_result :Private {
    my ( $self, $c ) = @_;
    my $resp = $c->req->args->[0];
    my $q = $c->req->args->[1];
    my $page_no = $c->req->args->[2];

    my $r_data = JSON->new->decode($resp);
    my $cursor_hr = $r_data->{cursor};
    my $pages_ar = $cursor_hr->{pages};
    my $results_ar = $r_data->{results};
    
    my @page_items;
    my @result_items;

    foreach(@$pages_ar) {
        my $label = $_->{label};
        my $page_url = $c->forward('build_page_url', [$q, $label]);
        push(@page_items, {
            label   => $label,
            url     => $page_url,
        });
    }
    
    foreach(@$results_ar) {
        my $track_url = $c->uri_for_action('/url/index', {q => $_->{url}});
        push(@result_items, {
            adkey   => $_->{richSnippet}->{metatags}->{adkey},
            content => $_->{content},
            visibleUrl => $_->{visibleUrl},
            contentNoFormatting => $_->{contentNoFormatting},
            clicktrackUrl => $track_url,
            formattedUrl  => $_->{formattedUrl},
            titleNoFormatting => $_->{titleNoFormatting},
            url     => $_->{url},
            title   => $_->{title},
            unescapedUrl => $_->{unescapedUrl},
        });
    }

    return {
        results => \@result_items,
        pages   => \@page_items,
    };
}


sub build_url {
    my $q = shift;
    my $page_no = shift;
    my $num = shift;

    my $base_url = "https://www.googleapis.com/customsearch/v1element?";
    my $cse_q = "$q intitle:$q";
    my $start = ($page_no - 1) * $num;
    my $param_hr = {
        key => "AIzaSyCVAXiUzRYsML1Pv6RwSG1gunmMikTzQqY",
        rsz => "large",
        hl  => "zh_CN",
        prettyPrint => "false",
        source      => "gcsc",
        gss         => ".com",
        cx          => "002907856746208406361:sfefsn3mj8e",
        sort        => "",
        googlehost  => "www.google.com",
        q           => $cse_q,
        oq          => $cse_q,
        start       => $start, 
        num         => $num,
    };
    
    my @params = map { $_ . "=" . $param_hr->{$_} } keys %$param_hr;
    my $param_s = join("&", @params);

    my $req_url = $base_url . $param_s;
    return $req_url;
}


sub build_page_url :Private {
    my ( $self, $c ) = @_;
    my $q = $c->req->args->[0];
    my $page_no = $c->req->args->[1];

    my $url = $c->uri_for_action("/search/index", {q => $q, page_no => $page_no});
    return $url;
}

=head1 AUTHOR

Zhongqiang Shen,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
