use strict;
use warnings;
use Test::More;


use Catalyst::Test 'FindBook';
use FindBook::Controller::Cse;

ok( request('/cse')->is_success, 'Request should succeed' );
done_testing();
