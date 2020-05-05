#!/usr/bin/perl -w
use strict;

use Data::Dumper;
use Crypt::OpenPGP::KeyRing;
use URI;
use URL::Encode;
use lib 'lib';
use HKP::Handler::GnuPG;

my $handler = HKP::Handler::GnuPG->new();

my $app = sub {
  my $env = shift;

  print Data::Dumper::Dumper( $env );

  my $path_info = $env->{PATH_INFO};
  my $query_string = $env->{QUERY_STRING};

  if ( $env->{REQUEST_METHOD} eq 'GET' ) {
    if ( $path_info eq '/pks/lookup' ) {
      # handler for `gpg --recv-keys 0xBA27A83C`
      $handler->handle( { event => 'recv-keys', env => $env } );
    }
  } elsif ( $env->{REQUEST_METHOD} eq 'POST' ) {
    print "POST request received$/";

    my $max_len = 100_100_000;
    if ( $path_info eq '/pks/add' ) {
      print "path is /pks/add$/";

      if ( $env->{CONTENT_LENGTH} > $max_len ) {
	my $error = "that file is too long!";
	print "$error$/";
	return [ 500, [ 'Content-Type' => 'text/plain' ], [ $error ] ];
      }

      # handler for `gpg --send-keys 0xBA27A83C`
      $handler->handle( { event => 'send-keys', env => $env } );
    }
  }

  print "path_info: $path_info$/";
  return [ 200, ['Content-Type' => 'text/plain' ], [ 'Hello World' ] ];
};
