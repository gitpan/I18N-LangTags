#
# Time-stamp: "1998-10-31 14:36:43 MST"
# Sean M. Burke <sburke@netadventure.net>
#
###########################################################################

package I18N::LangTags;
use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK $Debug $VERSION);
require 5.000;
require Exporter;
$Debug = 0;
@ISA = qw(Exporter);
@EXPORT = qw();
@EXPORT_OK = qw(is_language_tag same_language_tag
                extract_language_tags
                similarity_language_tag is_dialect_of);

$VERSION = "0.08";

=head1 NAME

I18N::LangTags - functions for dealing with RFC1766-style language tags

=head1 SYNOPSIS

    use I18N::LangTags qw(is_language_tag same_language_tag
                          extract_language_tags
                          similarity_language_tag is_dialect_of);

...or whatever of those function you want to import.  Those are
all the exportable functions -- you're free to import only some,
or none at all.  By default, none are imported.

If you don't import any of these functions, assume a C<&I18N::LangTags::>
in front of all the function names in the following examples.

=head1 DESCRIPTION

Language tags are a formalism, described in RFC 1766, for declaring
what language form (language and possibly dialect) a given chunk of
information is in.

This library provides functions for common tasks involving language
tags as they are needed in a variety of protocols and applications.

Please see the "See Also" references for a thorough explanation
of how to correctly use language tags.

=over

=cut

sub regularize_language_tag {
  #  For internal use.  Use only if you know what you're doing
  my($tag) = uc($_[0]); # uc it
  return undef unless &is_language_tag($tag);
  # If it's not a language tag, it's regularized form is undef

  $tag =~ s/^[xiXI]-//s; #lop off any leading x/i-
  return $tag;
}

###########################################################################

=item * the function is_language_tag($lang1)

