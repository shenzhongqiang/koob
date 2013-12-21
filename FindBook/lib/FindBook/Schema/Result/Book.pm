use utf8;
package FindBook::Schema::Result::Book;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FindBook::Schema::Result::Book

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

__PACKAGE__->table("book");

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "isbn",
  { data_type => "varchar", is_nullable => 0, size => 31 },
  "title",
  { data_type => "varchar", is_nullable => 1, size => 63 },
  "author",
  { data_type => "varchar", is_nullable => 1, size => 63 },
  "pic",
  { data_type => "varchar", is_nullable => 1, size => 31 },
  "description",
  { data_type => "text", is_nullable => 1},
  "rating",
  { data_type => "float", is_nullable => 1},
  "pubdate",
  { data_type => "varchar", is_nullable => 1, size => 15},
  "translator",
  { data_type => "varchar", is_nullable => 1, size => 63},
  "publisher",
  { data_type => "varchar", is_nullable => 1, size => 63},
  "pages",
  { data_type => "int", is_nullable => 1},
  "author_intro",
  { data_type => "text", is_nullable => 1},
);

__PACKAGE__->set_primary_key("id");
__PACKAGE__->has_many("book_tags", "FindBook::Schema::Result::BookTag", {"foreign.book_id" => "self.id"});
__PACKAGE__->many_to_many("tags", "book_tags", "tag");


# Created by DBIx::Class::Schema::Loader v0.07014 @ 2013-03-17 18:18:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:w/sWIS6d2VkGq3lFBjlXyg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
