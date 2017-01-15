use utf8;
package MyApp::Schema::Users::Result::Employee;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

MyApp::Schema::Users::Result::Employee

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

=head1 TABLE: C<Employees>

=cut

__PACKAGE__->table("employees");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 first_name

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 last_name

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 hire_date

  data_type: 'date'
  is_nullable: 1

=head2 department

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 technical_skills

  data_type: 'text'
  is_nullable: 1

=head2 project_id

  data_type: 'int'
  is_nullable: 1
  size: 11

=head2 last_updated

  data_type: 'timestamp'
  is_nullable: 0

=head2 updated_by

  data_type: 'int'
  is_nullable: 0,
  size: 11

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "first_name",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "last_name",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "hire_date",
  { data_type => "date", is_nullable => 0 },
  "department",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "technical_skills",
  { data_type => "text", is_nullable => 1 },
  "project_id",
  { data_type => "integer", is_nullable => 1, size => 11 },
  "last_updated",
  { data_type => "timestamp", is_nullable => 0 },
  "updated_by",
  { data_type => "integer", is_nullable => 0, size => 11 },
);

=head1 PRIMARY KEY

=over 4

=item * L</user_id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2016-11-12 14:19:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:kfHKb1o1wvgpgMUDEB11oQ

=head2 department

Type: belongs_to

Related object: L<MyApp::Schema::Users::Result::Department>

=cut

__PACKAGE__->belongs_to(
  "department",
  "MyApp::Schema::Users::Result::Department",
  { id => "department" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 employee_skill

Type: has_many

Related object: L<MyApp::Schema::Result::EmployeeSkill>

=cut

__PACKAGE__->belongs_to(
  "team",
  "MyApp::Schema::Users::Result::Team",
  { id => "project_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 employee_skill

Type: has_many

Related object: L<MyApp::Schema::Result::EmployeeSkill>

=cut

__PACKAGE__->has_many(
  "employee_skill",
  "MyApp::Schema::Users::Result::EmployeeSkill",
  { "foreign.id" => "self.id_employee" },
  { cascade_copy => 0, cascade_delete => 0 },
);

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
