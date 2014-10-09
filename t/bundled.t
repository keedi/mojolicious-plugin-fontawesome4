use Mojo::Base -base;
use Mojolicious;
use Test::Mojo;
use Test::More;

$ENV{PATH} = '/dev/null';    # make sure sass is not found

my $app = Mojolicious->new(mode => 'production');
my $t = Test::Mojo->new($app);

$app->plugin('FontAwesome4');
$app->routes->get('/test1' => 'test1');
$t->get_ok('/test1')->status_is(200)->element_exists('i.fa-user.fa-4x')
  ->text_like('style', qr{\.fa-google:before}, '.fa-google:before');

done_testing;

__DATA__
@@ test1.html.ep
%= asset 'font-awesome4.css' => { inline => 1 };
%= fa "user", "class" => "fa-4x"
