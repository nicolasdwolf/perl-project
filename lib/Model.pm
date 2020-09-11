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
 


sub new {
    my $class = shift;
    my $self = {
        _db => DBM::Deep->new( "foo.db" ) # This needs to be instantiated in each fork! or will start to fail 
    };
    
    return bless $self, $class;
}


sub credit {
    my ($self, $amount) = @_;
    
    $self->_common_checks($amount);
            
    $self->{_db}->lock_exclusive();
    
        
    $self->_add_balance($amount);
    sleep(1);
    $self->_add_transaction(TX_TYPE_CREDIT, $amount, time());    
    
    $self->{_db}->unlock();
    
}

sub get_balance {    
    my $self = shift;
    $self->{_db}->get('balance');
}

sub debit {
    my ($self, $amount) = @_;
    
    $self->_common_checks($amount);    
    
    if ($self->get_balance() < $amount) {
        die "Insufficient funds\n";
    }
        
    $self->{_db}->lock_exclusive();

    $self->_dec_balance($amount);            
    sleep(1);
    $self->_add_transaction(TX_TYPE_DEBIT, $amount, time());

    $self->{_db}->unlock();

}    
    
sub get_transactions {            
    my $self = shift;
    $self->{_db}->get('transactions');
} 
    
sub get_tx_by_id {
    my ($self, $tx_id) = @_;
    
    if (!looks_like_number($tx_id)) {
        die "Id must be a number\n";
    }
    
    my $txs = $self->{_db}->get('transactions');
    my ($tx) = grep { $_->{tx_id} == $tx_id } @$txs;    
    $tx;
}
    
sub _common_checks  {
    my ($self, $amount) = @_;
    
    if (!looks_like_number($amount)) {
        die "Amount must be a number\n";
    }
    
    if ($amount == 0) {
        die "Operation by 0 not allowed\n";
    }
            
}

sub _add_balance  {
    my ($self, $amount) = @_;  
    $self->{_db}->{balance} += $amount;
    
}

sub _dec_balance  {
    my ($self, $amount) = @_;
    $self->{_db}->{balance} -= $amount
}

sub _add_transaction  {
    #@TODO should test if lock is in place
    my ($self, $type, $amount, $timestamp) = @_;    
    my $t = $self->{_db}->get('transactions');
    my $d = {tx_id => $self->{_db}->get('tx_id'), type => $type, 'amount' => $amount, timestamp => $timestamp};    
    push @$t, $d;        
    $self->{_db}->{tx_id}++;
}
    
    
    
    

    
