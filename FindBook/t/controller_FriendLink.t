use strict;
use warnings;
use Test::More;


use Catalyst::Test 'FindBook';
use FindBook::Controller::FriendLink;

ok( request('/friendlink')->is_success, 'Request should succeed' );
done_testing();
