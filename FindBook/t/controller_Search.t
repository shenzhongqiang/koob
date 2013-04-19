use strict;
use warnings;
use Test::More;


use Catalyst::Test 'FindBook';
use FindBook::Controller::Search;

ok( request('/search')->is_success, 'Request should succeed' );
done_testing();
