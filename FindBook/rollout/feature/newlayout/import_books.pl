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
    my $cat = $tag_row->catalog;
    my $subcat = $tag_row->subcat;
    print "importing $cat/$subcat ...\n";
    import_books($tag_row);
}


sub import_books {
    my $tag_row = shift;

    my $tag = $tag_row->subcat;
    my $start = 0;
    my $count = 100;
    my $url_pattern = "https://api.douban.com/v2/book/search?" . "tag=$tag&start=%s&count=$count";
    while(1) {
        $start += $count;
        my $url = sprintf($url_pattern, $start);
        my $resp = Request::send_request($url);
        my $data_hr = from_json($resp);
        my $books_ar = $data_hr->{books};
        foreach my $item_hr (@$books_ar) {
            try {
                my $book_hr = DbBook::parse_resp($item_hr);
                my $book_row = $schema->resultset("Book")->find({isbn => $book_hr->{isbn}});
                if(defined $book_row) {
                    print $book_hr->{isbn} . " already exists\n";
                    my $bt_row = $schema->resultset("BookTag")->find_or_create({book_id => $book_row->id, tag_id => $tag_row->id});
                }
                if(!defined $book_row) {
                    my $pic = basename($book_hr->{img_url});
                    my $guard = $schema->txn_scope_guard;
                    $book_row = $schema->resultset("Book")->create({
                        isbn        => $book_hr->{isbn},
                        title       => $book_hr->{title},
                        rating      => $book_hr->{rating},
                        author      => $book_hr->{author},
                        translator  => $book_hr->{translator},
                        publisher   => $book_hr->{publisher},
                        pubdate     => $book_hr->{pubdate},
                        pages       => $book_hr->{pages},
                        pic         => $pic,
                        description => $book_hr->{description},
                        author_intro=> $book_hr->{author_intro},
                    });
                    $schema->resultset("BookTag")->create({
                        book_id => $book_row->id,
                        tag_id  => $tag_row->id,
                    });
                    $guard->commit;
                    print "created ", $book_hr->{isbn}, "\n";
                }
            }
            catch {
                my $e = shift;
                print "$e\n";
            };
        }
        if($data_hr->{count} < $count) {
            last;
        }
    }
}
