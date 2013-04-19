use strict;
use warnings;
use Test::More;


use Catalyst::Test 'FindBook';
use FindBook::Controller::Feedback;

ok( request('/feedback')->is_success, 'Request should succeed' );
done_testing();
