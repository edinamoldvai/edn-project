use strict;
use warnings;
use Test::More;


use Catalyst::Test 'MyApp';
use MyApp::Controller::Department;

ok( request('/department')->is_success, 'Request should succeed' );
done_testing();
