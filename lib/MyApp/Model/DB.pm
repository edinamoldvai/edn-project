package MyApp::Model::DB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'MyApp::Schema::Users',
    
    connect_info => {
        dsn => 'dbi:mysql:pandora',
        user => 'root',
        password => 'strawb3rry',
        quote_names => q{1},
    }
);

=head1 NAME

MyApp::Model::DB - Catalyst DBIC Schema Model

=head1 SYNOPSIS

See L<MyApp>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<MyApp::Schema::Users>

=head1 GENERATED BY

Catalyst::Helper::Model::DBIC::Schema - 0.65

=head1 AUTHOR

ubuntu

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;