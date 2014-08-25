use t::Helper;
use Cwd 'abs_path';
use File::Spec::Functions 'catdir';
use File::Basename 'dirname';
use Mojolicious;

mkdir 'lib/Mojolicious/Plugin/FontAwesome4/packed';
plan skip_all => "Could not create lib/Mojolicious/Plugin/FontAwesome4/packed: $!" unless -d "lib/Mojolicious/Plugin/FontAwesome4/packed";

for my $mode (qw( production development )) {
  my $app = Mojolicious->new(home => Mojo::Home->new(Cwd::abs_path('t')) );
  my $t = Test::Mojo->new($app);
  my ($css, $body);

  $app->mode($mode);
  $app->plugin('FontAwesome4');
  $app->routes->get('/' => sub {
    my $c = shift;
    $c->render(text => $c->asset('font-awesome4.css'));
  });

  plan skip_all => 'sass is not present' unless $app->asset->preprocessors->has_subscribers('scss');

  $t->get_ok('/')->status_is(200);
  $css = $t->tx->res->dom->at('link')->{href};

  $t->get_ok($css)
    ->status_is(200)
    ->content_like(qr{url\("\.\./fonts/fontawesome-webfont\.eot}, 'fontawesome-webfont.eot')
    ;

  my $font = $t->tx->res->body =~ m{url\("(\.\./fonts/fontawesome-webfont\.eot)} ? $1 : 'invalid/regex';
  $t->get_ok(join '/', dirname($css), $font)->status_is(200);

  shift @{ $app->static->paths };
  is int(@{ $app->static->paths }), 1, 'only one static path';
  
  opendir (my $DH, 't/public/packed') or die $!;
  for my $file (readdir $DH) {
    next unless $file =~ /\.css$/;
    unlink "lib/Mojolicious/Plugin/FontAwesome4/packed/$file";
    link "t/public/packed/$file", "lib/Mojolicious/Plugin/FontAwesome4/packed/$file" or die "link t/public/packed/$file: $!";
    unlink "t/public/packed/$file" or die "unlink t/public/packed/$file: $!";
  }

  $t->get_ok($css)->status_is(200);
}

done_testing;
