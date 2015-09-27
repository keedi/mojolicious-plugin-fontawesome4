use Mojo::Base -base;
use Mojolicious;
use Test::Mojo;
use Test::More;

$ENV{PATH} = '/dev/null';    # make sure sass is not found

my $public = File::Spec->catdir(qw( t public ));
my $app    = Mojolicious->new(mode => 'production');
my $t      = Test::Mojo->new($app);

mkdir $public or plan skip_all => "Could not mkdir $public: $!";
$app->static->paths([$public]);
$app->plugin('FontAwesome4');
$app->routes->get('/test1' => 'test1');
$t->get_ok('/test1')->status_is(200)->element_exists('i.fa-user.fa-4x')
  ->text_like('style', qr{\.fa-google:before}, '.fa-google:before');

my $font    = $t->tx->res->dom->at('style')->text;
my $font_re = qr{"(\.\./fonts/fontawesome-webfont\.woff[^"]+)"};
like $font, $font_re, 'correct font path';

$font = $font =~ $font_re ? $1 : 'could-not-find-font-in-css';
$t->get_ok("/packed/$font")->status_is(200);

done_testing;

__DATA__
@@ test1.html.ep
%= asset 'font-awesome4.css' => { inline => 1 };
%= fa "user", "class" => "fa-4x"
