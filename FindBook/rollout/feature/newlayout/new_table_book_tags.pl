#!/usr/bin/perl
#
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../../lib";
use FindBook::Schema;

my $schema = FindBook::Schema->connect(
    'dbi:mysql:findbook', 'findbook', '58862455'
);
my @book_rows = $schema->resultset("Book")->all;
foreach my $book_row (@book_rows) {
    my $bid = $book_row->id;
    my $tid = $book_row->tag_id;
    print "$bid,$tid\n";
    $schema->resultset("BookTag")->find_or_create({book_id => $bid, tag_id => $tid});
}
