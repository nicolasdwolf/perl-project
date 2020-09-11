#!/usr/bin/perl
{
package MyWebServer;
 
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use HTTP::Server::Simple::CGI;
use base qw(HTTP::Server::Simple::CGI);
use HTTP::Server::Simple::Static;
use Net::Server::PreFork;
use JSON -convert_blessed_universally;
use Try::Tiny;
use Error::Return;
use Data::Dumper;
use Cwd qw(cwd);
use Model;

my $json = JSON->new->allow_nonref->convert_blessed;
 
my $webroot = cwd . "/public";
 
my %dispatch = (    
    '/api/transactions' => \&resp_transactions,
    '/api/transaction' => \&resp_transaction,
    '/api/balance' => \&resp_balance,
    '/api/get_tx' => \&resp_get_tx
);
 
sub handle_request {
    my $self = shift;
    my $cgi  = shift;
   
    my $path = $cgi->path_info();
    my $handler = $dispatch{$path};
 
    if (ref($handler) eq "CODE") {
        try {
            my $response = $handler->($cgi);
            print "HTTP/1.0 200 OK\n";
            print $cgi->header;
            print $json->encode($response);            
        } catch {
            my $message = $_;        
            print "HTTP/1.0 500 Internal Error\n";
            print $cgi->header;
            print $json->encode({'status' => 'ERROR', 'message' => $message});                        
            print STDERR $message . "\n";
        }
                 
    } else {
        if (!$self->serve_static($cgi, $webroot)) {
        print "HTTP/1.0 404 Not found\r\n";
        print $cgi->header,
              $cgi->start_html('Not found'),
              $cgi->h1('Not found'),
              $cgi->end_html;
        }
    }
}

sub resp_transaction {
    my $cgi  = shift;   # CGI.pm object
    return if !ref $cgi;
    
    my $post = $json->decode($cgi->param('POSTDATA'));
        
    my $amount = $post->{amount};
    my $type = $post->{type};
        
    my $model = Model->new();
            
    try {
        if ($type eq $model->TX_TYPE_CREDIT) {
            $model->credit($amount);
            
        } elsif ($type eq $model->TX_TYPE_DEBIT) {
            $model->debit($amount);
        } else {
            die "Type invalid\n";
        }                        
    } catch {                                            
        die $_;    
    };
        
    return {'status' => 'OK'};
              
}


sub resp_balance {
    my $cgi  = shift;   # CGI.pm object
    return if !ref $cgi;
     

    my $model = Model->new();
    my $balance = $model->get_balance();
    
    return $balance;
}

sub resp_transactions {
    my $cgi  = shift;   # CGI.pm object
    return if !ref $cgi;
     
    my $model = Model->new();            
    return $model->get_transactions();    
}


sub resp_get_tx {
    my $cgi  = shift;   # CGI.pm object
    return if !ref $cgi;
     
    my $id = $cgi->param('id');
    
    my $model = Model->new();    
    my $tx = $model->get_tx_by_id($id);    
    if (!defined($tx)) {        
        die "Transaction not found\n";                
    }
    
    return $tx;
}


sub net_server { 'Net::Server::PreFork' }

}


 

my $pid = MyWebServer->new(5000);
$pid->run();


