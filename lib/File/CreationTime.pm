package File::CreationTime;

use warnings;
use strict;
use File::ExtAttr qw(getfattr setfattr);

use Exporter;
our @ISA = 'Exporter';
our @EXPORT = qw(creation_time);
our @EXPORT_OK = qw(creation_time);

=head1 NAME

File::CreationTime - Keeps track of file creation times

=head1 VERSION

Version 2.00

=cut

our $VERSION = '2.00';

=head1 SYNOPSIS

Keeps track of creation times on UNIX filesystems that don't normally
provide such information.

    use File::CreationTime;

    my $file = "~/path/to/file";
    print "$file was created: ". creation_time($file). "\n";

Your filesystem need to support extended filesystem attributes, and
you need to be able to write the target file.

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
    my $ATTRIBUTE = "user.creation_time"; # use user.* to appease Linux

    die "$filename does not exist" if !-e $filename;
    
    my $ctime = getfattr($filename, $ATTRIBUTE);
    
    return $ctime if(defined $ctime);
    
    # no ctime attr?  create one.
    my $mtime = (stat($filename))[9];
    setfattr($filename, $ATTRIBUTE, $mtime) or 
      die "Failed to set attribute $ATTRIBUTE on $filename";

    return $mtime;
}

=head1 ACCURACY

The algorithm used to determine the creation time is as follows.  The
first time creation_time is called, an extended filesystem attribute
called creation_time is created and is set to contain the time that
[filename] was most recently modified.  As such, if you have a file
that's several years old, then modify it, then call creation_time, the
file's creation time will obviously be wrong.  However, if you create
a file, call creation_time, wait several years, modify the file, then
call creation_time again, the result will be accurate.


=head1 DIAGNOSTICS

=head2 Invalid path format

This indicates that you passed a weird path to creation_time.  This is
a bug in my software -- please report exactly what path caused this
message.

=head2 [path] does not exist

You passed [path] to creation_time, but it doesn't exist (or you can't
read it).

=head2 Failed to set attribute user.creation_time on [file]

Couldn't create the attribute for some reason.  Does your filesystem
support extended filesystem attributes?

=head1 BUGS

Doesn't work on antiquated OSes that don't support extended filesystem
attributes.  Use an older version (1.xx) of this module if you need that.

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
