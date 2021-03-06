use utf8;
package MyApp::Schema::Users::Result::Department;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

MyApp::Schema::Users::Result::Department

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

=head1 TABLE: C<Departments>

=cut

__PACKAGE__->table("departments");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 dname

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "dname",
  { data_type => "varchar", is_nullable => 0, size => 100 }
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<dname>

=over 4

=item * L</dname>

=back

=cut

__PACKAGE__->add_unique_constraint("dname", ["dname"]);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2016-11-12 14:19:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:kfHKb1o1wvgpgMUDEB11oQ

=head2 employees

Type: has_many

Related object: L<MyApp::Schema::Users::Result::Employee>

=cut

__PACKAGE__->has_many(
  "employees",
  "MyApp::Schema::Users::Result::Employee",
  { "foreign.department" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
