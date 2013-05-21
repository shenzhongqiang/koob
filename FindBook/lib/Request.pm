package Request;
use LWP::UserAgent;
use Exception;

sub send_request {
    my $url = shift;

    my $ua = LWP::UserAgent->new;
    $ua->agent("Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.63 Safari/537.31");
    $ua->timeout(10);
    $ua->env_proxy;
    
    for(my $i = 0; $i < 5; $i++) {
        my $resp = $ua->get($url);
        if($resp->is_success) {
            return $resp->decoded_content;
        }
    }

    RequestError->throw(url => $url, error => "error sending request to below url:\n$url\n");
}

sub download_file {
    my $url = shift;
    my $local_path = shift;

    my $ua = LWP::UserAgent->new;
    $ua->agent("Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.63 Safari/537.31");
    $ua->timeout(10);
    $ua->env_proxy;
    
    for(my $i = 0; $i < 5; $i++) {
        my $resp = $ua->get($url, ":content_file" => $local_path);
        if($resp->is_success) {
            return;
        }
    }

    RequestError->throw(url => $url, error => "error downloading from url:\n$url\n");
}
1;
