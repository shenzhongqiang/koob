use strict;
use warnings;
use Test::More;


use Catalyst::Test 'FindBook';
use FindBook::Controller::User;

ok( request('/user')->is_success, 'Request should succeed' );
done_testing();
