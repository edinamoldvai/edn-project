package MyApp::Controller::Sprints;
use Moose;
use namespace::autoclean;
use Excel::Writer::XLSX;
use Spreadsheet::WriteExcel;
use DateTime                   qw( );
use DateTime::Format::Strptime qw( );
use Spreadsheet::ParseXLSX;

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

    $self->check_if_dates_correct($c, $params->{id}, $start_date, $end_date);

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

    if (!$c->req->upload('file')) {
        $c->stash( error_msg => 'There is no file chosen to upload!');
        $c->go("add_sprint", [$params->{id}]);
        return;
    }

    #make the upload of the file
    my $upload = $c->req->upload('file');

    my $filename = $upload->tempname;
    if ( $filename =~ /\/tmp\/(\w+)\.xlsx$/ ) {
    	$filename = $1;
    	$upload->copy_to("/media/sf_Application/MyApp/files");
    	process_xslx($self,$c,$filename,$params->{id});
    } else {
    	$c->stash( error_msg => 'Not an .xlsx file!');
        $c->go("add_sprint", [$params->{id}]);
        return;
    }

    $c->stash(status_msg => 'File successfully uploaded!');
    $c->go("add_sprint", [$params->{id}]);
}

sub process_xslx {
	my ($self, $c, $file, $id) = @_;

	my $path_to_file = "/media/sf_Application/MyApp/files/".$file.".xlsx";

	my $parser = Spreadsheet::ParseXLSX->new;
	my $workbook = $parser->parse($path_to_file);
	my $worksheet = $workbook->worksheet('Sheet1');
	unless ($worksheet) {
			$c->stash( error_msg => "Sheet1 can't be found!");
	        $c->go("add_sprint", [$id]);
	        return;
	    }

	my $metadata_sheet = $workbook->worksheet('Sheet2');
	unless ($metadata_sheet) {
			$c->stash( error_msg => "Sheet2 can't be found!");
	        $c->go("add_sprint", [$id]);
	        return;
	    }

	my $has_headers = $self->check_headers($worksheet);
	my $data = $self->read_data($worksheet);
	unless ($data) {
			$c->stash( error_msg => "Sheet1 doesn't contain enough information!");
	        $c->go("add_sprint", [$id]);
	        return;
	    }

	my $has_metadata_headers = $self->check_metadata_headers($metadata_sheet);
	my $metadata = $self->read_data($metadata_sheet);

	my $pretty_data;
	my $pretty_metadata;

	foreach my $key (keys %{$metadata}) {
		my $start_date = $metadata->{$key}->{"Sprint started"};
		$start_date =~ /^\d{4}-\d\d-\d\d$/;
		
		my $end_date = $metadata->{$key}->{"Sprint ended"};
		$end_date =~ /^\d{4}-\d\d-\d\d$/;

		unless ($start_date && $end_date) {
			$c->stash( error_msg => "Dates not defined!");
	        $c->go("add_sprint", [$id]);
	        return;
	    }

	    $self->check_if_dates_correct($c, $id, $start_date, $end_date);

		my $description = $metadata->{$key}->{"Description"};

		$pretty_metadata->{project_id} = $id;
		$pretty_metadata->{start_date} = $start_date;
		$pretty_metadata->{end_date} = $end_date;
		$pretty_metadata->{sprint_title} = "Sprint : ".$start_date." - ".$end_date;
		$pretty_metadata->{sprint_description} = $description;

	}
	my $employee_storypoints;
	my $velocity = 0;
	foreach my $key (keys %{$data}) {
		my $employee_id = $self->check_if_employee_exists($c, $data->{$key}->{Assignee}, $id);
		unless ($employee_id) {
			$c->stash( error_msg => "One of the employees doesn't exist in the system for this project!");
	        $c->go("add_sprint", [$id]);
	        return;
	    }
	    $pretty_data->{$employee_id}->{$data->{$key}->{"Ticket number"}} = $data->{$key}->{"Story Points"};
	    $employee_storypoints->{$employee_id} += $data->{$key}->{"Story Points"};
	    $velocity += $data->{$key}->{"Story Points"};
	}

	$pretty_metadata->{velocity} = $velocity;

	my $sprint_id = $self->insert_into_sprints($c,$pretty_metadata);

	$self->register_employee_performance($c,$id,$employee_storypoints,$sprint_id);

}

sub check_headers {
	my ($self, $worksheet) = @_;

	my $first_column = $worksheet->get_cell(0,0);
	my $second_column = $worksheet->get_cell(0,1);
	my $third_column = $worksheet->get_cell(0,2);

	my $success;

	unless ($first_column->Value() eq "Ticket number" &&
		$second_column->Value() eq "Story Points" &&
		$third_column->Value() eq "Assignee") {

			$success = 0;
	} else {
		$success = 1;
	}

	return $success;

}

sub read_data {
	my ($self, $worksheet) = @_;

	my ( $row_min, $row_max ) = $worksheet->col_range();
	my ( $col_min, $col_max ) = $worksheet->row_range();
	my $data;
	foreach my $col (1 .. $col_max) {
		foreach my $row ($row_min .. $row_max) {
			my $value = $worksheet->get_cell($col, $row);
			my $header = $worksheet->get_cell(0, $row);
			$data->{$col}->{$header->Value()} = $value->Value();
		}
	}
	return $data;
}

sub check_if_employee_exists {
	my ($self, $c, $employee_name, $project_id) = @_;

	my ($first, $last) = split(" ", $employee_name);

	my $employee = $c->model("DB::Employee")->search({
		first_name => $first,
		last_name => $last
	})->first;

	unless ($employee) {
		$employee = $c->model("DB::Employee")->search({
			first_name => $last,
			last_name => $first
		})->first;
	}

	if ($employee) {
		if ($employee->project_id == $project_id ) {
			return $employee->id;
		}
	}
	
}

sub check_metadata_headers {
	my ($self, $worksheet) = @_;

	my $first_column = $worksheet->get_cell(0,0);
	my $second_column = $worksheet->get_cell(0,1);
	my $third_column = $worksheet->get_cell(0,2);

	my $success;

	unless ($first_column->Value() eq "Sprint started" &&
		$second_column->Value() eq "Sprint ended" &&
		$third_column->Value() eq "Description") {

			$success = 0;
	} else {
		$success = 1;
	}

	return $success;
}

sub check_if_dates_correct {
	my ($self, $c, $id, $start_date, $end_date) = @_;

	$start_date = $self->parser->parse_datetime($start_date);
    $end_date = $self->parser->parse_datetime($end_date);

	my @previous_dates = $c->model("DB::Sprint")->search(
		{
			project_id => $id,
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
        	$c->go("add_sprint", [$id]);
    	}
    }

    if(DateTime->compare($start_date,$end_date) > 0){
        $c->stash(error_msg => 'Start date should be earlier than end date');
        $c->go("add_sprint", [$id]);
    }
}

sub insert_into_sprints {
	my ($self, $c, $data) = @_;

	my $new_sprint = $c->model("DB::Sprint")->create($data);

	return $new_sprint->id;
}

sub register_employee_performance {
	my ($self, $c, $project_id, $employees_data, $sprint_id) = @_;

	foreach my $key (keys %{$employees_data}) {
		eval {
			my $employee_performance = $c->model("DB::EmployeePerformance")->create({
				sprint_id => $sprint_id,
				employee_id => $key,
				project_id => $project_id,
				velocity => $employees_data->{$key}
				});
		}
		or do {
			$c->response->redirect($c->uri_for('list',
                 {mid => $c->set_error_msg("There was an error while adding the sprint to the database, please try again later.")}));
		};
		
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
