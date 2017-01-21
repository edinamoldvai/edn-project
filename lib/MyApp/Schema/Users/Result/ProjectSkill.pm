use utf8;
package MyApp::Schema::Users::Result::ProjectSkill;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

MyApp::Schema::Users::Result::ProjectSkill

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

__PACKAGE__->table("project_skill");

=head1 ACCESSORS

=head2 id_project

  data_type: 'integer'
  is_auto_increment: 0
  is_nullable: 0

=head2 id_skill

  data_type: 'integer'
  is_auto_increment: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id_project",
  { data_type => "integer", is_auto_increment => 0, is_nullable => 0 },
  "id_skill",
  { data_type => "integer", is_auto_increment => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id_project","id_skill");


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2016-11-12 14:19:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:kfHKb1o1wvgpgMUDEB11oQ


=head1 RELATIONS

=head2 id_project

Type: belongs_to

Related object: L<MyApp::Schema::Users::Result::Team>

=cut

__PACKAGE__->belongs_to(
  "id_project",
  "MyApp::Schema::Users::Result::Team",
  { id => "id_project" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 id_skill

Type: belongs_to

Related object: L<MyApp::Schema::Users::Result::TechnicalSkill>

=cut

__PACKAGE__->belongs_to(
  "id_skill",
  "MyApp::Schema::Users::Result::TechnicalSkill",
  { id => "id_skill" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
