#!/usr/local/bin/perl -w

require 5; # Time-stamp: "2001-03-13 21:53:39 MST"
 # Sean M. Burke, sburke@cpan.org
 # This program is for generating the language_codes.txt file
use strict;
use LWP::Simple;
use HTML::TreeBuilder 3.10;
my $root = HTML::TreeBuilder->new();
my $url = 'http://lcweb.loc.gov/standards/iso639-2/bibcodes.html';
$root->parse(get($url) || die "Can't get $url");
$root->eof();

my @codes;

foreach my $tr ($root->find_by_tag_name('tr')) {
  my @f = map $_->as_text(), $tr->content_list();
  #print map("<$_> ", @f), "\n";
  next unless @f == 5;
  pop @f; # nix the French name
  next if $f[-1] eq 'Language Name (English)'; # it's a header line
  my $xx = splice(@f, 2,1); # pull out the two-letter code
  $f[-1] =~ s/^\s+//;
  $f[-1] =~ s/\s+$//;
  if($xx =~ m/[a-zA-Z]/) {   # there's a two-letter code for it
    push   @codes, [ lc($f[-1]),   "$xx\t$f[-1]\n" ];
  } else { # print the three-letter codes.
    if($f[0] eq $f[1]) {
      push @codes, [ lc($f[-1]), "$f[1]\t$f[2]\n" ];
    } else { # shouldn't happen
      push @codes, [ lc($f[-1]), "@f !!!!!!!!!!\n" ]; 
    }
  }
}

print map $_->[1], sort {; $a->[0] cmp $b->[0] } @codes;
print "[ based on $url\n at ", scalar(localtime), "]\n",
  "[Note: doesn't include IANA-registered codes.]\n";
exit;
__END__
