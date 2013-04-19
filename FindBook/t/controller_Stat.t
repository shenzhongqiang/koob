use strict;
use warnings;
use Test::More;


use Catalyst::Test 'FindBook';
use FindBook::Controller::Stat;

ok( request('/stat')->is_success, 'Request should succeed' );
done_testing();
