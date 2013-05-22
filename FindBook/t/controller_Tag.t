use strict;
use warnings;
use Test::More;


use Catalyst::Test 'FindBook';
use FindBook::Controller::Tag;

ok( request('/tag')->is_success, 'Request should succeed' );
done_testing();
