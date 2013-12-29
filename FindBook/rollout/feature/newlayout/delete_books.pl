#!/usr/bin/perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../../lib";
use FindBook::Schema;
use File::Basename;

my $schema = FindBook::Schema->connect(
    'dbi:mysql:findbook', 'findbook', '58862455'
);

my @book_rows = $schema->resultset("Book")->all;
foreach my $book_row (@book_rows) {
    my $pic = $book_row->pic;
    my $desc = $book_row->description;
    my $isbn = $book_row->isbn;
    my $dir = dirname(__FILE__);
    my $path = "$dir/../../../root/static/pics/$pic";
    my $sum = `md5sum $path | cut -f1 -d ' '`;
    chomp($sum);
    if($sum eq "634c5cb7b200c21bff123c9c124d528d" || $desc eq "") {
        # delete file
        if(-e $path) {
            unlink($path) or warn "cannot delete file $path: $!\n";
        }
        # delete rows in DB
        my $guard = $schema->txn_scope_guard;
        $book_row->book_tags->delete;
        $book_row->delete;
        $guard->commit;
        print "deleted $isbn\n";
    }
}
