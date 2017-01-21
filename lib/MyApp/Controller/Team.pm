package MyApp::Controller::Team;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

MyApp::Controller::Team - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

my %skills;
my %reverse_skills;
=head1 METHODS

=cut

=head2 auto

=cut

sub auto :Path :Args(0) {
    my ( $self, $c ) = @_;

    %skills = map {
            $_->id => $_->technical_skill,
        } $c->model('DB::TechnicalSkill')->all();

    %reverse_skills = reverse %skills;

}

sub add_new_team :Local :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash(template => 'team/add_new_team.tt2');
}

sub save_new_team :Local :Args(0) {
    my ( $self, $c ) = @_;

    my $params = $c->req->params();
    warn Data::Dumper::Dumper($params);
    my $team_name_already_exists = $c->model('DB::Team')->search({
    		name => $params->{name}
    		})->first();

    if ($team_name_already_exists) {
	        $c->response->redirect($c->uri_for('view_teams_for_this_user',
            	{mid => $c->set_status_msg("A team with this name already exists. Please choose another name.")}));
    } else {

		unless ($params->{daily_meeting_time} =~ m/(1[012]|[1-9]):[0-5][0-9](\\s)?(?i)(am|pm)/ 
	    	or $params->{planning_time} =~ m/(1[012]|[1-9]):[0-5][0-9](\\s)?(?i)(am|pm)/ 
	    	or $params->{retrospective_time} =~ m/(1[012]|[1-9]):[0-5][0-9](\\s)?(?i)(am|pm)/ 
	    	or $params->{planning_day} =~ m/^((Monday)|(Tuesday)|(Wednesday)|(Thursday)|(Friday))$/
	    	or $params->{retrospective_day} =~ m/^((Monday)|(Tuesday)|(Wednesday)|(Thursday)|(Friday))$/) {
		    	$c->response->redirect($c->uri_for('view_teams_for_this_user',
            		{mid => $c->set_status_msg("One of the date/time validations doesn't pass.")}));
	    };    

	    my $planning_time = $params->{planning_time}.",".$params->{planning_day};
	    my $retrospective_time = $params->{retrospective_time}.",".$params->{retrospective_day};

	    my @words = split /,/, $params->{skills};

	    my %skills = map {
	        $_->id => $_->technical_skill,
    	} $c->model('DB::TechnicalSkill')->all();

	    my @found_skills;
	    my $new_skill;
	    my @skills_string = values %skills;
	    my $informative_message;
	   	foreach my $skill (@words) {
	    	if ($reverse_skills{$skill}) {
	    		push @found_skills, $reverse_skills{$skill};
	    	} else {
	    		eval {
	    			$new_skill = $c->model('DB::TechnicalSkill')->create({
		    			technical_skill => $skill
		    			});
	                push @found_skills, $new_skill->id;
	    			} or do {
	    				$c->response->redirect($c->uri_for('view_teams_for_this_user',
            				{mid => $c->set_status_msg("There was an error while adding the new skill to the database, please try again later.")}));
	    			}
	    	}
	    }

	    eval {
	    	my $new_team = $c->model('DB::Team')->create({
		    	name => $params->{team_name},
		    	target_velocity => $params->{team_velocity},
		    	days_in_iteration => $params->{team_iteration},
		    	daily_meeting => $params->{daily_meeting_time},
		    	sprint_planning => $planning_time,
		    	sprint_retrospective => $retrospective_time,
		    	manager_id => $c->user->user_id,
		    	notes => $params->{team_notes},
		    	});
		    foreach my $skill (@found_skills) {
	                my $relation = $c->model('DB::ProjectSkill')->create({
	                    id_project => $new_team->id,
	                    id_skill => $skill
	                    });
	            }
	        } or do {
	    		$c->response->redirect($c->uri_for('view_teams_for_this_user',
            		{mid => $c->set_status_msg("There was an error while saving the new employee, please try again later.")}));	
	    	};
	    
	    $c->response->redirect($c->uri_for('view_teams_for_this_user',
            {mid => $c->set_status_msg("The team is saved successfully.")}));	
	    	
	}

}

sub delete :Local :Args(1) {
    my ($self, $c, $id) = @_;

    my $team_to_delete = $c->model('DB::Team')->find($id);

    if ($team_to_delete) {
        eval {
            $team_to_delete->delete;
            my $relations = $c->model('DB::ProjectSkill')->search({
                id_project => $id,
                })->delete_all();
        } or do {
            $c->response->redirect($c->uri_for('view_teams_for_this_user',
                {mid => $c->set_status_msg("There was an error while deleting the project, please try again later.")}));
        }
    } else {
        $c->response->redirect($c->uri_for('view_teams_for_this_user',
            {mid => $c->set_status_msg("No project found with this id.")}));
    }

    $c->response->redirect($c->uri_for('view_teams_for_this_user',
        {mid => $c->set_status_msg("Project deleted.")}));
}

