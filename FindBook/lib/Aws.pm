package Aws;
use strict;
use warnings;

use Request;
use Exception;
use POSIX qw/strftime/;
use Net::Amazon::AWSSign;

sub new {
    my $class = shift;
    my $base_url = "http://webservices.amazon.com/onca/xml";
    my ($host, $uri) = get_host_uri($base_url);
    my $key_id = "AKIAJX3ENKNWYCFUYPFA";
    my $key = "viB4SmNFEg0Xjxw0fG0LK6Gl9TODuWd0E57MlDBi";
    my $tag = "ifindbook-23";
    my $verb = 'GET';
    my $self = {
        _base_url => $base_url,
        _host => $host,
        _uri  => $uri,
        _key_id => $key_id,
        _key => $key,
        _tag => $tag,
        _verb => $verb,
    };
    bless $self, $class;
}

sub get_product_by_isbn {
    my $self = shift;
    my $isbn = shift;

    my $sign = Net::Amazon::AWSSign->new($self->{_key_id}, $self->{_key});
    my %param = (
        Service => "AWSECommerceService",
        Operation => "ItemLookup",
        ResponseGroup => "Large",
        SearchIndex => "All",
        IdType => "ISBN",
        ItemId => $isbn,
        AWSAccessKeyId => $self->{_key_id},
        AssociateTag => $self->{_tag},
        Timestamp => "2014-01-05T16:46:00Z",
    );
    my $query_string = $self->get_query_string(\%param);
    my $url = $self->{_base_url} . "?" . $query_string;
    my $aws_signed_uri = $sign->addRESTSecret($url);
    print "$aws_signed_uri\n\n";
    my $result = Request::send_request($aws_signed_uri);
}

sub get_query_string {
    my $self = shift;
    my $param_hr = shift;
    
    my @param;
    foreach my $key (keys %$param_hr) {
        my $value = $param_hr->{$key};
        push(@param, "$key=$value");
    }
    my $str = join("&", @param);
    return $str;
}

sub sign {
    my $self = shift;
    my $string = shift;

    my $digest = Digest::SHA::hmac_sha256_base64($string, $self->{_key});    
    return $digest;
}

sub get_string_to_sign {
    my $self = shift;
    my $param_hr = shift;
    
    my @sorted_param;
    foreach my $key (sort keys %$param_hr) {
        my $value = $param_hr->{$key};
        my $ec_key = URI::Escape::uri_escape($key);
        my $ec_value = URI::Escape::uri_escape($value);
        push(@sorted_param, "$ec_key=$ec_value");
    }
    my $str = join("&", @sorted_param);
    $str = $self->{_verb} . "\n" .
           lc($self->{_host}) . "\n" .
           $self->{_uri} . "\n" .
           $str;
    return $str;
}

sub get_host_uri {
    my $url = shift;
    
    if($url =~ /^http:\/\/([^\/]+)(\/.*$)/) {
        my $host = $1;
        my $uri = $2;
        return ($host, $uri);
    }
    NoHostFound->throw(error => "no host or uri found in url $url");
}


1;

package main;
   my $aws = Aws->new;
   my $string = $aws->get_product_by_isbn('9789814068116');
1;
