use Mojolicious::Lite;
use if !$ENV{USE_FROM_SYSTEM}, qw( lib lib );

plugin 'FontAwesome4';
get '/' => 'index';

app->start;

__DATA__
@@ index.html.ep
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Font Awesome demo</title>
  %= asset "font-awesome4.css"
</head>
<body>
  %= fa "user", "data-whatever" => 123, class => "fa-4x"
</body>
</html>