sub edit :Local {
	my ($self, $c, $id) = @_;

	my $team = $c->model('DB::Team')->search({
		id => $id,
		manager_id => $c->user->user_id,
		})->first;
	my %skills_for_team = $self->get_skill($c, $id);
    my $scal = join(", ", map { "$skills_for_team{$_}" } keys %skills_for_team);

	my ($planning_time, $planning_day) = split(/,/, $team->sprint_planning());
	my ($retrospective_time, $retrospective_day) = split(/,/, $team->sprint_retrospective);

	if ($team) {

		$c->stash({
			id => $team->get_column("id"),
			team_name => $team->get_column("name"),
			team_velocity => $team->get_column("target_velocity"),
			team_iteration => $team->get_column("days_in_iteration"),
			daily_meeting_time => $team->get_column("daily_meeting"),
			planning_time => $planning_time,
			planning_day => $planning_day,
			retrospective_time => $retrospective_time,
			retrospective_day => $retrospective_day,
			team_notes => $team->get_column("notes"),
			skills => $scal
			});

	} else {
		$c->response->redirect($c->uri_for('view_teams_for_this_user',
            {mid => $c->set_status_msg("This team doesn't exist.")}));	
	    	
	}

}

sub view_teams_for_this_user :Local :Args(0) {
	my ($self, $c) = @_;

	my @teams_list = $c->model('DB::Team')->search({
		manager_id => $c->user->user_id
		})->all();

	my %teams_to_show;

	foreach my $team (@teams_list){
		%teams_to_show->{$team->id} = $team->name;
	}

	$c->stash({
		data => \%teams_to_show,
		template => "team/view_teams_for_this_user.tt2",
		});
}

sub update :Local {
	my ($self, $c) = @_;

 	my $params = $c->req->params();
 	
    my $current_item = $c->model('DB::Team')->find($params->{id});
    my $team_name_already_exists = $c->model('DB::Team')->search({
    		name => $params->{team_name},
    		id => { "-not_in" => ($params->{id})},
    		})->first();

    if ($team_name_already_exists) {

		$c->response->redirect($c->uri_for('view_teams_for_this_user',
        	{mid => $c->set_status_msg("A team with this name already exists. Please choose another name.")}));	

    } else {

		unless ($params->{daily_meeting_time} =~ m/(1[012]|[1-9]):[0-5][0-9](\\s)?(?i)(am|pm)/ 
	    	or $params->{planning_time} =~ m/(1[012]|[1-9]):[0-5][0-9](\\s)?(?i)(am|pm)/ 
	    	or $params->{retrospective_time} =~ m/(1[012]|[1-9]):[0-5][0-9](\\s)?(?i)(am|pm)/ 
	    	or $params->{planning_day} =~ m/^((Monday)|(Tuesday)|(Wednesday)|(Thursday)|(Friday))$/
	    	or $params->{retrospective_day} =~ m/^((Monday)|(Tuesday)|(Wednesday)|(Thursday)|(Friday))$/) {
		    	$c->response->redirect($c->uri_for('view_teams_for_this_user',
            		{mid => $c->set_status_msg("One of the date/time validations doesn't pass.")}));
	    };    

	    my $planning_time = $params->{planning_time}.",".$params->{planning_day};
	    my $retrospective_time = $params->{retrospective_time}.",".$params->{retrospective_day};
	    
		my @words = split /,/, $params->{skills};

	    my %skills = map {
	        $_->id => $_->technical_skill,
    	} $c->model('DB::TechnicalSkill')->all();

	    my @found_skills;
	    my @not_found;
	    my @skills_string = values %skills;
	   	foreach my $skill (@words) {
	    	if ( grep $_ eq $skill, @skills_string ) {
	    		push @found_skills, $skill;
	    	} else {
	    		eval {
	                my $new_skill = $c->model('DB::TechnicalSkill')->create({
	                    technical_skill => $skill
	                    });
	                push @found_skills, $new_skill->id;
	               } or do {
	                    $c->response->redirect($c->uri_for('view_teams_for_this_user',
            				{mid => $c->set_status_msg("There was an error while adding the new skill to the database, please try again later.")}));
	               }
	    	}
	    }

	    $current_item->update({
	    	name => $params->{team_name},
	    	target_velocity => $params->{team_velocity},
	    	days_in_iteration => $params->{team_iteration},
	    	daily_meeting => $params->{daily_meeting_time},
	    	sprint_planning => $params->{planning_time},
	    	sprint_retrospective => $params->{retrospective_time},
	    	notes => $params->{team_notes},
	    	});
	    foreach my $skill (@found_skills) {
                my $relation = $c->model('DB::ProjectSkill')->update_or_create({
                    id_project => $current_item->id,
                    id_skill => $skill
                    });
            };

	    $c->response->redirect($c->uri_for('view_teams_for_this_user',
           {mid => $c->set_status_msg("The team is successfully updated.")}));
	               
	}

}

