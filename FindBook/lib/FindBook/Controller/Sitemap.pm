package FindBook::Controller::Sitemap;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

FindBook::Controller::Sitemap - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my $index_url = $c->uri_for_action("/index");
    my $rec_url = $c->uri_for_action("/recommend/index");
    my $date = today();
    my @book_rows = $c->model('FindBookDB::Book')->all;
    my @cats = $c->model('FindBookDB::Tag')->search(undef, {distinct => 'catalog'})->get_column('catalog')->all;
    my @subcats = $c->model('FindBookDB::Tag')->search(undef, {distinct => 'subcat'})->get_column('subcat')->all;
    
    my @urls;
    push(@urls, {
        loc     => $index_url,
        lastmod => $date,
        changefreq => 'weekly',
        priority => 1.0,
    });
    
    push(@urls, {
        loc     => $rec_url,
        lastmod => $date,
        changefreq => 'daily',
        priority => 0.9,
    });
    
    foreach(@cats) {
        my $cat_url = $c->uri_for_action("/recommend/catalog", $_);
        push(@urls, {
            loc     => $cat_url,
            lastmod => $date,
            changefreq => 'daily',
            priority => 0.8,
        });
    }
   
    foreach(@subcats) {
        my $subcat_url = $c->uri_for_action("/recommend/subcat", $_);
        push(@urls, {
            loc     => $subcat_url,
            lastmod => $date,
            changefreq => 'daily',
            priority => 0.7,
        });
    }
   
    foreach(@book_rows) {
        my $book_url = $c->uri_for_action("/book/list", $_->isbn);
        my $pic_url = $index_url . "static/pics/" . $_->pic;
        push(@urls, {
            loc     => $book_url,
            lastmod => $date,
            changefreq => 'weekly',
            priority => 0.6,
            pic_url  => $pic_url,
        });
    }
    
    $c->res->content_type('text/xml');
    $c->stash(template => 'src/sitemap.tt', urls => \@urls);
}


sub so :Local :Args(0) {
    my ( $self, $c ) = @_;

    my $index_url = $c->uri_for_action("/index");
    my $rec_url = $c->uri_for_action("/recommend/index");
    my $date = today();
    my @book_rows = $c->model('FindBookDB::Book')->all;
    my @cats = $c->model('FindBookDB::Tag')->search(undef, {distinct => 'catalog'})->get_column('catalog')->all;
    my @subcats = $c->model('FindBookDB::Tag')->search(undef, {distinct => 'subcat'})->get_column('subcat')->all;
    
    my @urls;
    push(@urls, {
        loc     => $index_url,
        lastmod => $date,
        changefreq => 'weekly',
        priority => 1.0,
    });
    
    push(@urls, {
        loc     => $rec_url,
        lastmod => $date,
        changefreq => 'daily',
        priority => 0.9,
    });
   
    foreach(@cats) {
        my $cat_url = $c->uri_for_action("/recommend/catalog", $_);
        push(@urls, {
            loc     => $cat_url,
            lastmod => $date,
            changefreq => 'daily',
            priority => 0.8,
        });
    }
   
    foreach(@subcats) {
        my $subcat_url = $c->uri_for_action("/recommend/subcat", $_);
        push(@urls, {
            loc     => $subcat_url,
            lastmod => $date,
            changefreq => 'daily',
            priority => 0.7,
        });
    }
   
    foreach(@book_rows) {
        my $book_url = $c->uri_for_action("/book/list", $_->isbn);
        push(@urls, {
            loc     => $book_url,
            lastmod => $date,
            changefreq => 'weekly',
            priority => 0.6,
        });
    }
    
    $c->res->content_type('text/plain');
    $c->stash(template => 'src/sitemap_so.tt', urls => \@urls);
}


sub today {
    my (undef, undef, undef, $mday, $mon, $year) = localtime(time);
    $year = $year + 1900;
    $mon = $mon + 1;
    my $date = sprintf("%d-%02d-%02d", $year, $mon, $mday);
    return $date;
}

=head1 AUTHOR

Zhongqiang Shen,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
