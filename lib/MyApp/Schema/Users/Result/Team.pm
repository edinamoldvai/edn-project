use utf8;
package MyApp::Schema::Users::Result::Team;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

MyApp::Schema::Teams::Result::Team

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

__PACKAGE__->load_components(qw/Numeric Core/); # Load the Numeric component

=head1 TABLE: C<Teams>

=cut

__PACKAGE__->table("Teams");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 target_velocity

  data_type: 'integer'
  is_nullable: 1

=head2 days_in_iteration

  data_type: 'integer'
  is_nullable: 1

=head2 daily_meeting

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 sprint_planning

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 sprint_retrospective

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 manager_id

  data_type: 'integer'
  is_nullable: 1

=head2 notes

  data_type: 'text'
  is_nullable: 1

=head2 no_of_ba

  data_type: 'integer'
  is_nullable: 1

=head2 no_of_dev

  data_type: 'integer'
  is_nullable: 1

=head2 no_of_qa

  data_type: 'integer'
  is_nullable: 1

=head2 ba_filled

  data_type: 'integer'
  is_nullable: 1

=head2 dev_filled

  data_type: 'integer'
  is_nullable: 1

=head2 qa_filled

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "target_velocity",
  { data_type => "integer", is_nullable => 1 },
  "days_in_iteration",
  { data_type => "integer", is_nullable => 1 },
  "daily_meeting",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "sprint_planning",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "sprint_retrospective",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "manager_id",
  { data_type => "integer", is_nullable => 1 },
  "notes",
  { data_type => "text", is_nullable => 1 },
  "no_of_ba",
  { data_type => "integer", is_nullable => 1 },
  "no_of_dev",
  { data_type => "integer", is_nullable => 1 },
  "no_of_qa",
  { data_type => "integer", is_nullable => 1 },
  "ba_filled",
  { data_type => "integer", is_nullable => 1 },
  "dev_filled",
  { data_type => "integer", is_nullable => 1 },
  "qa_filled",
  { data_type => "integer", is_nullable => 1 },
);

# Define 'simple' numeric cols, these will have some extra accessors & mutators
 #  created
 __PACKAGE__->numeric_columns(qw/no_of_qa no_of_ba no_of_dev ba_filled dev_filled qa_filled/);
  # Define min and max values for a column
 __PACKAGE__->numeric_columns(no_of_dev => {min_value => 0, max_value => 30});
 __PACKAGE__->numeric_columns(no_of_ba => {min_value => 0, max_value => 30});
__PACKAGE__->numeric_columns(no_of_qa => {min_value => 0, max_value => 30});
=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2016-11-26 20:46:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:M39iNRVtsduu/3Qa7ojkzg

__PACKAGE__->has_many(
  "employees",
  "MyApp::Schema::Users::Result::Employee",
  { "foreign.project_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 project_skill

Type: has_many

Related object: L<MyApp::Schema::Result::ProjectSkill>

=cut

__PACKAGE__->has_many(
  "project_skill",
  "MyApp::Schema::Users::Result::ProjectSkill",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 sprints

Type: has_many

Related object: L<MyApp::Schema::Result::Sprint>

=cut

__PACKAGE__->has_many(
  "sprint_team",
  "MyApp::Schema::Users::Result::Sprint",
  { "foreign.project_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 sprints

Type: has_many

Related object: L<MyApp::Schema::Result::EmployeePerformance>

=cut

__PACKAGE__->has_many(
  "id_project",
  "MyApp::Schema::Users::Result::EmployeePerformance",
  { "foreign.project_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
