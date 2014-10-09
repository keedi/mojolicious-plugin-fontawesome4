use Mojo::Base -base;
use Mojolicious;
use Mojolicious::Plugin::FontAwesome4;
use Test::More;
use File::Basename;
use File::Copy;
use File::Find;
use File::Path qw( make_path remove_tree );

plan skip_all => 'Cannot copy files without font-awesome.scss' unless -r 'scss/font-awesome.scss';

my $CAN_SASS = do {
  my $app = Mojolicious->new;
  $app->plugin('AssetPack');
  $app->asset->preprocessors->can_process('scss');
};

my $BASE = 'lib/Mojolicious/Plugin/FontAwesome4';
mkdir $BASE or die "mkdir $BASE: $!" unless -d $BASE;

remove_tree "$BASE/$_" for qw( fonts scss );
remove_tree "$BASE/packed" if $CAN_SASS;

find(
  {
    follow   => 0,
    no_chdir => 1,
    wanted   => sub {
      return if -d $File::Find::name;
      return if $File::Find::name =~ /\bless\b/;
      my $dest = dest($File::Find::name) or return diag "No destination for $File::Find::name";
      my $dir = dirname($dest);
      make_path($dir) or die "mkdir $dir: $!" unless -d $dir;
      copy $File::Find::name => $dest or die "cp $File::Find::name $dest: $!";
    },
  },
  'scss',
  'font',
);

ok -e "$BASE/scss/font-awesome.scss", "font-awesome.scss";

{
  diag 'Modify import statements in font-awesome.scss';
  local @ARGV = ("$BASE/scss/font-awesome.scss");
  local $^I   = '';
  while (<>) {
    s!import "([^"]+)"!import "font-awesome/$1"!;
    print;    # print back to same file
  }
}

SKIP: {
  skip 'Sass is required', 1 unless $CAN_SASS;
  my $app = Mojolicious->new;
  $app->mode('production');
  $app->static->paths([Mojolicious::Plugin::FontAwesome4->asset_path]);
  $app->plugin('FontAwesome4');
  is_deeply [packed_files()], [qw( font-awesome4.css )], 'packed for production';
}

SKIP: {
  skip 'Sass is required', 1 unless $CAN_SASS;
  my $app = Mojolicious->new;
  $app->static->paths([Mojolicious::Plugin::FontAwesome4->asset_path]);
  $app->mode('development');
  $app->plugin('FontAwesome4');
  is_deeply [packed_files()], [qw( font-awesome.css font-awesome4.cs font-awesome4.csss )], 'packed for development';
}

done_testing;

sub dest {
  my $file = $_[0];
  my $name = basename $file;

  return "$BASE/scss/font-awesome.scss"  if $name eq 'font-awesome.scss';
  return "$BASE/scss/font-awesome/$name" if $name =~ /^_.*\.scss$/;
  return "$BASE/font/$name"              if $file =~ /\bfonts\b/;
  return;
}

sub packed_files {
  sort map { s!-\w+\.(\w+)$!.$1!; basename $_ } glob "$BASE/packed/*";
}
