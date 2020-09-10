package MyApp;

use strict;
use warnings;

use Dancer2;
use JSON -convert_blessed_universally;
use Dancer2::Plugin::REST;
use Try::Tiny;
use Error::Return;
use Data::Dumper;
use Model;

#@TODO avoid leaking too much information on exceptions 

# Can't use Dancer2 JSON serializer as it can't convert blessed objects to 
# json (in this case from DBM::Deep)
# Ideally objects from Model should come unblessed but I couldn't found 
# any package to store data in memory shareable inter-process with locks without adding more 
# dependencies (I've tried IPC::Shareable but didn't work)
my $json = JSON->new->allow_nonref->convert_blessed;

# Still using using Dancer2 serializer when there is a exception thrown or any unblessed data
set engines => {
    serializer => {
        JSON => {
                pretty        => 1,                              
                allow_nonref  => 1,
                canonical     => 0,
                utf8          => 1,
        },
    },
};

set serializer => 'JSON';

get '/get_tx/:id' => sub {
    my $model = Model->new();    
    my $tx = $model->get_tx_by_id(params->{id});    
    if (!defined($tx)) {        
        return status_500 {'status' => 'ERROR', 'message' => 'Transaction not found'};                
    }
    send_as html => $json->encode($tx);
};

get '/balance' => sub {
    my $model = Model->new();
    $model->get_balance();
    
};

get '/transactions' => sub {
    my $model = Model->new();            
    send_as html => $json->encode($model->get_transactions());
    
};

post '/transaction' => sub {    
    my $post = from_json request->body;        
    my $amount = $post->{amount};
    my $type = $post->{type};
        
    my $model = Model->new();
    
    try {
        if ($type eq $model->TX_TYPE_CREDIT) {
            $model->credit($amount);
            
        } elsif ($type eq $model->TX_TYPE_DEBIT) {
            $model->debit($amount);
        }
    } catch {                        
        my $message = $_;        
        RETURN status_500 {'status' => 'ERROR', 'message' => $message};                
    };
        
    {'status' => 'OK'}

};

true;
