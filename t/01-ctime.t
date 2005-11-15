#!/usr/bin/perl
# Copyright (c) 2005 Jonathan T. Rockway

use Test::More tests=>6;
use File::CreationTime;

is(creation_time("t/test.file"), 123456, "creation time of known file");

unlink("t/new.file");
unlink("t/.new.file.creationtime");
ok(!-e "t/new.file", "test file removal");
system("touch t/new.file");
ok(-e "t/new.file", "test file creation");

ok(!-e "t/.new.file.creationtime", "no previous creation time");
ok(creation_time("t/new.file"), "creation time didn't die");
ok(-e "t/.new.file.creationtime", "created creation time file");
unlink("t/new.file");
unlink("t/.new.file.creationtime");
