package MyApp::Controller::Employee;
use Moose;
use namespace::autoclean;

use DateTime; 

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

MyApp::Controller::Employee - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 GLOBAL VARIABLES

=cut

my %departments;
my %projects;
my %skills;
my %roles;
my %reverse_departments;
my %reverse_projects;
my %reverse_skills;
my %reverse_roles;
=head1 METHODS

=cut

=head2 auto

=cut

sub auto :Path :Args(0) {
    my ( $self, $c ) = @_;

    # Select all departments and projects because all operations need them and we also neew to maintain the dropdownlist on the ui side
    %departments = map {
            $_->id => $_->dname,
        } $c->model('DB::Department')->all();

    %projects = map {
            $_->id => $_->name,
        } $c->model('DB::Team')->all();

    %skills = map {
            $_->id => $_->technical_skill,
        } $c->model('DB::TechnicalSkill')->all();

    %roles = map {
            $_->id => $_->role,
        } $c->model('DB::Role')->all();

    %reverse_departments = reverse %departments;
    %reverse_projects = reverse %projects;
    %reverse_skills = reverse %skills;
    %reverse_roles = reverse %roles;

    warn Data::Dumper::Dumper(\%roles);

}

sub list :Local :Args(0) {
	my ($self, $c) = @_;

    $c->load_status_msgs;

	my %employees = map {
	        $_->id => $_->first_name." ".$_->last_name,
    	} $c->model('DB::Employee')->all();

	$c->stash({
		data => \%employees,
		template => "employee/list.tt2",
		});
}

sub add :Local {
    my ( $self, $c ) = @_;

    $c->stash({
        departments => \%departments,
        projects => \%projects,
        roles => \%roles,
        template => 'employee/add.tt2'
        });
}

sub save_new_employee :Local :OnError('add') {
    my ( $self, $c ) = @_;

    my $params = $c->req->params;

    my @words = split /,/, $params->{skills};

    my @found_skills;
    my $new_skill;
   	foreach my $skill (@words) {
        $skill =~ s/^\s+|\s+$//g;
    	if ($reverse_skills{$skill}) {
    		push @found_skills, $reverse_skills{$skill};
    	} else {
    		eval {
    			$new_skill = $c->model('DB::TechnicalSkill')->create({
	    			technical_skill => $skill
	    			});
                push @found_skills, $new_skill->id;
    			} or do {
    				$c->response->redirect($c->uri_for('list',
                        {mid => $c->set_status_msg("There was an error while adding the new skill to the database, please try again later.")}));
    			}
    	}
    }

    my $date = getTime();

    eval {
    	my $new_employee = $c->model('DB::Employee')->create({
	    	first_name => $params->{first_name},
	    	last_name => $params->{last_name},
	    	department => $reverse_departments{$params->{department}},
	    	project_id => $reverse_projects{$params->{project}},
            hire_date => $date,
            updated_by => $c->user->user_id,
            role_id => $reverse_roles{$params->{roles}},
	    	});

        foreach my $skill (@found_skills) {
                my $relation = $c->model('DB::EmployeeSkill')->create({
                    id_employee => $new_employee->id,
                    id_skill => $skill
                    });
            }
    	} or do {
    		$c->response->redirect($c->uri_for('list',
                {mid => $c->set_status_msg("There was an error while saving the new employee, please try again later.")}));
    	};

        $c->response->redirect($c->uri_for('list',
            {mid => $c->set_status_msg("The employee has been added successfully.")}));

}

sub edit :Local {
	my ($self, $c, $id) = @_;

    my $params = $c->req->params;

	my $employee = $c->model('DB::Employee')->find($id);
    my %skills_for_employee = $self->get_skill($c, $id);
    my $scal = join(", ", map { "$skills_for_employee{$_}" } keys %skills_for_employee);

	if ($employee) {
		
		$c->stash({
			id => $employee->id,
			first_name => $employee->first_name,
			last_name => $employee->last_name,
			department => $departments{$employee->department->id},
			project => $projects{$employee->project_id},
            role => $roles{$employee->role_id},
			skills => $scal,
            departments => \%departments,
            projects => \%projects,
            roles => \%roles,
			});

	} else {
		$c->response->redirect($c->uri_for('list',
            {mid => $c->set_status_msg("No employee found with this id.")}));
	}

}

sub update :Local :OnError('edit') {
	my ($self, $c) = @_;

    my $params = $c->req->params;

    my $employee = $c->model('DB::Employee')->find($params->{id});

    my @words = split /,/, $params->{skills};
    my @found_skills;
    foreach my $skill (@words) {
        $skill =~ s/^\s+|\s+$//g;
        if ($reverse_skills{$skill}) {
            push @found_skills, $reverse_skills{$skill};
        } else {
            eval {
                my $new_skill = $c->model('DB::TechnicalSkill')->create({
                    technical_skill => $skill
                    });
                push @found_skills, $new_skill->id;
                } or do {
                    $c->response->redirect($c->uri_for('list',
                        {mid => $c->set_status_msg("There was an error while adding the new skill to the database, please try again later.")}));
                }
        }
    }

    unless ( $params->{skills} ) {
        my $relations = $c->model('DB::EmployeeSkill')->search({
                id_employee => $employee->id,
                })->delete;
    }
    
    eval {
    	$employee->update({
    		first_name => $params->{first_name},
    		last_name => $params->{last_name},
    		department => $reverse_departments{$params->{department}},
    		project_id => $reverse_projects{$params->{project}},
            role_id => $reverse_roles{$params->{roles}},
    		});
        foreach my $skill (@found_skills) {
                my $relation = $c->model('DB::EmployeeSkill')->update_or_create({
                    id_employee => $employee->id,
                    id_skill => $skill
                    });
            };
    } or do {
    	$c->response->redirect($c->uri_for('list',
            {mid => $c->set_status_msg("There was an error while updating the employee, please try again later.")}));
    };

    $c->response->redirect($c->uri_for('list',
        {mid => $c->set_status_msg("The employee has been updated.")}));

}

sub delete :Local :Args(1) {
    my ($self, $c, $id) = @_;

    my $employee_to_delete = $c->model('DB::Employee')->find($id);

    if ($employee_to_delete) {
        eval {
            $employee_to_delete->delete;
            my $relations = $c->model('DB::EmployeeSkill')->search({
                id_employee => $id,
                })->delete;
        } or do {
            $c->response->redirect($c->uri_for('list',
                {mid => $c->set_status_msg("There was an error while deleting the employee, please try again later.")}));
        }
    } else {
        $c->response->redirect($c->uri_for('list',
            {mid => $c->set_status_msg("No employee found with this id.")}));
    }

    $c->response->redirect($c->uri_for('list',
        {mid => $c->set_status_msg("Employee deleted.")}));

}

sub get_skill :Private {
    my ( $self, $c, $id ) = @_;

    my @skills = $c->model('DB::EmployeeSkill')->search(
        {
            'me.id_employee' => $id,
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


sub trim {
	my ($self, $string) = @_;
	$string =~ s/^\s+|\s+$//g;

	return $string

}

sub getTime {

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    my $nice_timestamp = sprintf ( "%04d-%02d-%02d",
                                   $year+1900,$mon+1,$mday);
    return $nice_timestamp;
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
