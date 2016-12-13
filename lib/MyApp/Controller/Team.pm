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


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched MyApp::Controller::Team in Team.');
}

sub add_new_team :Local :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash(template => 'team/add_new_team.tt2');
}

sub save_new_team :Local :Args(0) {
    my ( $self, $c ) = @_;

    foreach my $param (values($c->req->params)) {
    	$param =~ /^\Q$param\E/;
    	$param = $self->trim($param);
    }

    my $name = $c->req->params->{team_name};
    my $velocity = $c->req->params->{team_velocity};
    my $iteration = $c->req->params->{team_iteration};
    my $planning_time = $c->req->params->{planning_time};
    my $retrospective_time = $c->req->params->{retrospective_time};
    my $daily_meeting_time = $c->req->params->{daily_meeting_time};
    my $planning_day = $c->req->params->{planning_day};
    my $retrospective_day = $c->req->params->{retrospective_day};
    my $notes = $c->req->params->{team_notes};
    my $skills => $c->req->params->{skills};

    my $team_name_already_exists = $c->model('DB::Team')->search({
    		name => $name
    		})->first();

    if ($team_name_already_exists) {

    		$c->stash({
    			error_msg => "A team with this name already exists. Please choose another name."
    			});
    		$c->go("add_new_team");

    } else {

		unless ($daily_meeting_time =~ m/(1[012]|[1-9]):[0-5][0-9](\\s)?(?i)(am|pm)/ 
	    	or $planning_time =~ m/(1[012]|[1-9]):[0-5][0-9](\\s)?(?i)(am|pm)/ 
	    	or $retrospective_time =~ m/(1[012]|[1-9]):[0-5][0-9](\\s)?(?i)(am|pm)/ 
	    	or $planning_day =~ m/^((Monday)|(Tuesday)|(Wednesday)|(Thursday)|(Friday))$/
	    	or $retrospective_day =~ m/^((Monday)|(Tuesday)|(Wednesday)|(Thursday)|(Friday))$/) {
		    	$c->stash({
	    			error_msg => "One of the date/time validations don't pass."
	    			});
	    		$c->go("add_new_team");
	    };    

	    $planning_time = $planning_time.",".$planning_day;
	    $retrospective_time = $retrospective_time.",".$retrospective_day;

	    my $new_team = $c->model('DB::Team')->create({
	    	name => $name,
	    	target_velocity => $velocity,
	    	days_in_iteration => $iteration,
	    	daily_meeting => $daily_meeting_time,
	    	sprint_planning => $planning_time,
	    	sprint_retrospective => $retrospective_time,
	    	manager_id => $c->user->user_id,
	    	notes => $notes,
	    	technical_skills_needed => $skills,
	    	});

	    $c->stash->{status_msg} = "The team is saved successfully";
	    $c->go("view_teams_for_this_user");
	}

}

sub delete :Local :Args(1) {
    my ($self, $c, $id) = @_;

    my $team_to_delete = $c->model('DB::Team')->find($id);
    $team_to_delete->delete;

    $c->stash->{status_msg} = "Team deleted.";
    $c->go('view_teams_for_this_user');
}

sub edit :Local {
	my ($self, $c, $id) = @_;

	my $team = $c->model('DB::Team')->find($id);

	my ($planning_time, $planning_day) = split(/,/, $team->sprint_planning);
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
			skills => $team->get_column("technical_skills_needed"),
			});

	} else {
		$c->stash({
    			error_msg => "This team does not exist."
    			});
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

	foreach my $param (values($c->req->params)) {
    	$param =~ /^\Q$param\E/;
    	$param = $self->trim($param);
    }

    my $id = $c->req->params->{id};
    my $name = $c->req->params->{team_name};
    my $velocity = $c->req->params->{team_velocity};
    my $iteration = $c->req->params->{team_iteration};
    my $planning_time = $c->req->params->{planning_time};
    my $retrospective_time = $c->req->params->{retrospective_time};
    my $daily_meeting_time = $c->req->params->{daily_meeting_time};
    my $planning_day = $c->req->params->{planning_day};
    my $retrospective_day = $c->req->params->{retrospective_day};
    my $notes = $c->req->params->{team_notes};
    my $skills = $c->req->params->{skills};

    my $current_item = $c->model('DB::Team')->find($id);
    my $team_name_already_exists = $c->model('DB::Team')->search({
    		name => $name,
    		id => { "-not_in" => ($id)},
    		})->first();

    if ($team_name_already_exists) {

    		$c->stash({
    			error_msg => "A team with this name already exists. Please choose another name."
    			});
    		$c->go("edit");

    } else {

		unless ($daily_meeting_time =~ m/(1[012]|[1-9]):[0-5][0-9](\\s)?(?i)(am|pm)/ 
	    	or $planning_time =~ m/(1[012]|[1-9]):[0-5][0-9](\\s)?(?i)(am|pm)/ 
	    	or $retrospective_time =~ m/(1[012]|[1-9]):[0-5][0-9](\\s)?(?i)(am|pm)/ 
	    	or $planning_day =~ m/^((Monday)|(Tuesday)|(Wednesday)|(Thursday)|(Friday))$/
	    	or $retrospective_day =~ m/^((Monday)|(Tuesday)|(Wednesday)|(Thursday)|(Friday))$/) {
		    	$c->stash({
	    			error_msg => "One of the date/time validations don't pass."
	    			});
	    		$c->go("edit");
	    };    

	    $planning_time = $planning_time.",".$planning_day;
	    $retrospective_time = $retrospective_time.",".$retrospective_day;
	    

		my @words = split /,/, $skills;
		warn Data::Dumper::Dumper(@words);

	    my @existing_skills = $c->model('DB::TechnicalSkill')->search(
	    {
	    	technical_skill => { in => \@words },
	    },
	    {
	    	result_class => "DBIx::Class::ResultClass::HashRefInflator"
	    })->all();
	    warn Data::Dumper::Dumper(@existing_skills);
	    my @skill_ids;
	    my @not_found;
	    foreach my $skill (@existing_skills) {
	    	if ( grep $_ eq $skill->{technical_skill}, @words ) {
	    		push @skill_ids, $skill->{id};
	    		warn Data::Dumper::Dumper("found : ".$skill->{technical_skill});
	    	} else {
	    		warn Data::Dumper::Dumper($_);
	    		# @not_found = (grep $_ ne $skill->{technical_skill}, @words);
	    		# $c->stash->{informative_message} = "The sistem found "

	    	}
	    }

	    warn Data::Dumper::Dumper("NOT found : ");
	    warn Data::Dumper::Dumper(@not_found);
	    $current_item->update({
	    	name => $name,
	    	target_velocity => $velocity,
	    	days_in_iteration => $iteration,
	    	daily_meeting => $daily_meeting_time,
	    	sprint_planning => $planning_time,
	    	sprint_retrospective => $retrospective_time,
	    	notes => $notes,
	    	technical_skills_needed => \@skill_ids,
	    	});

	    $c->stash->{status_msg} = "The team is updated successfully";
	    $c->go("view_teams_for_this_user");
	}

}

sub add_members :Local {
	my ($self, $c) = @_;

	$c->stash(template => 'team/add_members.tt2');
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
