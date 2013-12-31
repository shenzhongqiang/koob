#!/usr/bin/perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use FindBook::Schema;
use Request;
use File::Basename;
use Template;

my $INDEX_URL = "http://www.ifindbook.net";
my $ROOT_DIR = dirname(__FILE__) . "/../root/";
my $DATE = today();

my $tt = Template->new({
    INCLUDE_PATH => $ROOT_DIR, 
    OUTPUT_PATH => $ROOT_DIR
}) || die "template error: $!\n";
my $urls_ar = get_all_urls();
my $split_hr = split_urls($urls_ar);
my @sitemaps;
foreach (keys %$split_hr) {
    my $array_i = $_;
    my $urls_ar = $split_hr->{$array_i};
    my $filename = "sitemap$array_i\.xml";
    my $filepath = $ROOT_DIR . $filename;
    $tt->process('src/sitemap.tt', {urls => $urls_ar}, $filename);
    push(@sitemaps, {
        loc => $INDEX_URL . "/" . $filename,
        lastmod => $DATE,
    });
}

generate_sitemap_index(\@sitemaps);


sub generate_sitemap_index {
    my $sitemaps_ar = shift;
    $tt->process('src/sitemap_index.tt', {sitemaps => $sitemaps_ar}, 'sitemap.xml');
}


sub get_all_urls {
    my $rec_url = $INDEX_URL . "/recommend";
    my $schema = FindBook::Schema->connect(
        'dbi:mysql:findbook', 'findbook', '58862455'
    );

    my @book_rows = $schema->resultset('Book')->all;
    my @cats = $schema->resultset('Tag')->search(undef, {distinct => 'catalog'})->get_column('catalog')->all;
    my @subcats = $schema->resultset('Tag')->search(undef, {distinct => 'subcat'})->get_column('subcat')->all;
    
    my @urls;
    push(@urls, {
        loc     => $INDEX_URL,
        lastmod => $DATE,
        changefreq => 'weekly',
        priority => 1.0,
    });
    
    push(@urls, {
        loc     => $rec_url,
        lastmod => $DATE,
        changefreq => 'daily',
        priority => 0.9,
    });
    
    foreach(@cats) {
        my $cat_url = $rec_url . "/catalog/" . $_;
        push(@urls, {
            loc     => $cat_url,
            lastmod => $DATE,
            changefreq => 'daily',
            priority => 0.8,
        });
    }
   
    foreach(@subcats) {
        my $subcat_url = $rec_url . "/subcat/" . $_;
        push(@urls, {
            loc     => $subcat_url,
            lastmod => $DATE,
            changefreq => 'daily',
            priority => 0.7,
        });
    }
   
    foreach(@book_rows) {
        my $book_url = $INDEX_URL . "/book/list/" . $_->isbn;
        my $pic_url = $INDEX_URL . "/static/pics/" . $_->pic;
        push(@urls, {
            loc     => $book_url,
            lastmod => $DATE,
            changefreq => 'weekly',
            priority => 0.6,
            pic_url  => $pic_url,
        });
    }

    return \@urls;
}


sub today {
    my (undef, undef, undef, $mday, $mon, $year) = localtime(time);
    $year = $year + 1900;
    $mon = $mon + 1;
    my $date = sprintf("%d-%02d-%02d", $year, $mon, $mday);
    return $date;
}


sub split_urls {
    my $urls_ar = shift;

    my %sitemap;
    my $url_i = 0;
    my $array_i = 0;
    foreach my $url (@$urls_ar) {
        if($url_i % 50000 == 0) {
            $array_i++;
            $sitemap{$array_i} = [];
        }
        push(@{$sitemap{$array_i}}, $url);
        $url_i++;
    }
    return \%sitemap;
}
