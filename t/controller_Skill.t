use strict;
use warnings;
use Test::More;


use Catalyst::Test 'MyApp';
use MyApp::Controller::Skill;

ok( request('/skill')->is_success, 'Request should succeed' );
done_testing();
