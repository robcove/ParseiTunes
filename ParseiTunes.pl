# Parse your iTunes Library XML file
# by Rob 
#!/usr/bin/perl -w
use strict;

# Path to your iTunes Music Library XML file
my $library = 'iTunes Music Library.xml';

# Insert any of the available (or unlisted) fields you would like to use (not implemented)
my @fields = ( "Name", 
               "Artist", 
               "Album", 
               "Genre", 
               "Total Time", 
               "Track Number", 
               "Year", 
               "Date Added", 
               "Play Count", 
               "Play Date", 
               "Rating" );

open(XML, "$library") or die "Couldn't open iTunes XML file.\n";

undef $/; # This lets me read entire file into scalar instead of splitting by newline
my $usable_xml = <XML>;
close(XML);
$/ = "\n"; # Restore default behavior just in case

# Everything before Tracks is unimportant and Playlist support may be added later
if ($usable_xml =~ /Tracks<\/key>.*?<dict>(.*)<key>Playlists/s) {
	$usable_xml = $+;
}
else {
	die "Your iTunes XML file is messed up.\n";
}

#print "$usable_xml\n"; # debug

my @xml_songs = ($usable_xml =~ /<dict>(.*?)<\/dict>/sg) or die "Broken!\n"; # Another <dict> to traverse
my @songs; # Array of hashes for each song
for my $i (0 .. $#xml_songs) {
	my @keys = ($xml_songs[$i] =~ /<key>(.*?)<\/key>/g);
	my @values = ($xml_songs[$i] =~ /<key>.*?<\/key>.*?<.*?>(.*?)<\/.*?>/g);
	for my $j (0 .. $#keys) {
		$songs[$i]{$keys[$j]} = $values[$j]; # Populate the hash now, filter later?
	}
}
# Filter out all the podcasts and audiobooks
@songs = grep { $_->{Genre} ne "Podcast" } @songs;
@songs = grep { $_->{Genre} ne "Audiobook" } @songs;
# Sort by Artist
my @songs = sort { lc($a->{Artist}) cmp lc($b->{Artist}) } @songs;

foreach my $song (@songs) {
  print "$song->{Artist} - $song->{Name} : $song->{Album} : $song->{Genre}\n";
}

print "$#songs Total Tracks\n";
