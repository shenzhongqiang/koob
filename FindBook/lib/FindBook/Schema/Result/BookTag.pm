use utf8;
package FindBook::Schema::Result::BookTag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FindBook::Schema::Result::BookTag

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

__PACKAGE__->table("book_tag");

__PACKAGE__->add_columns(
  "book_id",
  { data_type => "integer", is_nullable => 0 },
  "tag_id",
  { data_type => "integer", is_nullable => 0 },
);

__PACKAGE__->set_primary_key("book_id", "tag_id");
__PACKAGE__->belongs_to("tag", "FindBook::Schema::Result::Tag", {"foreign.id" => "self.tag_id"});
__PACKAGE__->belongs_to("book", "FindBook::Schema::Result::Book", {"foreign.id" => "self.book_id"});


# Created by DBIx::Class::Schema::Loader v0.07014 @ 2013-03-17 18:18:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:w/sWIS6d2VkGq3lFBjlXyg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
