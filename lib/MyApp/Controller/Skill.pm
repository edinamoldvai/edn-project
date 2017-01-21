package MyApp::Controller::Skill;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

MyApp::Controller::Skill - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched MyApp::Controller::Skill in Skill.');
}

sub list :Local :Args(0) {
	my ($self, $c) = @_;

	my %skill_list = map {
		$_->id => $_->technical_skill,
		} $c->model('DB::TechnicalSkill')->all();

	$c->stash({
		skills => \%skill_list,
		template => "skill/list.tt2",
		});
}

sub view_employees_with_skill :Local {
	my ($self, $c, $id) = @_;

	my $skill = $c->model('DB::TechnicalSkill')->find($id);

	if ($skill) {

		my @employees_with_skill = $c->model('DB::EmployeeSkill')->search(
	        {
	            'me.id_skill' => $id,
	        },
	        {
	            join    => ['id_employee'],
	            columns => [ { id => 'id_employee.id' },
	            			 { first_name => 'id_employee.first_name' },
	            			 { last_name => 'id_employee.last_name'} ],
	            result_class => 'DBIx::Class::ResultClass::HashRefInflator',
	        },
	    );

	    my %employees = map {
	            $_->{id} => "$_->{first_name} $_->{last_name}",
	        } @employees_with_skill;

	    $c->stash({
	    	employees => \%employees,
			template => "skill/group.tt2"
			});

	} else {
		$c->stash({
			error_msg => "This technical skill does not exist.",
			template => "skill/list.tt2"
			});
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
