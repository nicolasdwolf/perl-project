package MyApp_frontend;

use strict;
use warnings;

use Dancer2;

get '/' => sub {
    send_file 'index.html';
};

true;