sub list :Local :Args(0) {
	my ($self, $c) = @_;

	$c->load_status_msgs;

	my %team_list = map {
		$_->id => $_->name,
		} $c->model('DB::Team')->all();

	$c->stash({
		teams => \%team_list,
		template => "team/list.tt2",
		});
}

sub view_employees_in_team :Local {
	my ($self, $c, $id) = @_;

	$c->load_status_msgs;

	my $team = $c->model('DB::Team')->find($id);

	if ($team) {

		my @employees_in_team = $c->model('DB::Team')->search(
		{
			name => $team->name
		},
		{
			columns => [ qw(
                id
                name
                employees.id
                employees.first_name
                employees.last_name
            )],
			join     => 'employees',
			result_class => 'DBIx::Class::ResultClass::HashRefInflator',
        })->all();

		my $employees;
		foreach my $entity (@employees_in_team) {
			$employees->{$entity->{employees}->{id}} =
				$entity->{employees}->{first_name}." ".$entity->{employees}->{last_name}
		}

		$c->stash({
			employees => $employees,
			template => "team/group.tt2"
			});

	} else {
		$c->stash({
			error_msg => "This team does not exist.",
			template => "team/list.tt2"
			});
	}

}

sub get_skill :Private {
    my ( $self, $c, $id ) = @_;

    my @skills = $c->model('DB::ProjectSkill')->search(
        {
            'me.id_project' => $id,
        },
        {
            join    => ['id_skill'],
            columns => [ { id => 'id_skill.id' }, { name => 'id_skill.technical_skill' } ],
            result_class => 'DBIx::Class::ResultClass::HashRefInflator',
        },
    );
    my %skills = map {
            $_->{id} => $_->{name},
        } @skills;

    return %skills;
}

sub add_members :Local {
	my ($self, $c, $id) = @_;

	
	my @employees_without_project = $c->model('DB::Employee')->search(
		{	project_id => undef },
		{
			columns => [ { id => 'id' }, { first_name => "first_name" }, { last_name => "last_name" } ],
			result_class => 'DBIx::Class::ResultClass::HashRefInflator',
		})->all;

	my @employee_skills = $c->model('DB::EmployeeSkill')->search(
        {},
        {
            select  => [ 'me.id_employee', { 'GROUP_CONCAT' => 'id_skill.technical_skill' } ],
            as      => [ qw ( employeeid skill) ],
            join    => [ 'id_skill' ],
            group_by     => 'me.id_employee',
            result_class => 'DBIx::Class::ResultClass::HashRefInflator',
        },
    );

    my %pretty_skills = map {
            $_->{employeeid} => $_->{skill},
        } @employee_skills;

	my %pretty_employees = map {
            $_->{id} => "$_->{first_name} $_->{last_name}",
        } @employees_without_project;

    my %pretty_employees_skills;
        foreach my $employee (keys %pretty_skills){
        	if ($pretty_employees{$employee}) {
	        	$pretty_employees_skills{$employee}{skills} = $pretty_skills{$employee};
	        	$pretty_employees_skills{$employee}{name} = $pretty_employees{$employee};
        	} 
        }
    my @covered_skills = get_covered_skills($self, $c, $id);
	$c->stash({
		id => $id,
		employees => \%pretty_employees_skills,
		template => 'team/add_members.tt2'
		});

}

sub add_to_team :Local {
	my ( $self, $c, $id_project, $id_employee ) = @_;

	my $employee = $c->model('DB::Employee')->find($id_employee);
	my $project = $c->model('DB::Team')->find($id_project);
	if($employee && $project) {
		eval {
			$employee->project_id($id_project);
			$employee->update;
		} or do {
			$c->response->redirect($c->uri_for('view_teams_for_this_user',
            	{mid => $c->set_status_msg("There was an error while adding the employee to the project, please try again later.")}));
		}
	} else {
		$c->response->redirect($c->uri_for('view_teams_for_this_user',
            {mid => $c->set_status_msg("This project or employee does not exist in the database.")}));
	}

	$c->response->redirect($c->uri_for('view_teams_for_this_user',
        {mid => $c->set_status_msg("The team is successfully updated.")}));
	
}

sub get_covered_skills :Private {
	my ($self, $c, $id) = @_;

	my @skills = $c->model('DB::ProjectSkill')->search(
		{
			id_project => $id,
		},
		{
			select  => [ { 'GROUP_CONCAT' => 'id_skill.technical_skill' } ],
            as      => [ 'skills' ],
            join    => [ 'id_skill' ],
            result_class => 'DBIx::Class::ResultClass::HashRefInflator',
		});
	
}

sub trim {
	my ($self, $string) = @_;
	$string =~ s/^\s+|\s+$//g;

	return $string
};

=encoding utf8

=head1 AUTHOR

ubuntu,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
