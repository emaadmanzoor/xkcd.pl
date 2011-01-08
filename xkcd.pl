#!/usr/bin/perl

### xkcd.pl ###

# An xkcd webcomic grabber that downloads the entire
# bunch of xkcd to the current date to the $HOME/XKCD
# directory on its first run, and then fetches only the
# undownloaded comics on its subsequent runs.

# Author: Emaad Ahmed Manzoor, etc.

# COMMENT # 
# I've lost the sources/inspiration for the code here due
# to which I'm unable to give the due credit and attributions,
# so I'll just enclose the changes I've made in EDIT tags and
# hope the original coders own up some day, when this gets real
# popular and all.

# EDIT: EMAAD

# Requirements:
# Perl
# imagemagick
# wget

# /EDIT: EMAAD

use LWP::Simple;
#  use Smart::Comments;

## Objectives ##

#  Download all comics from xkcd.com
#  Ability to download new comics
#  Download ALT text
#  Saved in: ~/Desktop

# Set Specifics
$sitePrefix = "http://xkcd.com/";

## Path to main XKCD directory ##
$path = "$ENV{HOME}/";


mkdir "$path/XKCD", 0755 or print "XKCD Directory Exists\n";
chomp($path = "$path/XKCD");

$d = get($sitePrefix);
if ($d =~ /http:\/\/xkcd.com\/(\d+)\//) {
    $current = $1;
}

# Obtains all individual comic data
sub getComicData {
    my $siteData = get("$sitePrefix$current/");
    my @data = split /\n/, $siteData;
    foreach (@data) {
        if (/http:\/\/xkcd.com\/(\d+)\//) {
            $current = $1;
        }
        if (/src="(http:\/\/imgs.xkcd.com\/comics\/.+\.\w{3})"/) {
            $currentUrl = $1;
            if (/alt="(.+?)"/) {
                $title = $1;
            $title = "House of Pancakes" if $current == 472;  # Color title on comic 472 with weird syntax
            }
            if (/title="(.+?)"/) {    #title commonly know as 'alt' text
                $alt = $1;
            }
        }
    }
}

chdir "$path" or die "Cannot change directory: $!";
&getComicData();
while ( get("$sitePrefix$current/")){ ### Writing Files $current: $title
    print "Downloading Image $current: $title\n";
    
    #EDIT: EMAAD
    
    #Create directories for individual comics
    #mkdir "$current $title", 0755 or die "Previously Downloaded";
    #chdir "$path/$current $title" or die "Cannot change directory: $!";
	
	#EMAAD: Replace spaces with _
	$title =~ s/ /_/g;
	
	#EMAAD: Remove special characters
	$title =~ s/\W//g;
	
    # Save image file
    $image = get($currentUrl);
    open my $IMAGE, '>>', "$title.png"
        or die "Cannot create file!";
    print $IMAGE $image;
    close $IMAGE;

	#Clean up alt
	$alt =~ s/\&\#39;/\'/g;	#replace single quotes
	$alt =~ s/\&quot;/\\\"/g;	#replace double quotes
	$alt =~ s/\-\-/\-/g; #replace --
	
    # Save alt text to a text file (uncomment this if you want)
    #open my $TXT, '>>', "$title ALT.txt"
    #   or die "Cannot create file!";
    #print $TXT $alt;
    #close $TXT;
    
    # Save alt text into the image as a caption
    # USES: imagemagick
    $ext = "png";
	my $pic_details = `identify $title.$ext`;
	$pic_details =~ /$title.$ext [A-Z]+ (\d+x\d+) /;
	$size = $1;
	
	$size =~ /(\d+)/;
	$width=$1;
	$overlay_size = $width."x"."30";
	
	print "Writing ALT Text $current: $title\n";
	system("convert $title.$ext -background white -fill black -gravity center -size $overlay_size caption:\"$alt\" -append $title.$ext");
	
	# /EDIT: EMAAD
	
    #chdir "$path" or die "Cannot change directory: $!";
    $current--;
	
    # Check for non existent 404 comic
    $current-- if $current == 404;

    &getComicData();
}


# End Gracefully
print "Download Complete\n"
