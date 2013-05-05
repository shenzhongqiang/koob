package FindBook::Controller::Search;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

FindBook::Controller::Search - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(2) {
    my ( $self, $c ) = @_;
    my $q = $c->req->params->{q};
    my $page_no = $c->req->params->{page_no};
    my $result_hr = $c->forward('/cse/get_search_result', [$q, $page_no, 10]);
    my $pages_ar = $result_hr->{pages};
    my $results_ar = $result_hr->{results};
    
    if($q ne "dnspod") {
        $c->model('FindBookDB::Keyword')->create({
            query   => $q,
        });
    }

    $c->stash(
        template => "src/search.tt", 
        page_no  => $page_no,
        q        => $q,
        pages    => $pages_ar,
        results  => $results_ar,
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
