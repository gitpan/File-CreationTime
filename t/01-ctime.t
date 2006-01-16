#!/usr/bin/perl
# Copyright (c) 2005 Jonathan T. Rockway

use Test::More tests=>3;
use File::CreationTime;

sub cleanup {
    unlink("new.file");
}

# cleanup from last time, if necessary
cleanup;

# create a file
open my $testfile, ">new.file";
print {$testfile} "hello, world\n";
close $testfile;

ok(-e "new.file", "test file creation");

# record the ctime
ok(my $ctime = creation_time("new.file"), "creation time didn't die");

# change the mtime of the file by ... 2 seconds
print {*STDERR} " (Sleeping 5 seconds)\n";
sleep 5;
open $testfile, ">new.file";
print {$testfile} "hello, world (again)\n";
close $testfile;

# see if creation_time works :)
is(creation_time("new.file"), 
   $ctime, "creation time matched between tests");

# cleanup
cleanup;
