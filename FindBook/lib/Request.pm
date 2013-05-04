package Request;
use LWP::UserAgent;
use Exception;

sub send_request {
    my $url = shift;

    my $ua = LWP::UserAgent->new;
    $ua->agent("Mozilla/5.0 (X11; Linux i686) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.79 Safari/535.11");
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
1;
