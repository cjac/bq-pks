package HKP::Handler::GnuPG;

use 5.006;

=head1 NAME

HKP::Handler::GnuPG - Handle requests from gpg command

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Quick summary of what the module does.

A little code snippet

    use HKP::Handler::GnuPG;

    my $h = HKP::Handler::GnuPG->new();
    ...

    $h->handle( { event => 'send-keys', env => $env } );

=head1 SUBROUTINES/METHODS

=head2 new

constructor

=cut

sub new {
  my( $class, $options ) = @_;

  my $self;
  if ( ref $class ) {
    $self = $class;
    $class = ref $class;
  }else{
    $self = bless({},$class);
  }

  return $self;
}


sub _send_keys {
  my( $self, $context ) = @_;
  my $env = $context->{env};
}

sub _recv_keys {

}

sub handle {
  my( $self, $context ) = @_;

  if ( $context->{event} eq 'send-keys' ) {
    $self->_send_keys( $context );
  }
  if ( $context->{event} eq 'recv-keys' ) {
    $self->_recv_keys( $context );
  }
}


1;
