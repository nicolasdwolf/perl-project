package Model;

use strict;
use warnings;

use DBM::Deep;
use Data::Dumper;
use Scalar::Util qw(looks_like_number);

 use constant {
    TX_TYPE_CREDIT  => 'credit',
    TX_TYPE_DEBIT   => 'debit'
};

    
my $db = DBM::Deep->new( "foo.db" );

$db->put('tx_id', 1);
$db->put('balance', 0);
$db->put('transactions', []);

    
my $_common_checks = sub {
    my $amount = shift;
    
    if (!looks_like_number($amount)) {
        die "Amount must be a number\n";
    }
    
    if ($amount == 0) {
        die "Operation by 0 not allowed\n";
    }
            
};

my $_add_balance = sub {
    my $amount = shift;        
    $db->{balance} += $amount;
    
};

my $_dec_balance = sub {
    my $amount = shift;    
    $db->{balance} -= $amount
};

my $_add_transaction = sub {
    #@TODO should test if lock is in place
    my ($type, $amount, $timestamp) = @_;    
    my $t = $db->get('transactions');
    push @$t, {tx_id => $db->get('tx_id'), type => $type, 'amount' => $amount, timestamp => $timestamp};        
    $db->{tx_id}++;
};   


sub new {
    my ($class, %args) = @_;    
    return bless { %args }, $class;
}


sub credit {
    my ($self, $amount) = @_;
    
    $_common_checks->($amount);
        
    $db->lock_exclusive();
        
    $_add_balance->($amount);
    sleep(1);
    $_add_transaction->(TX_TYPE_CREDIT, $amount, time());    
    
    $db->unlock();
}

sub get_balance {    
    $db->get('balance');
}

sub debit {
    my ($self, $amount) = @_;
    
    $_common_checks->($amount);    
    
    if ($self->get_balance() < $amount) {
        die "Insufficient funds\n";
    }
        
    $db->lock_exclusive();

    $_dec_balance->($amount);            
    sleep(1);
    $_add_transaction->(TX_TYPE_DEBIT, $amount, time());

    $db->unlock();

}    
    
sub get_transactions {            
    $db->get('transactions');
} 
    
sub get_tx_by_id {
    my ($self, $tx_id) = @_;
    
    if (!looks_like_number($tx_id)) {
        die "Id must be a number\n";
    }
    
    my $txs = $db->get('transactions');
    my ($tx) = grep { $_->{tx_id} == $tx_id } @$txs;    
    $tx;
}
    
    
    
    
    

    
