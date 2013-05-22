use strict;
use warnings;
use Test::More;


use Catalyst::Test 'FindBook';
use FindBook::Controller::Recommend;

ok( request('/recommend')->is_success, 'Request should succeed' );
done_testing();
