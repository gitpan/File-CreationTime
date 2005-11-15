package File::CreationTime;

use warnings;
use strict;

use Exporter;
our @ISA = 'Exporter';
our @EXPORT = qw(creation_time);
our @EXPORT_OK = qw(creation_time);

=head1 NAME

File::CreationTime - Keeps track of file creation times

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

Keeps track of creation times on UNIX filesystems that don't normally
provide such information.

    use File::CreationTime;

    my $file = "~/path/to/file";
    print "$file was created: ". creation_time($file). "\n";

Write access is required to the parent directory of the file
the first time creation_time is called.

=head1 EXPORT

=head2 create_time

Used like perl's builtin -C, but returns the creation time of a file
(in seconds past the epoch), not the inode change time.

=head1 FUNCTIONS

=head2 creation_time
     creation_time("/path/to/file")

Returns the creation time of /path/to/file in seconds past the epoch.
Requires write access to /path/to/file the first time the function is
called.

=cut

sub creation_time {
    my $filename = shift;
    die "$filename does not exist" if !-e $filename;
    
    my ($dir, $file, $ctime_file);
    
    # 'constants'
    my $FILENAME_CLASS = "[^\/]";                # class that matches filenames
    my $CREATION_TIME_PREFIX = ".";
    my $CREATION_TIME_SUFFIX = ".creationtime";

    if($filename =~ /($FILENAME_CLASS+)\/($FILENAME_CLASS+)$/){
	$dir = $1;
	$file = $2;
	$ctime_file = "$dir/$CREATION_TIME_PREFIX$file$CREATION_TIME_SUFFIX";
    }
    elsif ($filename =~ /^($FILENAME_CLASS+)$/){
	$dir = "";
	$file = $1;
	$ctime_file = "$CREATION_TIME_PREFIX$file$CREATION_TIME_SUFFIX";
    }
    else {
	die "Invalid path format ($filename)";
    }
    
    if(-e $ctime_file){ 
	open my $ctime_store, '<', $ctime_file or 
	  die "Error opening ctime file $ctime_file: $!";
	
	while(my $line = <$ctime_store>){
	    if($line =~ /^\d+$/){
		close $ctime_store;
		return int($line);
	    }
	}
	close $ctime_store;
    }

    # ctime file didn't exist or wasn't in the correct format
    
    # get the modification time of the file
    my $mtime = (stat($filename))[9];
    
    open my $ctime_store, '>', $ctime_file or
      die "Error opening ctime file $ctime_file: $!";
    
    print {$ctime_store} "$mtime\n" or die "Write error: $!";
    close $ctime_store;

    return $mtime;
}

=head1 ACCURACY

The algorithm used to determine the creation time is as follows.  The
first time creation_time is called, a file called
.[filename].creationtime is created in the same directory as filename.
This file contains the time that [filename] was most recently
modified.  As such, if you have a file that's several years old, then
modify it, then call creation_time, the file's creation time will
obviously be wrong.  However, if you create a file, call
creation_time, wait several years, modify the file, then call
creation_time again, the result will be accurate.

If you modify .[filename].creationtime, the result will be wrong.  The
module isn't magic, after all :)

=head1 DIAGNOSTICS

=head2 Invalid path format

This indicates that you passed a weird path to creation_time.  This is
a bug in my software -- please report exactly what path caused this
message.

=head2 [path] does not exist

You passed [path] to creation_time, but it doesn't exist (or you can't
read it).

=head2 Error opening ctime file [filename]

The OS returned an error when trying to open [filename].  Check permissions.

=head1 BUGS

If you delete [filename], then create a new file with the same name,
the old creation time will stick around.

If you create millions of files, call creation_time on them, then
remove them, the old creation_time data will waste disk space.  If
this is a problem, have a cron job remove them.

=head2 REPORTING

Please report any bugs or feature requests to
C<bug-file-creationtime@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=File-creationTime>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 AUTHOR

Jonathan T. Rockway, C<< <jon-cpan@jrock.us> >>

=head1 COPYRIGHT & LICENSE

Copyright 2005 Jonathan T. Rockway, all rights reserved.

This program is Free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of File::CreationTime
