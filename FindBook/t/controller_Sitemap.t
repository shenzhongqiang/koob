use strict;
use warnings;
use Test::More;


use Catalyst::Test 'FindBook';
use FindBook::Controller::Sitemap;

ok( request('/sitemap')->is_success, 'Request should succeed' );
done_testing();
