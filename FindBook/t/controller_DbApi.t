use strict;
use warnings;
use Test::More;


use Catalyst::Test 'FindBook';
use FindBook::Controller::DbApi;

ok( request('/dbapi')->is_success, 'Request should succeed' );
done_testing();
