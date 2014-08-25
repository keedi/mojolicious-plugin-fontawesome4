package t::Helper;
use Mojo::Base -strict;
use Test::Mojo;
use Test::More;
use File::Basename ();
use File::Find;
use File::Path ();
use File::Spec::Functions qw( catdir catfile splitdir );
use constant DEBUG => $ENV{MOJO_FONTAWESOME_DEBUG} || 0;

my $base = catdir qw( lib Mojolicious Plugin FontAwesome4 );

sub copy {
  my $class = shift;

  find(
    {
      follow => 1,
      no_chdir => 1,
      wanted => sub {
        return unless -f;
        my $file = $_;
        my $name = File::Basename::basename($file);
        my $to_dir = $class->file_to_dir($file) or return;
        my $to_file = catfile $to_dir, $name;

        warn "[TEST] cp $file $to_file\n" if DEBUG;
        File::Path::make_path($to_dir) or die "mkdir $to_dir: $!" unless -d $to_dir;
        unlink $to_file if -e $to_file;
        link $file => $to_file or die "cp $file $to_file: $!";
        $class->rewrite_import($to_file) if $to_file =~ /font-awesome\.scss$/;
      },
    },
    'scss', 'fonts',
  );
}

sub file_to_dir {
  my ($class, $file) = @_;
  my @path = splitdir $file;

  pop @path unless -d $file;

  while (@path) {
    my $p = shift @path;
    last if $p eq 'stylesheets';
  }

  return catdir $base, 'scss', @path if $file =~ /font-awesome\.scss$/;
  return catdir $base, 'scss', 'font-awesome', @path if $file =~ /\.scss$/;
  return catdir $base, 'fonts', @path if $file =~ /\bfonts\b/;
  return;
}

sub rewrite_import {
  my ($class, $file) = @_;

  local @ARGV = ($file);
  local $^I = '';
  s!\@import\s+"([^"]+)"!\@import "font-awesome/$1"! and print while <>;
}

sub import {
  my $class = shift;
  my $caller = caller;

  strict->import;
  warnings->import;

  mkdir catdir qw( t public );
  mkdir catdir qw( t public packed );

  if (-d 'scss') {
    $base = catdir 'blib', $base if -d 'blib';
    mkdir $base;
    plan skip_all => "Could not create $base: $!" unless -d $base;
    $class->copy;
  }

  my $check = catfile $base, 'scss', 'font-awesome.scss';

  if (!-e $check) {
    plan skip_all => "$check does not exists. Cannot run tests";
  }

  eval qq[
    package $caller;
    use Test::More;
    use Test::Mojo;
    1;
  ] or die $@;
}

1;
