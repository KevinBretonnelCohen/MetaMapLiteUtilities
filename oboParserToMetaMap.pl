#!/usr/bin/perl

# The ID of an OBO concept is its best unique key, as far as I know.
# So, let's always be checking to see if the ID is a new one or not--
# the ID being a new one is what lets us know that we have moved on 
# to a different concept.  
# Maybe the smoothest way to do that is to use it as the key to a hash
# in which we store everything?

# QUESTION: Can we use the OBO ID in place of a CUI?

# TODO: NEED TEST DATA

# USAGE: ./oboParserToMetaMap.pl infile ontology_abbreviation
# infile is a .obo file
# ontology_abbreviation is a string that you want added to output filenames. Examples: PRO, GO, CHEBI

use strict 'vars';

# set to 1 for debugging output, or to 0 to suppress it
my $DEBUG = 0;

my %everything = (); # wow, this will suck up a LOT of memory if the 
# ontology is big...
my $id = ""; # does this get used anymore??

# this cries out for OOP...


# hard-code input file OR read from command line
#my $oboInputFile = "/Users/transfer/Dropbox/a-m/Corpora/obo/craft-ontologies/CHEBI/CHEBI.obo";
# get the arguments off of the command line
my $oboInputFile = $ARGV[0];
my $ontology_abbreviation = $ARGV[1];

# validate that all command-line arguments were present
unless ($oboInputFile && $ontology_abbreviation) {
    die "Missing input filename or ontology abbreviation.\n";
}

#open (IN, $ARGV[0]) || die "Couldn't open ontology file $ARGV[0]: $!\n";
open (IN, $oboInputFile) || die "Couldn't open ontology file $oboInputFile: $!\n";

# output files...
#print gmtime();
#my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime(time);
my @timestamp = gmtime(time);

# year-month-day-hour-minute-second
my $outfile_timestamp = "$timestamp[5]-$timestamp[4]-$timestamp[3]-$timestamp[2]:$timestamp[1]:$timestamp[0]";
$DEBUG && print "DEBUG: $outfile_timestamp\n";

my $output_file_path = "/Users/transfer/Dropbox/Scripts-new/"; # change this if you're not me

my $MRCONSO_file_name = "MRCONSO" . $outfile_timestamp;
$MRCONSO_file_name = $output_file_path . $MRCONSO_file_name . $ontology_abbreviation;
my $MRSTY_file_name = "MRSTY" . $outfile_timestamp;
$MRSTY_file_name = $output_file_path . $MRSTY_file_name . $ontology_abbreviation;

open (MRCONSO, ">$MRCONSO_file_name") || die "Couldn't open MRCONSO output file $MRCONSO_file_name: $!\n";

open (MRSTY, ">$MRSTY_file_name") || die "Couldn't open MRSTY output file $MRSTY_file_name: $!\n";

while (my $line = <IN>) {
    chomp($line); # remove the newline or you get screwed at the end

    if ($line =~ /^id:\s+([A-Z].+)$/) {
	$id = $1;
	$DEBUG && print "DEBUG ID: <$id>\n";
    }

    if ($line =~ /^name: / || $line =~ /^synonym: /) {
	my $nameOrSynonym = extractNameOrSynonym($line);
	$DEBUG && print "DEBUG name or synonym: <$nameOrSynonym>\n";
	$DEBUG && print "DEBUG adding <$nameOrSynonym> to ID <$id>\n";
	$everything{$id}{$nameOrSynonym}++; # no worries if there are multiple identical synonyms, because each gets stored just once, since it's a key itself
    }
}


# PRODUCE MRCONSO.RRF FILE

my @ids = keys(%everything);
# the incredibly ugly "scalar @ids" returns the length of the id--
# doing it the obvious way was not working...
$DEBUG && print "DEBUG Number of unique IDs: ", scalar @ids, "\n";

# to make regression testing at least remotely possible,
# let's sort the keys...
@ids = sort(@ids);
$DEBUG && print "DEBUG first 10 IDs: first $ids[1], 25th $ids[25]\n";

# what we're doing here is producing the output format that's required 
# by the MRCONSO file.  
# that format has quite a few variables, so I'm  going to put 
# them in variables, in the hopes that it will be clear from the 
# names how they map to the elements of an MRCONSO entry.
# if they are fixed strings OR I hope that we don't have to worry
# about them OR if at the moment I flat-out don't know what their
# purpose is, then I'll initialize them here.

my $language = "ENG";
my $termStatus = "P"; # P for preferred, S for non-preferred (maybe for synonyms??)
my $LUI = "X1234567"; # not used, per documentation
my $stringType = "PF"; # fixed
my $sui = "A1234567"; # hopefully this doesn't get used!!! #HACK
my $isPref = "P"; # is this the same as $termStatus??
my $aui = "B1234567"; # hopefully we don't need this one, either 
my $saui = "C1234567"; # likewise 
my $scui; # pretty sure that this would be the ID from the OBO ontology
my $sdui = "D1234567"; # 
my $sab = "OBO"; # set separately for each ontology TODO: pass in on cmd line
my $termType = "OBO"; # not sure what this is meant for, but "OBO" seems reasonable for now 
my $code; # "Source Asserted ID"
my $string; # this will be the term, whether preferred, synonym, or whatever
my $sourceRestrictionLevel = "0"; 
my $suppress = "N"; # maybe you set this to Y for deprecated terms?? 
my $contentViewFlag = "1871"; # no clue! 

