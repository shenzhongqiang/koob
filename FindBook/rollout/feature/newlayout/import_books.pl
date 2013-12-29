#!/usr/bin/perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../../lib";
use FindBook::Schema;
use DbBook;
use JSON;
use File::Basename;
use Try::Tiny;

my $schema = FindBook::Schema->connect(
    'dbi:mysql:findbook', 'findbook', '58862455'
);

my @tag_rows = $schema->resultset("Tag")->all;
foreach my $tag_row (@tag_rows) {
    print "XXX:", $tag_row->subcat, "xxx\n";
}
