package Exception;

sub error_send_request {
    my $url = shift;
    die "error occurred when requesting $url\n";
}

1;
