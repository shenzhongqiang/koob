#!/usr/bin/perl

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
    my @bt_rows = $book_row->book_tags;
    if(!@bt_rows) {
        $book_row->delete;
        next;
    }
    my $bt_row = $bt_rows[0];
    $book_row->update({tag_id => $bt_row->tag_id});
}

