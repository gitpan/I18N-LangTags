use ExtUtils::MakeMaker;
# Time-stamp: "2004-03-30 21:38:40 AST"
#
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile(
    'NAME'	=> 'I18N::LangTags',
    'VERSION_FROM' => 'lib/I18N/LangTags.pm', # finds $VERSION
    'ABSTRACT_FROM' => 'lib/I18N/LangTags.pm', # 
    'dist'        => { COMPRESS => 'gzip -6f', SUFFIX => 'gz', },
    
   'PREREQ_PM'    => {	
                         $^O =~ m/Win32/i ? (
			    'Win32::Locale' => 0.01,
					   ) : (),
	             },
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
