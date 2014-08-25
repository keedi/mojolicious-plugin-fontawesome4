use t::Helper;

use Mojolicious::Lite;
plugin 'FontAwesome4';

my $t = Test::Mojo->new;

for my $file (qw(
  /fonts/FontAwesome.otf
  /fonts/fontawesome-webfont.svg
  /fonts/fontawesome-webfont.woff
  /fonts/fontawesome-webfont.ttf
  /fonts/fontawesome-webfont.eot
  /scss/font-awesome/_variables.scss
  /scss/font-awesome.scss
)) {
  $t->get_ok($file)->status_is(200);
}

done_testing;
