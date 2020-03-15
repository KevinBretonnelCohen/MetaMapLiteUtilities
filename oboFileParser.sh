# produce the output files for the 6 ontologies in the CRAFT 2.0 distribution
# change my path to your path...
echo "Converting OBO files to MetaMap format."
echo "CHEBI..."
./oboParserToMetaMap.pl /Users/transfer/Dropbox/a-m/Corpora/craft-2.0/ontologies/CHEBI.obo CHEBI
echo "CL..."
./oboParserToMetaMap.pl /Users/transfer/Dropbox/a-m/Corpora/craft-2.0/ontologies/CL.obo CL
echo "GO..."
./oboParserToMetaMap.pl /Users/transfer/Dropbox/a-m/Corpora/craft-2.0/ontologies/GO.obo GO
echo "NCBI (this one takes a while)..."
./oboParserToMetaMap.pl /Users/transfer/Dropbox/a-m/Corpora/craft-2.0/ontologies/NCBITaxon.obo NCBI 
echo "PR"
./oboParserToMetaMap.pl /Users/transfer/Dropbox/a-m/Corpora/craft-2.0/ontologies/PR.obo PR
echo "SO"
./oboParserToMetaMap.pl /Users/transfer/Dropbox/a-m/Corpora/craft-2.0/ontologies/SO.obo SO
echo "Combining MetaMap-format files."
cat MRCON* > temp.txt
mv temp.txt MRCONSO
cat MRST* > temp.txt
mv temp.txt MRSTY
echo "Counting..."
wc -l MRCONS*
wc -l MRSTY*
echo "Cleaning up temporary files..."
rm MRCONS*CHEBI
rm MRSTY*CHEBI
rm MRCONS*CL
rm MRSTY*CL
rm MRCONS*GO
rm MRSTY*GO
rm MRCONS*NCBI
rm MRSTY*NCBI
rm MRCONS*PR
rm MRSTY*PR
rm MRCONS*SO
rm MRSTY*SO

echo "Compiling index files--takes a while..."
cd "/Users/transfer/Dropbox/N-Z/NLM Visiting Scientist/public_mm_lite"
echo "Changed directory to:"
pwd
java -Xmx5g -cp target/metamaplite-3.6.2rc3-standalone.jar gov.nih.nlm.nls.metamap.dfbuilder.CreateIndexes data/obo/MRCONSO data/obo/MRSTY data/ivf/obo
echo "Running test--check the log file to make sure it worked."
echo "reproduction" | ./metamaplite.sh --indexdir=data/ivf/obo --pipe --brat
echo "Running MetaMapLite!"
./metamaplite.sh --indexdir=data/ivf/obo --brat /Users/transfer/Dropbox/a-m/Corpora/craft-2.0/articles/txt/*.txt
echo "Done! Check your input directory--it should have a bunch of new output files in it."
