package FindBook::Controller::Feedback;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

FindBook::Controller::Feedback - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
#    my $content = $c->req->params->{content};
#    my $contact = $c->req->params->{contact};
#    
#    $c->model("FindbookDB::Feedback")->create({
#        content => $content,
#        contact => $contact,
#    });
    $c->stash(template => "src/feedback.tt");
}


sub add :Local {
    my ( $self, $c ) = @_;
    my $params_hr = $c->req->params;
    
    my %result = (success => 1, msg => "");
    $params_hr->{source_ip} = $c->req->address;
    $c->model("FindbookDB::Feedback")->create($params_hr);
    $c->stash(%result);
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
