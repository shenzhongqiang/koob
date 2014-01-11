package DbBook;
use strict;
use warnings;
use File::Basename;
use Encode;
use Request;
use Exception;
use JSON;

sub new {
    my $class = shift;
    my $db_base = 'https://api.douban.com/v2/book';
    
    my $self = {
        db_base => $db_base,
    };

    bless $self, $class;
}

# params 
#   isbn - isbn of the book
# return
#   hashref
sub get_book {
    my $self = shift;
    my $isbn = shift;

    my $url = $self->{db_base} . "/isbn/" . $isbn;
    my $resp = Request::send_request($url);
    my $data_hr = from_json($resp);

    return parse_resp($data_hr);
}


sub parse_resp {
    my $data_hr = shift;

    my %book;
    my $pic = "";
    my $isbn = $data_hr->{isbn13};
    if(!defined $isbn) {
        IsbnNotExists->throw(error => "the book does not have a ISBN number");
    }
    if($data_hr->{summary} eq "") {
        NoDescription->throw(error => "the book $isbn does not have a description");
    }

    $book{isbn} = $isbn;
    if(defined $data_hr->{rating}) {
        $book{rating} = $data_hr->{rating}->{average} || 0.0;
        if($data_hr->{rating}->{numRaters} < 100) {
            $book{rating} = 0.0;
        }
    }
    if(defined $data_hr->{image}) {
        my $img_url = $data_hr->{image};
        my $ext = get_file_ext($img_url);
        $pic = get_pic_path($isbn, $ext);
        unless(-e $pic) {
            Request::download_file($img_url, $pic);
            if(!check_md5sum($pic)) {
                NoValidPic->throw(error => "the book $isbn does not have a valid cover picture");
            }
        }
        $book{img_url} = "/static/pics/$isbn.$ext";
    }
    if(defined $data_hr->{pubdate}) {
        $book{pubdate} = $data_hr->{pubdate};
    }
    if(defined $data_hr->{title}) {
        $book{title} = $data_hr->{title};
    }
    if(defined $data_hr->{author_intro}) {
        $book{author_intro} = $data_hr->{author_intro};
    }
    my $translator_ar = $data_hr->{translator};
    if(defined $translator_ar) {
        $book{translator} = join(",", @$translator_ar);
    }
    if(defined $data_hr->{pages}) {
        $book{pages} = $data_hr->{pages};
    }
    if(defined $data_hr->{publisher}) {
        $book{publisher} = $data_hr->{publisher};
    }
    my $author_ar = $data_hr->{author};
    if(defined $author_ar) {
        $book{author} = join(",", @$author_ar);
    }
    $book{description} = $data_hr->{summary};
    if(! ($book{description} =~ /\*{2}/)) {
        $book{description} =~ s/\*/\n\*/g;
    }
    
    foreach(keys %book) {
        my $key = $_;
        my $val = $book{$key};
        $book{$key} = decode("utf-8", $val);
    }
    return \%book;
}


sub get_file_ext {
    my $img_url = shift;

    my @array = split /\./, $img_url;
    my $ext = pop @array;
    return $ext;
}


sub get_pic_path {
    my $isbn = shift;
    my $ext = shift;

    my $file = __FILE__;
    my $dir = dirname($file);
    my $pic_dir = "$dir/../root/static/pics/";
    my $pic_path = $pic_dir . "$isbn.$ext";
    return $pic_path;
}

sub check_md5sum {
    my $pic_path = shift;

    my $sum = `md5sum $pic_path | cut -f1 -d ' '`;
    chomp($sum);
    if($sum eq "634c5cb7b200c21bff123c9c124d528d") {
        unlink($pic_path) or die "cannot delete file $pic_path: $!\n";
        return 0;
    }
    return 1;
}
1;
