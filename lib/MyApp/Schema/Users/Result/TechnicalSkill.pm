use utf8;
package MyApp::Schema::Users::Result::TechnicalSkill;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

MyApp::Schema::Users::Result::TechnicalSkill

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

=head1 TABLE: C<Users>

=cut

__PACKAGE__->table("technical_skills");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 technical_skill

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "technical_skill",
  { data_type => "varchar", is_nullable => 0, size => 45 }
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<technical_skill>

=over 4

=item * L</technical_skill>

=back

=cut

__PACKAGE__->add_unique_constraint("technical_skill", ["technical_skill"]);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2016-11-12 14:19:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:kfHKb1o1wvgpgMUDEB11oQ

=head1 RELATIONS

=head2 employee_skill

Type: has_many

Related object: L<MyApp::Users::Schema::EmployeeSkill>

=cut

__PACKAGE__->has_many(
  "employee_skill",
  "MyApp::Schema::Users::Result::EmployeeSkill",
  { "foreign.id" => "self.id_skill" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 project_skill

Type: has_many

Related object: L<MyApp::Users::Schema::ProjectSkill>

=cut

__PACKAGE__->has_many(
  "project_skill",
  "MyApp::Schema::Users::Result::ProjectSkill",
  { "foreign.id" => "self.id_skill" },
  { cascade_copy => 0, cascade_delete => 0 },
);

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;

1;
