use strict;
use warnings;
use Test::More;


use Catalyst::Test 'MyApp';
use MyApp::Controller::Employee;

ok( request('/employee')->is_success, 'Request should succeed' );
done_testing();
