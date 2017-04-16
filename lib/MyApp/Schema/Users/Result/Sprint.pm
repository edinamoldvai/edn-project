use utf8;
package MyApp::Schema::Users::Result::Sprint;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

MyApp::Schema::Users::Result::Role

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

=head1 TABLE: C<roles>

=cut

__PACKAGE__->table("sprints");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 project_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 start_date

  data_type: 'date'

=head2 end_date

  data_type: 'date'

=head2 sprint_title

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=cut

=head2 sprint_title

  data_type: 'text'
  is_nullable: 1

=cut

=head2 velocity

  data_type: 'int'
  is_nullable: 1
  size: 5

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "project_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "start_date",
  { date_type => "date" },
  "end_date",
  { date_type => "date" },
  "sprint_title",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "sprint_description",
  { data_type => "text" },
  "velocity",
  { data_type => "integer", is_nullable => 1, size => 5}
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2016-11-12 14:19:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:kfHKb1o1wvgpgMUDEB11oQ

=head2 employees

Type: has_many

Related object: L<MyApp::Schema::Users::Result::Sprint>

=cut

__PACKAGE__->belongs_to(
  "sprint_team",
  "MyApp::Schema::Users::Result::Team",
  { "foreign.id" => "self.project_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 employee_performance

Type: has_many

Related object: L<MyApp::Schema::Result::EmployeePerformance>

=cut

__PACKAGE__->has_many(
  "id_sprint",
  "MyApp::Schema::Users::Result::EmployeePerformance",
  { "foreign.sprint_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;

1;
