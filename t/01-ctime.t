#!/usr/bin/perl
# Copyright (c) 2005 Jonathan T. Rockway

use Test::More tests=>8;
use File::CreationTime;

# test cached info
is(creation_time("t/test.file"), 123456, "creation time of known file");

# cleanup from last time, if necessary
unlink("/tmp/new.file");
unlink("/tmp/.new.file.creationtime");
ok(!-e "/tmp/.new.file.creationtime", "test file ctime record removal");
ok(!-e "/tmp/new.file", "test file removal");

# create a file
system("touch /tmp/new.file");
ok(-e "/tmp/new.file", "test file creation");

# make sure it doesn't have a creation time
ok(!-e "/tmp/.new.file.creationtime", "no previous creation time");

# record the ctime
ok(my $ctime = creation_time("/tmp/new.file"), "creation time didn't die");
ok(-e "/tmp/.new.file.creationtime", "created creation time file");

# change the mtime of the file by ... 2 seconds
sleep 2;
`echo Test >> /tmp/new.file`;

# see if creation_time works :)
is(creation_time("/tmp/new.file"), 
   $ctime, "creation time matched between tests");

# cleanup
unlink("/tmp/new.file");
unlink("/tmp/.new.file.creationtime");
