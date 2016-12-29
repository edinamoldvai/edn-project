package MyApp::Controller::Department;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

MyApp::Controller::Department - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched MyApp::Controller::Department in Department.');
}

sub list :Local :Args(0) {
	my ($self, $c) = @_;

	my %dep_list = map {
		$_->id => $_->dname,
		} $c->model('DB::Department')->all();

	$c->stash({
		departments => \%dep_list,
		template => "department/list.tt2",
		});
}

sub view_employees_in_department :Local {
	my ($self, $c, $id) = @_;

	my $department = $c->model('DB::Department')->find($id);

	if ($department) {

		my @employees_in_department = $c->model('DB::Department')->search(
		{
			dname => $department->dname
		},
		{
			columns => [ qw(
                id
                dname
                employees.id
                employees.first_name
                employees.last_name
            )],
			join     => 'employees',
			result_class => 'DBIx::Class::ResultClass::HashRefInflator',
        })->all();

		my $employees;
		foreach my $entity (@employees_in_department) {
			
			$employees->{$entity->{employees}->{id}} = $entity->{employees}->{first_name}." ".$entity->{employees}->{last_name}
		}

		$c->stash({
			employees => $employees,
			template => "department/group.tt2"
			});

	} else {
		$c->stash({
			error_msg => "This department does not exist.",
			template => "department/list.tt2"
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
