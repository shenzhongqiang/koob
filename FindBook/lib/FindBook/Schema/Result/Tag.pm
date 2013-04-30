use utf8;
package FindBook::Schema::Result::Tag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FindBook::Schema::Result::Tag

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

__PACKAGE__->table("tag");

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "catalog",
  { data_type => "varchar", is_nullable => 0, size => 31 },
  "subcat",
  { data_type => "varchar", is_nullable => 0, size => 31 },
);

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07014 @ 2013-03-17 18:18:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:w/sWIS6d2VkGq3lFBjlXyg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
