#!/usr/bin/perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Request;
use File::Basename;


my $path = get_sitemap_path();
my $url = "http://www.ifindbook.net/sitemap";
Request::download_file($url, $path);

sub get_sitemap_path {
    my $file = __FILE__;
    my $dir = dirname($file);
    my $sitemap_path = "$dir/../root/sitemap.xml";
    return $sitemap_path;
}
