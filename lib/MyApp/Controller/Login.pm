package MyApp::Controller::Login;
use Moose;
use namespace::autoclean;

use Catalyst qw/
    Authentication
    Session
    Session::Store::File
    Session::State::Cookie
/;
use Email::Valid;
use Crypt::PBKDF2;
use Data::Password::Check;
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

    # # Get the username and password from form
    # my $username = $c->request->params->{email};
    # my $password = $c->request->params->{password};

    # # If the username and password values were found in form
    # if ($username && $password) {
    #     # Attempt to log the user in
    #     if ($c->authenticate({ email => $username,
    #                            password => $password  } )) {
    #         # If successful, then let them use the application
    #         $c->response->redirect($c->uri_for(
    #             $c->controller('Root')->action_for('index')));
    #         return;
    #     } else {
    #         # Set an error message
    #         $c->stash(error_msg => "Wrong username or password.");
    #     }
    # } else {
    #     # Set an error message
    #     # $c->stash(error_msg => "Empty username or password.")
    #     #     unless ($c->user_exists);
    # }

    # If either of above don't work out, send to the login page
    $c->stash(template => 'login.tt2');
}

sub login :Path('/login_user') :Args(0) {
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
    } 
}

sub signup :Path('/signup') :Args(0) {
    my ($self, $c) = @_;

    my $params = $c->req->params();

    # validate all params
    unless ($params->{username} && $params->{email} && $params->{password} && $params->{password_confirm}) {
        $c->stash(error_msg => "All the fields are mandatory!");
        $c->stash(form_data => $params);
        $c->stash(template => 'login.tt2');
    }

    # validate email address 
    my $valid_email = Email::Valid->address(
        -address => $params->{email},
        -mxcheck => 1 );
    unless ($valid_email) {
        $c->stash(error_msg => "The email is not valid!");
        $c->stash(form_data => $params);
        $c->stash(template => 'login.tt2');
        return;
    }

    # validate password confirm
    my $password_confirmed = $params->{password} eq $params->{password_confirm} ? 1 : 0;
    unless ($password_confirmed) {
        $c->stash(error_msg => "The passwords don't match." );
        $c->stash(form_data => $params);
        $c->stash(template => 'login.tt2');
        return;
    }

    # validate password rules
    my $password_verified = Data::Password::Check->check({'password' => $params->{password},
        'silly_words_append' => [ 'more', 'silly', 'words', 'admin', 'Admin123' ],
        });
    if ($password_verified->has_errors()) {
        my $errors = $password_verified->error_list();
        my $errors_string = join('. ', @{$errors});
        $c->stash(error_msg => $errors_string );
        $c->stash(form_data => $params);
        $c->stash(template => 'login.tt2');
        return;
    }

    # create hashed password
    my $pbkdf2 = Crypt::PBKDF2->new(
        hash_class => 'HMACSHA2',
        hash_args => {
            sha_size => 512,
        },
        iterations => 10000,
        salt_len => 10,
    );
    my $hashed_password = $pbkdf2->generate($params->{password});

    # verify if uswer already exists
    my $user_already_exists = $c->model("DB::User")->search({
        email => $params->{email}
        })->first();

    my $user;
    if ( !$user_already_exists ) {
        eval {
            $user = $c->model("DB::User")->create({
                email => $params->{email},
                display_name => $params->{username},
                password => $hashed_password
                });
            } or do {
                $c->stash(error_msg => "There was an error while creating the user, please data and try again.");
                $c->stash(form_data => $params);
                $c->stash(template => 'login.tt2');
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
                    # Set an error message if the user can'tlog in
                    $c->stash(error_msg => "The user couldn't log in, please try again later.");
                    $c->stash(form_data => $params);
                    $c->stash(template => 'login.tt2');
                }
            }
            
    } else {
        $c->stash(error_msg => "A user with this email address already exists.");
        $c->stash(form_data => $params);
        $c->stash(template => 'login.tt2');
    }
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
