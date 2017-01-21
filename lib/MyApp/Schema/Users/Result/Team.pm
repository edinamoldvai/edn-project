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
);

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
  { "foreign.id" => "self.id_project" },
  { cascade_copy => 0, cascade_delete => 0 },
);

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
