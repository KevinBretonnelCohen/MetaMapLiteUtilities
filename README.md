# MetaMapLiteUtilities
Utility scripts, test data, etc. for working with the MetaMapLite named entity recognizer.  For more information about MetaMapLite, see https://www.ncbi.nlm.nih.gov/pubmed/28130331:

Demner-Fushman, Dina, Willie J. Rogers, and Alan R. Aronson. "MetaMap Lite: an evaluation of a new Java implementation of MetaMap." Journal of the American Medical Informatics Association 24, no. 4 (2017): 841-844.

# Scripts for preparing MetaMapLite input

oboParserToMetaMap.pl: converts .obo files to MetaMap's required "dictionary" formats.  The script takes a directory containing an .obo file as input, then converts all of its concepts to MetaMap format.  If you have multiple OBOs that you want to convert, I suggest either running the script on each one separately (the approach that the associated oboFileParser.sh script takes---see below), or catting them all together and then running it just once.  The latter might be preferable, although it might blow up your memory--I would be interested to hear if people have had problems/successes with that approach.  
oboFileParser.sh: drives the oboParserToMetaMap.pl script described above. See the thoughts above about running it on each of multiple OBO files separately, versus concatenating them and running the oboParserToMetaMap.pl file just once. The current version of the shell script does run separately on each ontology, making a bunch of temporary files in the process; it then concatenates them and deletes the temporary files.  NOTA BENE that MetaMapLite itself puts its output into the *input* directory unless told to do otherwise.



