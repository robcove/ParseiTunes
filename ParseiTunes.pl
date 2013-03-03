#Parse your iTunes Library XML file
# by Rob 
#!/usr/bin/perl -w
use strict;
die "Usage: ParseiTunes.pl <path to iTunes XML file>\n" unless $ARGV[0];
my $library = $ARGV[0];

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

my @xml_songs = ($usable_xml =~ /<dict>(.*?)<\/dict>/sg) or die "Broken!\n"; # Another <dict> to traverse
my @songs; # Array of hashes for each song
for my $i (0 .. $#xml_songs) {
	my @keys = ($xml_songs[$i] =~ /<key>(.*?)<\/key>/g);
	my @values = ($xml_songs[$i] =~ /<key>.*?<\/key>.*?<.*?>(.*?)<\/.*?>/g);
	for my $j (0 .. $#keys) {
		$songs[$i]{$keys[$j]} = $values[$j]; # Populate the hash now, filter later?
	}
}
# Filter all the podcasts, audiobooks and TV shows
@songs = grep { $_->{Genre} ne "Podcast" } @songs;
@songs = grep { $_->{Genre} ne "Audiobook" } @songs;

my @shows = grep { exists $_->{Series} } @songs;
@songs = grep { !exists $_->{Series} } @songs;
# Sort by Artist
@songs = sort { lc($a->{Artist}) cmp lc($b->{Artist}) } @songs;

foreach my $song (@songs) {
  print "$song->{Artist} - $song->{Name} : $song->{Album} : $song->{Genre}\n";
}
# Create an array of all the keys
# Not using the @keys above because it may contain podcasts/audiobooks which use different fields
#my $song = $songs[0];
#my @keys = sort { lc($a) cmp lc($b) } keys %$song;
#foreach my $key (@keys) {
#  print "$key\n";
#}
print "\n";
print $#songs + 1 . " Total Tracks\n";
