use strict;
use warnings;
use Test::More;


use Catalyst::Test 'FindBook';
use FindBook::Controller::Url;

ok( request('/url')->is_success, 'Request should succeed' );
done_testing();
