use ExtUtils::MakeMaker;
# Time-stamp: "2003-10-10 17:04:25 ADT"
#
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile(
    'NAME'	=> 'I18N::LangTags',
    'VERSION_FROM' => 'lib/I18N/LangTags.pm', # finds $VERSION
    'ABSTRACT_FROM' => 'lib/I18N/LangTags.pm', # 
    'dist'        => { COMPRESS => 'gzip -6f', SUFFIX => 'gz', },
    
    (($] >= 5.007003) ?
     ('INSTALLDIRS' => 'perl') : ()),

);

package MY;

sub libscan
{ # Determine things that should *not* be installed
    my($self, $path) = @_;
    return '' if $path =~ m/~/;
    $path;
}

__END__
