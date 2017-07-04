package MyApp::Controller::Employee;
use Moose;
use namespace::autoclean;

use DateTime; 
use Email::Valid;
use Switch;
use utf8;

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
        skills => \%reverse_skills,
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
                        {mid => $c->set_error_msg("Eroare! Încercați mai târziu.")}));
    			}
    	}
    }

    unless (Email::Valid->address(
        -address => $params->{email},
        -mxcheck => 1 )) {
        return $c->response->redirect($c->uri_for('list',
            {mid => $c->set_error_msg("Adresa email nu este validă.")}));
    }

    my $date = getTime();

    eval {
    	my $new_employee = $c->model('DB::Employee')->create({
	    	first_name => $params->{first_name},
	    	last_name => $params->{last_name},
            email => $params->{email},
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
                {mid => $c->set_error_msg("Eroare! Încercați mai târziu.")}));
    	};

        $c->response->redirect($c->uri_for('list',
            {mid => $c->set_status_msg("Angajatul a fost adăugat.")}));

}

sub edit :Local {
	my ($self, $c, $id) = @_;

    $c->load_status_msgs;

    my $params = $c->req->params;

	my $employee = $c->model('DB::Employee')->find($id);
    my %skills_for_employee = $self->get_skill($c, $id);


    my $scal = join(", ", map { "$skills_for_employee{$_}" } keys %skills_for_employee);

    my $data = $self->show_history($c, $id);
	if ($employee) {
		
		$c->stash({
			id => $employee->id,
			first_name => $employee->first_name,
			last_name => $employee->last_name,
            email => $employee->email,
			department => $departments{$employee->department->id},
			project => $projects{$employee->project_id},
            role => $roles{$employee->role_id},
			skills => $scal,
            departments => \%departments,
            projects => \%projects,
            roles => \%roles,
            performance => $data
			});

	} else {
		$c->response->redirect($c->uri_for('list',
            {mid => $c->set_error_msg("Nu există angajat cu acest id.")}));
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
                        {mid => $c->set_error_msg("Eroare! Încercați mai târziu.")}));
                }
        }
    }

    unless (Email::Valid->address(
        -address => $params->{email},
        -mxcheck => 1 )) {
        return $c->response->redirect($c->uri_for('list',
            {mid => $c->set_error_msg("Adresa email nu este validă.")}));
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
            email => $params->{email},
    		department => $reverse_departments{$params->{department}},
            role_id => $reverse_roles{$params->{roles}},
    		});
        foreach my $skill (@found_skills) {
                my $relation = $c->model('DB::EmployeeSkill')->update_or_create({
                    id_employee => $employee->id,
                    id_skill => $skill
                    });
            };

        $c->response->redirect($c->uri_for('list',
            {mid => $c->set_status_msg("Angajatul a fost modificat.")}));

    } or do {
    	$c->response->redirect($c->uri_for('list',
            {mid => $c->set_error_msg("Eroare! Încercați mai târziu.")}));
    };

    

}

sub delete :Local :Args(1) {
    my ($self, $c, $id) = @_;

    my $employee_to_delete = $c->model('DB::Employee')->find($id);

    if ($employee_to_delete) {
        eval {
            
            my $relations = $c->model('DB::EmployeeSkill')->search({
                id_employee => $id,
                })->delete;
            $relations = $c->model('DB::EmployeePerformance')->search({
                employee_id => $id,
                })->delete;
            $employee_to_delete->delete;
            $c->response->redirect($c->uri_for('list',
                {mid => $c->set_status_msg("Angajat șters.")}));
        } or do {
            $c->response->redirect($c->uri_for('list',
                {mid => $c->set_error_msg("Eroare! Încercați mai târziu.")}));
        }
    } else {
        $c->response->redirect($c->uri_for('list',
            {mid => $c->set_error_msg("Nu există angajat cu acest id.")}));
    }

}

sub delete_project :Local :Args(1) {
    my ($self, $c, $id) = @_;

    my $employee = $c->model('DB::Employee')->find($id);
    my $project = $employee->team;
    my $employee_role = $employee->role->role;

    eval {
        switch ($employee_role) {
            case "Developer" { $project->decrease_dev_filled(1)}
            case "Business Analyst" { $project->decrease_ba_filled(1)}
            case "QA" { $project->decrease_qa_filled(1)}
        }
        $employee->project_id(undef);
        $employee->update;
        $project->update;

        return $c->response->redirect($c->uri_for('edit', $id,
            {mid => $c->set_status_msg("Proiect șters de la angajat.")}));
    } or do {
        return $c->response->redirect($c->uri_for('edit', $id,
            {mid => $c->set_error_msg("Eroare! Încercați mai târziu.")}));
    }
    
    
                

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

sub show_history {
    my ($self, $c, $id) = @_;

    my @data = $c->model('DB::EmployeePerformance')->search(
        {
            employee_id => $id
        })->all();

    my $pretty_employee_data;
    foreach my $sprint (@data) {
        $pretty_employee_data->{$sprint->id_sprint->id}->{project} = $sprint->id_project->name;
        $pretty_employee_data->{$sprint->id_sprint->id}->{sprint} = $sprint->id_sprint->sprint_title;
        $pretty_employee_data->{$sprint->id_sprint->id}->{velocity} = $sprint->velocity();
    }

    return $pretty_employee_data;
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
