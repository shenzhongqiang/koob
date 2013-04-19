use strict;
use warnings;
use Test::More;


use Catalyst::Test 'FindBook';
use FindBook::Controller::ContactUs;

ok( request('/contactus')->is_success, 'Request should succeed' );
done_testing();
