use strict;
use warnings;
use Test::More;


use Catalyst::Test 'FindBook';
use FindBook::Controller::AboutUs;

ok( request('/aboutus')->is_success, 'Request should succeed' );
done_testing();
