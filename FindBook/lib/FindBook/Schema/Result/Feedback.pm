use utf8;
package FindBook::Schema::Result::Feedback;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FindBook::Schema::Result::Feedback

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

=head1 TABLE: C<feedback>

=cut

__PACKAGE__->table("feedback");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 index_open_time

  data_type: 'varchar'
  is_nullable: 1
  size: 31

=head2 search_resp_time

  data_type: 'varchar'
  is_nullable: 1
  size: 31

=head2 search_result_quality

  data_type: 'varchar'
  is_nullable: 1
  size: 31

=head2 ui_quality

  data_type: 'varchar'
  is_nullable: 1
  size: 31

=head2 other_suggestions

  data_type: 'text'
  is_nullable: 1

=head2 source_ip

  data_type: 'varchar'
  is_nullable: 1
  size: 31

=head2 ts

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "index_open_time",
  { data_type => "varchar", is_nullable => 1, size => 31 },
  "search_resp_time",
  { data_type => "varchar", is_nullable => 1, size => 31 },
  "search_result_quality",
  { data_type => "varchar", is_nullable => 1, size => 31 },
  "ui_quality",
  { data_type => "varchar", is_nullable => 1, size => 31 },
  "other_suggestions",
  { data_type => "text", is_nullable => 1 },
  "source_ip",
  { data_type => "varchar", is_nullable => 1, size => 31 },
  "ts",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07014 @ 2013-03-17 18:18:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:w/sWIS6d2VkGq3lFBjlXyg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
