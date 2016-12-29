package MyApp::Controller::Employee;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

MyApp::Controller::Employee - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched MyApp::Controller::Employee in Employee.');
}

sub list :Local :Args(0) {
	my ($self, $c) = @_;

	my %employees = map {
	        $_->id => $_->first_name." ".$_->last_name,
    	} $c->model('DB::Employee')->all();

	$c->stash({
		data => \%employees,
		template => "employee/list.tt2",
		});
}

sub add :Local :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash(template => 'employee/add.tt2');
}

sub save_new_employee :Local :Args(0) {
    my ( $self, $c ) = @_;

    foreach my $param (values($c->req->params)) {
    	$param =~ /^\Q$param\E/;
    	$param = $self->trim($param);
    }

    my $params = $c->req->params;

    my @words = split /,/, $params->{skills};

    my %skills = map {
        $_->id => $_->technical_skill,
	} $c->model('DB::TechnicalSkill')->all();
    my @skills_string = values %skills;

    my @found_skills;
   	foreach my $skill (@words) {
    	if ( grep $_ eq $skill, @skills_string ) {
    		push @found_skills, $skill;
    	} else {
    		eval {
    			my $new_skill = $c->model('DB::TechnicalSkill')->create({
	    			technical_skill => $skill
	    			});
    			} or do {
    				$c->stash->{error_msg} = "There was an error while adding the new skill to the database, please try again later.";
    				$c->forward('list');
    			}
    	}
    }

    eval {
    	my $new_employee = $c->model('DB::Employee')->create({
	    	first_name => $params->{first_name},
	    	last_name => $params->{last_name},
	    	department => $params->{department},
	    	project_id => undef,
	    	skills => @found_skills,
	    	});
    	} or do {
    		$c->stash->{error_msg} = "There was an error while saving the new employee, please try again later.";
    		$c->forward('list');
    	};
    
	$c->stash->{status_msg} = "The team is saved successfully";
    $c->forward('list');
}

sub edit :Local {
	my ($self, $c, $id) = @_;

	foreach my $param (values($c->req->params)) {
    	$param =~ /^\Q$param\E/;
    	$param = $self->trim($param);
    }

    my $params = $c->req->params;

	my $employee = $c->model('DB::Employee')->find($id);

	if ($employee) {
		
		$c->stash({
			id => $employee->id,
			first_name => $employee->first_name,
			last_name => $employee->last_name,
			department => $employee->department,
			project_id => $employee->project_id,
			skills => $employee->technical_skills
			});

	} else {
		$c->stash->{error_msg} = "No employee found with this id.";
    	$c->forward('list');
	}

}

sub update :Local {
	my ($self, $c) = @_;

	foreach my $param (values($c->req->params)) {
    	$param =~ /^\Q$param\E/;
    	$param = $self->trim($param);
    }

    my $params = $c->req->params;

    my $employee = $c->model('DB::Employee')->find($params->{id});

    eval {
    	$employee->update({
    		first_name => $params->{first_name},
    		last_name => $params->{last_name},
    		department => $params->{department},
    		project_id => undef,
    		skills => $params->{technical_skills}
    		});
    } or do {
    	$c->stash->{error_msg} = "There was an error while updating the employee, please try again later.";
    	$c->forward('list');
    }
}

sub delete :Local :Args(1) {
    my ($self, $c, $id) = @_;

    my $employee_to_delete = $c->model('DB::Employee')->find($id);
    $employee_to_delete->delete if $employee_to_delete;

    $c->stash->{status_msg} = "Employee deleted.";
    $c->forward('list');
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
