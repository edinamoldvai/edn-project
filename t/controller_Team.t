use strict;
use warnings;
use Test::More;


use Catalyst::Test 'MyApp';
use MyApp::Controller::Team;

ok( request('/team')->is_success, 'Request should succeed' );
done_testing();
