#!/usr/bin/perl -w
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'


use File::Copy;
use MP3::Tag;
use set_mp3v2tag;


copy("silence.mp3","test1.mp3");
$mp3 = MP3::Tag->new("test1.mp3");
$id3v2 = $mp3->new_tag("ID3v2");
$supptags = $id3v2->supported_frames();

for $t (keys %$supptags) {
    $tags{$t} = "test";
}
if (!set_mp3v2tag("test1.mp3",\%tags)) {
    print "Test 1: failed\n";
} else {
    open CAN, "<test1.mp3";
    $can = join '', <CAN>;
    close CAN;
    open REF, "<ref1.mp3";
    $ref = join '', <REF>;
    close REF;
    if ($can eq $ref) {
	print "Test 1: OK\n";
    } else {
	print "Test 1: failed\n";
    }
}

for $t (keys %$supptags) {
    $tags{$t} = "test2";
}
copy("test1.mp3","test2.mp3");
if (!set_mp3v2tag("test2.mp3",\%tags)) {
    print "Test 2: failed (execution)\n";
} else {
    open CAN, "<test2.mp3";
    $can = join '', <CAN>;
    close CAN;
    open REF, "<ref2.mp3";
    $ref = join '', <REF>;
    close REF;
    if ($can eq $ref) {
	print "Test 2: OK\n";
    } else {
	print "Test 2: failed (data compare)\n";
    }
}
unlink "test1.mp3";
unlink "test2.mp3";
exit;





