#!/usr/bin/perl -w

use strict;
use Carp;
use Symbol;
use MP3::Tag;

use vars qw(
	@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $REVISION
	%v1_to_v22_names
	%v1_to_v23_names
	%v2_to_v1_names
);

@ISA = 'Exporter';
@EXPORT = qw(
	set_mp3v2tag
);

$VERSION = '0.2';

=pod

=head1 NAME

MP3::Info::set_mp3v2tag - Set MP3 V2 tags for MP3-files

=head1 SYNOPSIS

Using a hashref

    #!perl -w
    use MP3::Info::set_mp3v2tag;

    my $file = "/tmp/music.mp3";
    my %tags;

    $tags{"TIT2"} = "Song title";
    $tags{"TPE1"} = "Who sings it";
	
    set_mp3v2tag($file,\%tst);

  You may also use V1 tag-names to set the corresponding V2 tags

    #!perl -w
    use MP3::Info::set_mp3v2tag;

    my $file = "/tmp/music.mp3";
    my %tags;

    $tags{"TITLE"} = "Song title";
    $tags{"ARTIST"} = "Who sings it";
	
    set_mp3v2tag($file,\%tst);

  Using comma-separated arguments
    #!perl -w
    use MP3::Info::set_mp3v2tag;

    my $file = "/tmp/music.mp3";
    set_mp3v2tag($file,"title","artist","album","2002","This is a test",
		      "genre", 0);

  Using an array or a list
    #!perl -w
    use MP3::Info::set_mp3v2tag;

    my $file = "/tmp/music.mp3";
    set_mp3v2tag($file, qw /TITLE ARTIST ALBUM 0000 COMMENT GENRE 0/);

=head1 AUTHOR

Benno Kardel, perlfan@justmail.de

I would like to thank Thomas Gefferts for his MP3::Tag module, which does
the ID3v2 tag writing on behalf of this wrapper. Also I would like to
thank Chris Nandor for his MP3::Info module which does a splendid job
(except that it cannot write ID3v2 tags) and is easy to use. Without that
module I would never have written this one.

=head1 DESCRIPTION

MP3::Info::set_mp3v2tag is only a little wrapper around Thomas Gefferts
MP3::Tag module. MP3::Info::set_mp3v2tag is mainly thought as an extension
to Chris Nandors MP3::Info module to which it adds support for writing
ID3v2 tags
 
=item set_mp3v2tag (FILE, TITLE, ARTIST, ALBUM, YEAR, COMMENT, GENRE [, TRACKNUM])

=item set_mp3v2tag (FILE, $HASHREF)

Adds/changes V2 tag information in an MP3 audio file.  Will clobber
any existing information in file.

Fields are TITLE, ARTIST, ALBUM, YEAR, COMMENT, GENRE (which indeed will
be converted to their corresponding ID3V23 fields). 

=head1 HISTORY

I was looking for a comfortable way to read and write ID3 tags
in PERL and found the MP3::Info package at CPAN which does quite
a good job.

Unfortunately it lacked support for writing ID3V2 tags.

So I looked again at CPAN and found the MP3::Tag package which 
supports it, but has a somewhat lower-level interface than MP3::Info.
My application was halfway written and already used 
MP3::Info::set_mp3_tag calls, so I wrote a little wrapper which 
provides the set_mp3v2tag routine quite similar to 
MP3::Info::set_mp3_tag.

I am far from being an expert in MP3-tags, and this little wrapper
completely relies on MP3::Tag and my - may be not so perfect - 
understanding of it. Still I hope there are no disastrous bugs 
in this software.

=head1 SUPPORTED ID3v2 tags

Since this little wrapper totally depends on Thomas Jeffert's 
MP3::Tag:ID3v2 you need to have a look at the MP3::Tag:ID3v2-Data 
man-page to find out which tags are actually supported.

=head1 SEE ALSO

MP3::Info, MP3::Tag, MP3::Tag::ID3v2, MP3::Tag::ID3v2-Data

=cut

# Keep emacs's PERL-mode happy (emacs screws up highlighting with a
#                               single apostroph)

sub set_mp3v2tag {
    my @argkeys = qw /TITLE ARTIST ALBUM YEAR COMMENT GENRE TRACKNUM/;
    my $id3v2;
    my %arghash;
    my $href;
    if (!ref($_[1])) {
	for (my $i = 0; $i <= $#argkeys; $i++) {
	    if (defined($_[$i+1])) {
		$arghash{$argkeys[$i]} = $_[$i+1];
            } else {
		if ($i != $#argkeys) {
		    warn "set_mp3v2tag: Error in arguments: No value for ".$argkeys[$i];
		    return undef;
		}
		print "DBG: $argkeys[$i]\n";
	    }
	} 
	$href = \%arghash;
    } else {
	$href = $_[1];
    }

    my $mp3 = MP3::Tag->new($_[0]);
    $mp3->get_tags;
    if (exists $mp3->{ID3v2}) {
	$id3v2 = $mp3->{ID3v2};
    } else {
	$id3v2 = $mp3->new_tag("ID3v2");
    }
    for my $v1n (keys %$href) {
        my $v23n;
	if (defined($v1_to_v23_names{$v1n})) {
	    $v23n = $v1_to_v23_names{$v1n};
	} else {
	    $v23n = $v1n;
	}
	if (defined($id3v2->change_frame($v23n,$$href{$v1n}))) {
	    my $info = $id3v2->get_frame($v23n);
	} else {
	    $id3v2->add_frame($v23n,$$href{$v1n});
	}
    }
    my $ret = $id3v2->write_tag();
    undef $mp3; # This is essential, otherwise tag-writing may be defered
                # until program exit !!
    return $ret; 
}

BEGIN {
%v1_to_v22_names = (
		   # v2.2 tags
		   'TITLE'    => 'TT2',
		   'ARTIST'   => 'TP1',
		   'ALBUM'    => 'TAL',
		   'YEAR'     => 'TYE',
		   'COMMENT'  => 'COM',
		   'TRACKNUM' => 'TRK',
		   'GENRE'    => 'TCO', # not clean mapping, but ...
		    );
%v1_to_v23_names = (
		   # v2.3 tags
		   'TITLE'    => 'TIT2',
		   'ARTIST'   => 'TPE1',
		   'ALBUM'    => 'TALB',
		   'YEAR'     => 'TYER',
		   'COMMENT'  => 'COMM',
		   'TRACKNUM' => 'TRCK',
		   'GENRE'    => 'TCON',
		    );

%v2_to_v1_names = (
		   # v2.2 tags
		   'TT2' => 'TITLE',
		   'TP1' => 'ARTIST',
		   'TAL' => 'ALBUM',
		   'TYE' => 'YEAR',
		   'COM' => 'COMMENT',
		   'TRK' => 'TRACKNUM',
		   'TCO' => 'GENRE', # not clean mapping, but ...
		   # v2.3 tags
		   'TIT2' => 'TITLE',
		   'TPE1' => 'ARTIST',
		   'TALB' => 'ALBUM',
		   'TYER' => 'YEAR',
		   'COMM' => 'COMMENT',
		   'TRCK' => 'TRACKNUM',
		   'TCON' => 'GENRE',
		   );

}

1;

__END__













#  LocalWords:  mp hashref perl TPE tst qw Benno Kardel Gefferts Nandors CPAN
#  LocalWords:  TRACKNUM
