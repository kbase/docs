package Bio::KBase::Tree::ForesterParserWrapper;

use strict;
use warnings;

#use Bio::KBase::Exceptions;
use Inline
    Java => "
        import org.forester.phylogeny.Phylogeny;
        import org.forester.phylogeny.PhylogenyMethods;
        import org.forester.io.parsers.nhx.NHXParser;
        import org.forester.io.writers.PhylogenyWriter;
        import org.forester.io.parsers.util.PhylogenyParserException;
        class PhylogenyParserWrapper {
            
            // using default forester settings, takes a newick tree and outputs it in phyloXML
            public static String newick2phyloXML(String newick_tree) {
                NHXParser parser = new NHXParser();
                String phyloXML_string=\"\";
                try {
                    // note, we only return the first tree parsed!!
                    parser.setSource(newick_tree);
                    Phylogeny [] trees = parser.parse();
                    // convert internal node names to bootstrap values - this is needed for MO trees
                    PhylogenyMethods.transferInternalNamesToBootstrapSupport(trees[0]);
                    PhylogenyWriter pw = new PhylogenyWriter();                    
                    phyloXML_string = pw.toPhyloXML(trees[0], 0).toString();
                } catch (final PhylogenyParserException e) {
                    //e.printStackTrace();
                    phyloXML_string=\"PARSE-ERROR: \"+e.getMessage();
                } catch (final java.io.IOException e) {
                    //e.printStackTrace();
                    phyloXML_string=\"IO-ERROR \"+e.getMessage();
                } catch (final Exception e) {
                    //e.printStackTrace();
                    phyloXML_string=\"UNKNOWN-ERROR: \"+e.getMessage();
                }
                return phyloXML_string;
            }
      }
    ",
    PACKAGE => 'main',
    CLASSPATH => '/kb/deployment/lib/forester_1005.jar';


sub convertToPhyloXML
{
    # check input parameters, throw an error if input arguments fail
    if (@_ != 1) {
        print "arg mismatch\n";
	#Bio::KBase::Exceptions::ArgumentValidationError->throw(error => "Invalid argument count for function get_trees (received $n, expecting 2)");
    }
    my($newick_tree_string) = @_;
    
    # do the conversion
    # if( length $newick_tree_string == 0) { return ""; }
    my $phyloXML_tree = PhylogenyParserWrapper->newick2phyloXML($newick_tree_string);
   
    # check for parse errors
    
    # return the tree
    return $phyloXML_tree;
}

1;