package MyApp::Controller::Sprints;
use Moose;
use namespace::autoclean;
use Excel::Writer::XLSX;
use Spreadsheet::WriteExcel;
use DateTime                   qw( );
use DateTime::Format::Strptime qw( );


BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

MyApp::Controller::Sprints - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

has parser => (
    is => 'ro',
    isa => 'DateTime::Format::Strptime',
    default => sub 
            { 
                return DateTime::Format::Strptime->new(
                            pattern   => '%Y-%m-%d',
                            on_error  => 'croak',
                        );
            }
    );

=head2 index

=cut

sub list :Local :Args(0) {
	my ($self, $c) = @_;

	$c->load_status_msgs;

	my @teams_list = $c->model('DB::Team')->search({
		manager_id => $c->user->user_id
		})->all();

	my %teams_to_show;

	foreach my $team (@teams_list){
		%teams_to_show->{$team->id} = $team->name;
	}

	$c->stash({
		data => \%teams_to_show,
		template => "sprints/teams.tt2",
		});
}

sub view_sprints :Local :Args(1){
	my ($self, $c, $id) = @_;

	my @sprints = $c->model("DB::Sprint")->search(
		{
			"me.project_id" => $id,
		},
		{
			join => "sprint_team",
			'+select' => ['sprint_team.target_velocity'],
      		'+as'     => ['sprint_team_target_velocity'],
			order_by => { "-desc" => "end_date" },
			result_class => "DBIx::Class::ResultClass::HashRefInflator",
		})->all();
	
	$c->stash({
		datapoints => \@sprints,
		id => $id,
		sprints => \@sprints,
		template => "sprints/view_sprints.tt2"
		});
}

sub add_sprint :Local :Args(1) {
	my ($self, $c, $id) = @_;
	
	$c->load_status_msgs;
	my $name;

	my $last_sprint_ended = $c->model("DB::Sprint")->search(
		{
			project_id => $id,
		},
		{
			order_by => { "-desc" => "end_date" }
		})->get_column("end_date")->first;

	my $project = $c->model("DB::Team")->find($id);

	my $iteration = $project->days_in_iteration;

	$c->stash({
		last_sprint_ended => $last_sprint_ended,
		iteration => $iteration,
		id => $id,
		template => "sprints/add_sprint.tt2"
		});
}

sub save_sprint :Local :Args(0) {
	my ($self, $c) = @_;

	my $params = $c->req->params;

	my $start_date = $self->parser->parse_datetime($params->{datepicker});
    my $end_date = $self->parser->parse_datetime($params->{datepicker_end});

    my @previous_dates = $c->model("DB::Sprint")->search(
		{
			project_id => $params->{id},
		},
		{
			columns => qw( end_date ),
			result_class => 'DBIx::Class::ResultClass::HashRefInflator',
		})->all();

    foreach my $date_already_logged ( @previous_dates ) {
    	my $end_date_exists = $self->parser->parse_datetime($date_already_logged->{end_date});
    	#start date has to be bigger than any other date already logged
    	if(DateTime->compare($start_date,$end_date_exists) < 0){
    		$c->stash(error_msg => 'Sprint overlaps are forbidden!');
        	$c->go("add_sprint", [$params->{id}]);
    	}
    }

    if(DateTime->compare($start_date,$end_date) > 0){
        $c->stash(error_msg => 'Start date should be earlier than end date');
        $c->go("add_sprint", [$params->{id}]);
    }

	eval {
		my $new_sprint = $c->model("DB::Sprint")->create({
			project_id => $params->{id},
			start_date => $params->{datepicker},
			end_date => $params->{datepicker_end},
			sprint_title => $params->{sprint_name},
			sprint_description => $params->{sprint_description},
			velocity => $params->{velocity}
			});
		return $c->response->redirect($c->uri_for('list',
            {mid => $c->set_status_msg("Sprint successfully saved.")}));
		} or do {
			$c->response->redirect($c->uri_for('list',
                {mid => $c->set_error_msg("There was an error while adding the sprint to the database, please try again later.")}));
		};


}

sub upload :Local {
    my ( $self, $c ) = @_;

    my $params = $c->req->params();

    # if (!$c->req->upload('my-file-selector')) {
    #     $c->stash( error_msg => 'There is no file chosen to upload!');
    #     $c->go("add_sprint", [$params->{id}]);
    #     return;
    # }


    #make the upload of the file
    my $upload = $c->req->upload('file');
    warn Data::Dumper::Dumper($upload);
    # $upload->copy_to("/MyApp/files/");
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
