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
use POSIX qw/strftime/;

my $TAG_FILE = dirname(__FILE__) . "/tag";
my $BLACK_PATH = dirname(__FILE__);
open(IN, "$BLACK_PATH/blacklist") or die "cannot open blacklist: $!\n";
my @blacklist = <IN>;
chomp(@blacklist);
close(IN);

my %blacklist = map { $_ => 1} @blacklist;

my $schema = FindBook::Schema->connect(
    'dbi:mysql:findbook', 'findbook', '58862455'
);

my $tag_id = get_start_tag_id();
my @tag_rows;
if($tag_id) {
    @tag_rows = $schema->resultset("Tag")->search({id => {'<=', $tag_id}}, {order_by => {-desc => 'id'}})->all;
}
else {
    @tag_rows = $schema->resultset("Tag")->search(undef, {order_by => {-desc => 'id'}})->all;
}
foreach my $tag_row (@tag_rows) {
    log_tag_id($tag_row->id);
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
        my $url = sprintf($url_pattern, $start);
        my $resp = Request::send_request($url);
        my $data_hr = from_json($resp);
        my $books_ar = $data_hr->{books};
        foreach my $item_hr (@$books_ar) {
            try {
                my $book_hr = DbBook::parse_resp($item_hr);
                my $isbn = $book_hr->{isbn};
                if($blacklist{$isbn}) {
                    InBlacklist->throw(error => "book $isbn is in blacklist");
                }
                my $book_row = $schema->resultset("Book")->find({isbn => $isbn});
                if(defined $book_row) {
                    print now(), " - $isbn already exists\n";
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
                        tag_id      => $tag_row->id,
                    });
                    $guard->commit;
                    print now(), " - created $isbn\n";
                }
            }
            catch {
                my $e = shift;
                print now(), " - $e\n";
            };
        }
        if($data_hr->{count} < $count) {
            last;
        }
        $start += $count;
    }
}

sub now {
    return strftime("%Y-%m-%d %H:%M:%S", localtime);
}

sub get_start_tag_id {
    if(-e $TAG_FILE) {
        open(IN, $TAG_FILE) or die "cannot open tag: $!\n";
        my @lines = <IN>;
        close(IN);
        my $tag_id = $lines[0];
        return $tag_id;
    }
    else {
        return 0;
    }
}

sub log_tag_id {
    my $tag_id = shift;
    open(OUT, "> $TAG_FILE") or die "canont open tag: $!\n";
    print OUT $tag_id;
    close(OUT);
}
