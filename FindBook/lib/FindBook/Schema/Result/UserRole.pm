use utf8;
package FindBook::Schema::Result::UserRole;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FindBook::Schema::Result::UserRole

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

__PACKAGE__->table("user");

__PACKAGE__->add_columns(
  "user_id",
  { data_type => "integer", is_nullable => 0 },
  "role_id",
  { data_type => "integer", is_nullable => 0 },
);

__PACKAGE__->set_primary_key("user_id", "role_id");
__PACKAGE__->belongs_to("user", "FindBook::Schema::Result::User", {"foreign.id" => "self.user_id"});
__PACKAGE__->belongs_to("role", "FindBook::Schema::Result::Role", {"foreign.id" => "self.role_id"});


# Created by DBIx::Class::Schema::Loader v0.07014 @ 2013-03-17 18:18:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:w/sWIS6d2VkGq3lFBjlXyg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
