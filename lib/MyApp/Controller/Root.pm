 package MyApp::Controller::Root;
use Moose;
use namespace::autoclean;
use DateTime                   qw( );
use DateTime::Format::Strptime qw( );
use utf8;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=encoding utf-8

=head1 NAME

MyApp::Controller::Root - Root Controller for MyApp

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 auto

Check if there is a user and, if not, forward to login page

=cut

# Note that 'auto' runs after 'begin' but before your actions and that
# 'auto's "chain" (all from application path to most specific class are run)
# See the 'Actions' section of 'Catalyst::Manual::Intro' for more info.
sub auto :Private {
    my ($self, $c) = @_;

    # Allow unauthenticated users to reach the login page.  This
    # allows unauthenticated users to reach any action in the Login
    # controller.  To lock it down to a single action, we could use:
    #   if ($c->action eq $c->controller('Login')->action_for('index'))
    # to only allow unauthenticated access to the 'index' action we
    # added above.
    if ($c->controller eq $c->controller('Login')) {
        return 1;
    }

    # If a user doesn't exist, force login
    if (!$c->user_exists) {
        # Dump a log message to the development server debug output
        $c->log->debug('***Root::auto User not found, forwarding to /login');
        # Redirect the user to the login page
        $c->response->redirect($c->uri_for('/login'));
        # Return 0 to cancel 'post-auto' processing and prevent use of application
        return 0;
    }

    # User found, so return 1 to continue with processing after this 'auto'
    return 1;
}


=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    # will show current sprint status
    my @sprints = $c->model("DB::Sprint")->search(
        {
            manager_id => $c->user->id,
        },
        {
            join => "sprint_team",
            select => ['sprint_team.name', 'sprint_team.days_in_iteration', 'me.end_date', { max => 'me.end_date' } ],
            as     => ['sprint_team_name', 'days_in_iteration', 'end_date', 'max_date'],
            group_by => [ "project_id","end_date", "days_in_iteration" ],
            result_class => "DBIx::Class::ResultClass::HashRefInflator",
        })->all();
    warn Data::Dumper::Dumper(\@sprints);

    my $format = DateTime::Format::Strptime->new(
        pattern   => '%Y-%m-%d',
        time_zone => 'local',
        on_error  => 'croak',
    );
    my $ref  = DateTime->today( time_zone => 'local' );

    foreach my $team (@sprints){
        my $last_day = $format->parse_datetime($team->{max_date});
        warn Data::Dumper::Dumper($team->{days_in_iteration});

        my $next = $last_day->add(days => $team->{days_in_iteration});
        $team->{zile_ramase} = $last_day->delta_days($ref)->in_units('days');

      #  $team->{iteration_ends} = 
    }

    my %mapped_sprints = map { $_->{sprint_team_name} => $format->parse_datetime($_->{max_date}) >= $ref ? 
        $_->{sprint_team_name}." - sprintul a fost deja introdus" : $_->{sprint_team_name}." - Sprintul curent se termină în " .
        $_->{zile_ramase} . " zile";
        } @sprints;
        warn Data::Dumper::Dumper(\%mapped_sprints);
    $c->stash({
        superu => $c->user->display_name,
        sprints => \%mapped_sprints,
        template => 'index.tt2'
        });
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

ubuntu,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
