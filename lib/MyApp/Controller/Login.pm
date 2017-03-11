package MyApp::Controller::Login;
use Moose;
use namespace::autoclean;

use Catalyst qw/
    Authentication
    Session
    Session::Store::File
    Session::State::Cookie
/;
BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

MyApp::Controller::Login - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

# sub index :Path :Args(0) {
#     my ( $self, $c ) = @_;

#     $c->response->body('Matched MyApp::Controller::Login in Login.');
# }

=head2 index

Login logic

=cut

sub index :Path :Args(0) {
    my ($self, $c) = @_;

    # Get the username and password from form
    my $username = $c->request->params->{email};
    my $password = $c->request->params->{password};

    # If the username and password values were found in form
    if ($username && $password) {
        # Attempt to log the user in
        if ($c->authenticate({ email => $username,
                               password => $password  } )) {
            # If successful, then let them use the application
            $c->response->redirect($c->uri_for(
                $c->controller('Root')->action_for('index')));
            return;
        } else {
            # Set an error message
            $c->stash(error_msg => "Wrong username or password.");
        }
    } else {
        # Set an error message
        # $c->stash(error_msg => "Empty username or password.")
        #     unless ($c->user_exists);
    }

    # If either of above don't work out, send to the login page
    $c->stash(template => 'login.tt2');
}



sub signup :Path('/signup') :Args(0) {
    my ($self, $c) = @_;

    my $params = $c->req->params();

    my $user_already_exists = $c->model("DB::User")->search({
        email => $params->{email}
        })->first();

    my $password_confirmed = $params->{password} eq $params->{password_confirm} ? 1 : 0;

    my $user;
    if ( !$user_already_exists && $password_confirmed ) {
        eval {
            $user = $c->model("DB::User")->create({
            email => $params->{email},
            display_name => $params->{username},
            password => $params->{password}
            });
            } or do {
                 $c->stash(error_msg => "There was an error while creating the user, please data and try again.");
            };
            if ($user) {
                if ( $c->authenticate({
                    email => $user->email,
                    password => $user->password
                    }) ) {
                    # If successful, then let them use the application
                    $c->response->redirect($c->uri_for(
                        $c->controller('Root')->action_for('index')));
                    return;
                } else {
                    # Set an error message
                    $c->stash(error_msg => "The user couldn't log in, please try again later.");
                }
            }
            
    } 
    # If successful, then let them use the application
    $c->stash(template => 'signup.tt2');

}

=encoding utf8

=head1 AUTHOR

ubuntu,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
