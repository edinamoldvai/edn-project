package MyApp::Controller::Account;
use Moose;
use namespace::autoclean;
use utf8;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

MyApp::Controller::Accounts - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

# sub index :Path('/') :Args(0) {
#     my ( $self, $c ) = @_;

#     # will show current sprint status
#     my @sprints = $c->model("DB::Sprint")->search(
#         {},
#         {
#             join => "sprint_team",
#             '+select' => ['sprint_team.target_velocity'],
#             '+as'     => ['sprint_team_target_velocity'],
#             order_by => { "-desc" => "end_date" },
#             result_class => "DBIx::Class::ResultClass::HashRefInflator",
#         })->all();
#     warn Data::Dumper::Dumper(\@sprints);
    
#     $c->stash(template => 'index.tt2');
# }


# =head2 index

# =cut

# sub list :Path('/') :Args(0) {
#     my ( $self, $c ) = @_;

#     $c->stash(template => 'page.tt2');
# }
=encoding utf8

=head1 AUTHOR

ubuntu,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