Returns true iff $lang1 is a formally valid language tag.

   is_language_tag("fr")            is TRUE
   is_language_tag("x-jicarilla")   is FALSE
       (Subtags can be 8 chars long at most -- 'jicarilla' is 9)

   is_language_tag("i-Klikitat")    is TRUE
       (True without regard to the fact noone has actually
        registered Klikitat -- it's a formally valid tag)

   is_language_tag("fr-patois")     is TRUE
       (Formally valid -- altho descriptively weak!)

   is_language_tag("Spanish")       is FALSE
   is_language_tag("french-patois") is FALSE
       (No good -- first subtag has to match
        /^([xXiI]|[a-zA-Z]{2})$/ -- see RFC1766)

=cut

sub is_language_tag {
  my($tag) = lc($_[0]);

  return 0 if $tag eq "i" or $tag eq "x";
  # Bad degenerate cases the following
  #  regexp would erroneously let pass

  return $tag =~ 
    /^(?:  # First subtag
         [xi] | [a-z]{2}
      )
      (?:  # Subtags thereafter
         -           # separator
         [a-z]{1,8}  # subtag  
      )*
    $/xs ? 1 : 0;
}

###########################################################################

=item * the function extract_language_tags($whatever)

Returns a list of whatever looks like formally valid language tags
in $whatever.  Not very smart, so don't get too creative with
what you want to feed it.

  extract_language_tags("fr, fr-ca, i-mingo")
    returns:   ('fr', 'fr-ca', 'i-mingo')

  extract_language_tags("It's like this: I'm in fr -- French!")
    returns:   ('It', 'in', 'fr')
  (So don't just feed it any old thing.)

=cut

sub extract_language_tags {
  my($text) = $_[0];

  return grep(!m/^[ixIX]$/s, # 'i' and 'x' aren't good tags
    $text =~ 
    m/
      \b
      (?:  # First subtag
         [iIxX] | [a-zA-Z]{2}
      )
      (?:  # Subtags thereafter
         -           # separator
         [a-zA-Z]{1,8}  # subtag  
      )*
      \b
    /xsg
  );
}

###########################################################################

=item * the function same_language_tag($lang1, $lang2)

Returns true iff $lang1 and $lang2 are acceptable variant tags
representing the same language-form.

   same_language_tag('x-kadara', 'i-kadara')  is TRUE
      (The x/i- alternation doesn't matter)
   same_language_tag('X-KADARA', 'i-kadara')  is TRUE
      (...and neither does case)
   same_language_tag('en',       'en-US')     is FALSE
      (all-English is not the SAME as US English)
   same_language_tag('x-kadara', 'x-kadar')   is FALSE
      (these are totally unrelated tags)

=cut

sub same_language_tag {
  return  &regularize_language_tag($_[0])
       eq &regularize_language_tag($_[1]) ? 1 : 0;
}

###########################################################################

=item * the function similarity_language_tag($lang1, $lang2)

Returns an integer representing the degree of similarity between
tags $lang1 and $lang2 (the order of which does not matter), where
similarity is the number of common elements on the left,
without regard to case and to x/i- alternation.

   similarity_language_tag('fr', 'fr-ca')           is 1
      (one element in common)
   similarity_language_tag('fr-ca', 'fr-FR')        is 1
      (one element in common)

   similarity_language_tag('fr-CA-joual',
                           'fr-CA-PEI')             is 2
   similarity_language_tag('fr-CA-joual', 'fr-CA')  is 2
      (two elements in common)

   similarity_language_tag('x-kadara', 'i-kadara')  is 1
      (x/i- doesn't matter)

   similarity_language_tag('en',       'x-kadar')   is 0
   similarity_language_tag('x-kadara', 'x-kadar')   is 0
      (unrelated tags -- no similarity)

   similarity_language_tag('i-cree-syllabic',
                           'i-cherokee-syllabic')   is 0
      (no B<leftmost> elements in common!)

=cut

sub similarity_language_tag {
  my $lang1 = &regularize_language_tag($_[0]);
  my $lang2 = &regularize_language_tag($_[1]);

  return undef if !defined($lang1) and !defined($lang2);
  return 0 if !defined($lang1) or !defined($lang2);

  my @l1_subtags = split('-', $lang1);
  my @l2_subtags = split('-', $lang2);
  my $similarity = 0;

  while(@l1_subtags and @l2_subtags) {
    if(shift(@l1_subtags) eq shift(@l2_subtags)) {
      ++$similarity;
    } else {
      last;
    } 
  }
  return $similarity;
}

###########################################################################

=item * the function is_dialect_of($lang1, $lang2)

Returns true iff language tag $lang1 represents a subdialect of
language tag $lang2.

B<Get the order right!  It doesn't work the other way around!>

   is_dialect_of('en-US', 'en')            is TRUE
     (American English IS a dialect of all-English)

   is_dialect_of('en-US', 'en')            is TRUE
     (American English IS a dialect of all-English)

   is_dialect_of('fr-CA-joual', 'fr-CA')   is TRUE
   is_dialect_of('fr-CA-joual', 'fr')      is TRUE
     (Joual is a dialect of (a dialect of) French)

   is_dialect_of('en', 'en-US')            is FALSE
     (all-English is a NOT dialect of American English)

   is_dialect_of('fr', 'en-CA')            is FALSE

   is_dialect_of('en', 'en'   )            is TRUE
     (B<Note:> a degenerate case)

   is_dialect_of('i-mingo-tom', 'x-Mingo') is TRUE
     (the x/i thing doesn't matter, nor does case)

=cut

sub is_dialect_of {

  my $lang1 = &regularize_language_tag($_[0]);
  my $lang2 = &regularize_language_tag($_[1]);

  return undef if !defined($lang1) and !defined($lang2);
  return 0 if !defined($lang1) or !defined($lang2);

  return 1 if $lang1 eq $lang2;
  return 0 if length($lang1) < length($lang2);

  $lang1 .= '-';
  $lang2 .= '-';
  return
    (substr($lang1, 0, length($lang2)) eq $lang2) ? 1 : 0;
}

###########################################################################

=back

=head1 NOTE

This library may (probably will) need ammending if/when RFC1766 is
superceded.

=head1 SEE ALSO

* RFC 1766, C<ftp://ftp.isi.edu/in-notes/rfc1766.txt>, "Tags for the
Identification of Languages".

* RFC 2277, C<ftp://ftp.isi.edu/in-notes/rfc2277.txt>, "IETF Policy on
Character Sets and Languages".

* RFC 2231, C<ftp://ftp.isi.edu/in-notes/rfc2231.txt>, "MIME Parameter
Value and Encoded Word Extensions: Character Sets, Languages, and
Continuations".

* Locale::Codes, in
C<http://www.perl.com/CPAN/modules/by-module/Locale/>

* ISO 639, "Code for the representation of names of languages",
C<http://www.indigo.ie/egt/standards/iso639/iso639-1-en.html>

* The IANA list of registered languages (hopefully up-to-date),
C<ftp://ftp.isi.edu/in-notes/iana/assignments/languages/>

=head1 COPYRIGHT

Copyright (c) 1998 Sean M. Burke. All rights reserved.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 AUTHOR

Sean M. Burke <sburke@netadventure.net>

=cut

1;

__END__