my $separator = "|";

foreach my $stored_id (@ids) {
    my @names_and_synonyms = keys($everything{$stored_id});
    foreach my $name_or_synonym (@names_and_synonyms) {
	$DEBUG && print "$stored_id $name_or_synonym\n";
	# the things that aren't fixed (so far)
	$scui = $stored_id;
	$string = $name_or_synonym; # TODO shouldn't I be validating this?
	$code = $stored_id;

	# build the output string for the MSCONSO file. 
	# just grind through stringing together all of
	# the variables, along with the official separator character...

	my $output = ""; # reinitialize or this will get totally out of control
	$output = $stored_id . $separator; 
	$output .= $language . $separator;
	$output .= $termStatus . $separator;
	$output .= $LUI . $separator;
	$output .= $stringType . $separator;
	$output .= $sui . $separator;
	$output .= $isPref . $separator;
	$output .= $aui . $separator;
	$output .= $saui . $separator;
	$output .= $scui . $separator; 
	$output .= $sdui . $separator;
	$output .= $sab . $separator;
	$output .= $termType . $separator;
	$output .= $code . $separator;
	$output .= $string . $separator;
	$output .= $sourceRestrictionLevel . $separator;
	$output .= $suppress . $separator;
	$output .= $contentViewFlag;

	print MRSTY (produceMRSTYfile($stored_id, $termType, $contentViewFlag) . "\n");
	print MRCONSO "$output\n";

	#$output .= $name_or_synonym . "|";
    }
}


# TODO: I think we might need for this to return some indication as to 
# whether or not this is a symptom...
# input: input line that contains a name or a synonym, probably
# with a bunch of other crap attached to it. So, we remove the
# other crap.
sub extractNameOrSynonym {

    # STATE OF THE WORLD: THIS ONLY RECOGNIZES NAMES AND SYNONYMS.
    # MAYBE MOVE ALL OF THE PROCESSING INTO A FUNCTION FOR HANDLING
    # THE CRUFF ON NAME AND SYNONYM LINES?
    # OK, DONE--THIS IS THAT FUNCTION!
    
    my $input = pop(@_);

    if ($input =~ /^name: / || $input =~ /^synonym: /) {
	my $label = $&;
	$input =~ s/$label//;
	$input =~ s/[A-Z]+ \[\]//; # whacks things like EXACT [] that tell you what kind of synonym it is
	$input =~ s/[A-Z]+ layperson \[\]//; # whacks things like EXACT [] that tell you what kind of synonym it is
	$input =~ s/[A-Z]+ \[.+\]//; # whacks things like EXACT [] that tell you what kind of synonym it is
	$input =~ s/[A-Z]+ layperson \[.+\]//; # whacks things like EXACT [] that tell you what kind of synonym it is
	$input =~ s/[A-Z]+ .+ \[.*\]//; # whacks things like EXACT [] that tell you what kind of synonym it is
#	$input =~ s/[A-Z]+ .+ \[.+\]//; # whacks things like EXACT [] that tell you what kind of synonym it is	


	# synonyms will also have double-quotes at the left and right edge--need to get rid of those
	if ($input =~ /^\W(.+)\W\$/) {
	    $input = $1; # the $1 variable holds whatever was between the parentheses in the regex--in other words, everything except for the double-quotes at the left and right edges of the term
	}

	# none of the preceding was working--let's try to brute-force this...
	$input =~ s/^"//;
	$input =~ s/"\s*$//;
	# what's left is (hopefully) the term
	
	#print "<$input>\n";
	#print "$input\n";
	$DEBUG && print "DEBUG name/synonym extraction: <$input>\n";
	return($input);
    }
} # close function definition: extract names/synonyms

# example line from the documentation:
# C0027051|T047|B2.2.1.2.1|Disease or Syndrome|AT32679180|3840|
# QUESTION: do I need to make sure that these are unique? I could
# put them in a hash.  TODO: check with Willie.
sub produceMRSTYfile {
    $DEBUG && print "In produceMRSTYfile() subroutine...\n";

    # these horrible variable names come more or less from the documentation---
    # trying to make this as easy as possible to understand from
    # the documentation, which unfortunately makes it hard to 
    # understand from the code...
    my $cui_mrsty = "";
    my $tui_mrsty = "";
    my $stn_mrsty = "";
    my $sty_mrsty = "";
    my $atui_mrsty = "";
    my $cvf_mrsty = "";

    $stn_mrsty = "A.1.2.3"; # dummy value--problem?
    $sty_mrsty = "CRAFTCONCEPT";
    $atui_mrsty = "E1234567";

    ($cui_mrsty, $tui_mrsty, $cvf_mrsty) = @_;

    my $mrsty_output = "";
    
    # $separator is hopefully global!
    $mrsty_output = $cui_mrsty . $separator . $tui_mrsty . $separator . $stn_mrsty . $separator . $atui_mrsty . $separator . $cvf_mrsty . $separator; # not sure why you need a separator at the end, but that's what the example in the documentation shows...

    $DEBUG && print "DEBUG MRSTY output: <$mrsty_output>\n";

    return($mrsty_output);
} # close function definition: MRSTY file production

