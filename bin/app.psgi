#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Plack::Builder;

use MyApp;
use MyApp_frontend;


builder {
    enable 'CrossOrigin', origins => '*';
    
    mount '/api'   => MyApp->to_app;
    mount '/'      => MyApp_frontend->to_app;
}
