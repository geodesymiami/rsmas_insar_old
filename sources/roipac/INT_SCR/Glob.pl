;#		GLOB
;#
;#PURPOSE:
;#    Search directory for list of files
;#
;#SYNOPSIS (PERL):
;#    Glob($directory, $pattern) -> @files
;#
;#    where:
;#
;#	$directory	Directory to search.
;#	$pattern	Pattern required in filename(s).
;#
;#ACTION:
;#    GLOB enumerates files in specified directory and only
;#    returns those files with match the pattern.
;#
;#EXAMPLE:
;#	require "Glob.pl";
;#
;#	$where5 = "/usr2/jim/stan/aaot-swf/";
;#	@Files5 = Glob($where5,'L1A_.*$');
;#
;#NOTES:
;#
;#SOURCES:
;#    Glob.pl
;#
;#HISTORY:
;#    $Log: not supported by cvs2svn $
;#    Revision 1.1.1.1  2007/02/06 16:35:13  sbaker
;#    Importing ROI_PAC code for cvs control
;#

use strict;

sub Glob($$)
{
    my ($dir,$pat,$pat2);
    ($dir,$pat,$pat2) = @_;

    my @filenames;
    my $f;

    if ($dir ne "") {
	$dir .= '/';			# add trailing /
	$dir =~ s+//+/+g;		# remove multiple //'s
    }

    opendir(DIR,$dir.'.') || (warn("Can't open $dir: $!\n") || return);
    @filenames = readdir(DIR);
    closedir(DIR);

    # ignore certain files
    @filenames = grep(!/^\.$/, @filenames);
    @filenames = grep(!/^\.\.$/, @filenames);

    # select desired files
    if ($pat ne "") {
	@filenames = grep(/$pat/, @filenames);
    }
    if ($pat2 ne "") {
	@filenames = grep(/$pat2/, @filenames);
    }

    # sort resulting list
    @filenames = sort {$a cmp $b} @filenames;

    # fixup file names (add directory string)
    if ($dir ne "") {
	foreach $f (@filenames) {
	    $f =~ s/^/$dir/;
	}
    }
    return @filenames;
}

1;
