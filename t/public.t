use Mojo::Base -base;
use Mojolicious::Lite;
use Test::Mojo;
use Test::More;

# Test that the assets can be fetched like normal files

plugin 'FontAwesome4';

my $t = Test::Mojo->new;

for my $file (
  qw(
  /scss/font-awesome.scss
  /scss/font-awesome/_bordered-pulled.scss
  /scss/font-awesome/_core.scss
  /scss/font-awesome/_extras.scss
  /scss/font-awesome/_fixed-width.scss
  /scss/font-awesome/_icons.scss
  /scss/font-awesome/_larger.scss
  /scss/font-awesome/_list.scss
  /scss/font-awesome/_mixins.scss
  /scss/font-awesome/_path.scss
  /scss/font-awesome/_rotated-flipped.scss
  /scss/font-awesome/_spinning.scss
  /scss/font-awesome/_stacked.scss
  /scss/font-awesome/_variables.scss
  )
  )
{
  $t->get_ok($file)->status_is(200);
}

done_testing;
