package Mojolicious::Plugin::FontAwesome4;

=head1 NAME

Mojolicious::Plugin::FontAwesome4 - Mojolicious + http://fortawesome.github.io/Font-Awesome/

=head1 VERSION

4.2004

=head1 DESCRIPTION

L<Mojolicious::Plugin::FontAwesome4> is used a L<Mojolicious> plugin to simpler include
L<http://fortawesome.github.io/Font-Awesome/> CSS and font files into your project.

This is done with the help of L<Mojolicious::Plugin::AssetPack>.

=head1 SYNOPSIS

=head2 Mojolicious::Lite

  use Mojolicious::Lite;
  plugin 'FontAwesome4';
  get '/' => 'index';
  app->start;

=head2 Template

  <!DOCTYPE html>
  <html lang="en">
  <head>
    %= asset "font-awesome4.css"
  </head>
  <body>
    %= fa "user", "class" => "fa-4x"
  </body>
  </html>

=cut

use Mojo::Base 'Mojolicious::Plugin';
use File::Spec::Functions 'catdir';
use Cwd ();

our $VERSION = '4.2004';

=head1 HELPERS

=head2 fa

Insert a L<FontAwesome|http://fortawesome.github.io/Font-Awesome/icons/> icons.
Example:

  # this...
  <%= fa "bars", class => "fa-4x", id => "abc" %>
  # turns into...
  <i class="fa fa-bars fa-4x" id="abc"></i>

=head1 METHODS

=head2 asset_path

  $path = Mojolicious::Plugin::FontAwesome4->asset_path($type);
  $path = $self->asset_path($type);

Returns the base path to the assets bundled with this module.

Set C<$type> to "sass" if you want a return value that is suitable for
the C<SASS_PATH> environment variable.

=cut

sub asset_path {
  my ($class, $type) = @_;
  my $path = Cwd::abs_path(__FILE__);

  $path =~ s!\.pm$!!;

  return join ':', grep {$_} catdir($path, 'scss'), $ENV{SASS_PATH} if $type and $type eq 'sass';
  return $path;
}

=head2 register

  $app->plugin("FontAwesome4");

See L</SYNOPSIS>.

=cut

sub register {
  my ($self, $app, $config) = @_;
  my $helper = $config->{helper} || 'fa';

  $config->{css} ||= [qw( font-awesome.scss )];

  $app->helper($helper => \&_fa);
  $app->plugin('AssetPack') unless eval { $app->asset };

  push @{$app->static->paths}, $self->asset_path;

  if (@{$config->{css}}) {
    $app->asset('font-awesome4.css' => map {"/scss/$_"} @{$config->{css}});
  }
}

sub _fa {
  my ($c, $icon) = (shift, shift);
  my @class = ("fa", "fa-$icon");
  my @args;

  while (my $arg = shift) {
    push @class, shift and next if $arg eq 'class';
    push @args, $arg;
  }

  $c->tag('i', class => join(' ', @class), @args, sub {''});
}

=head1 CREDITS

L<FontAwesome|http://fortawesome.github.io/Font-Awesome/> is created by
L<Dave Gandy|http://twitter.com/davegandy>.

=head1 LICENSE

FontAwesome is licensed under L<SIL OFL 1.1|http://scripts.sil.org/OFL>.

L<Mojolicious::Plugin::FontAwesome4> is licensed under Artistic License
version 2.0 and so is this code.

=head1 AUTHOR

Jan Henning Thorsen - C<jhthorsen@cpan.org>

=cut

1;
