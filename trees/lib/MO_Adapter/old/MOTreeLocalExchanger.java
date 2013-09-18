import java.sql.*;
import java.io.BufferedWriter;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.BufferedReader;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.TimeZone;

import KBTreeUtil.KBTree;

// same as the data exchanger, except looks for tree files locally
public class MOTreeLocalExchanger {

	public static String GROUP = "SSF";
	// Possible Groups (** indicates alignment files are ready)
	// 16S
	// 23S
	// 5S
	// Adhoc
	// COG       **
	// FastBLAST **
	// GENE3D    **
	// PFAM      **
	// PIRSF     **
	// SMART     **
	// species
	// SSF
	// TIGRFAMs
	
	public static String pathToTreeList =   "/homes/oakland/msneddon/mo_tree_dump/input/"+GROUP+"_TreeList.txt";
	
	public static String pathToDumpDir =   "/homes/oakland/msneddon/mo_tree_dump/dump/"+GROUP;
	public static String pathToAlnDir =    "/homes/oakland/msneddon/mo_tree_dump/input/alignments/"+GROUP;
	public static String pathToTreeDir =    "/homes/oakland/msneddon/mo_tree_dump/input/trees/"+GROUP;
	public static String pathToLociFile =  "/homes/oakland/msneddon/mo_tree_dump/input/ids/public_loci_with_associated_kbaseIds.txt";
	public static String pathToIdFile =    "/homes/oakland/msneddon/mo_tree_dump/input/ids/assigned_kbase_tree_id_list.txt";
	
	public static long timestampInSecondsSinceEpoch;
	public static boolean use_KB_DB = false;
	public static LocusLookup publicLoci;
	public static IdLookup kbaseIdMapping;
	public static String ALN_METHOD="";
	public static String ALN_PARAM="";
	
	// load the KBTree C++ Library for newick parsing and tree manipulations
	// and figure out what timestamp to use
	static {
		System.loadLibrary("KBTreeUtil");	
		Calendar calendar = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
		calendar.clear();
		calendar.set(2012, Calendar.OCTOBER, 9);
		timestampInSecondsSinceEpoch = calendar.getTimeInMillis() / 1000L;
		try {
			publicLoci = new LocusLookup(pathToLociFile);
			kbaseIdMapping = new IdLookup(pathToIdFile);
		} catch (IOException e) {
			System.err.println("Cannot open public loci file.  Cannot continue.");
			System.err.println(e.getMessage());
			e.printStackTrace();
			System.exit(1);
		}
		// Configure the alignment method and options for each source
		if(GROUP.compareTo("COG")==0) { 		ALN_METHOD="RPS-BLAST"; ALN_PARAM="-e 1e-5"; }
		else if(GROUP.compareTo("GENE3D")==0) { 	ALN_METHOD="HMMER3"; ALN_PARAM="-Z 2219 -E 0.001"; }
		else if(GROUP.compareTo("PFAM")==0) { 		ALN_METHOD="HMMER3"; ALN_PARAM="--cut_ga"; }
		else if(GROUP.compareTo("PIRSF")==0) { 		ALN_METHOD="HMMER3"; ALN_PARAM="-Z 2791 -E 0.02"; }
		else if(GROUP.compareTo("SMART")==0) { 		ALN_METHOD="HMMER3"; ALN_PARAM="-Z 885 -E 2.04e-5"; }
		else if(GROUP.compareTo("SSF")==0) { 		ALN_METHOD="HMMER3"; ALN_PARAM="-Z 2019 -E 0.02"; }
		else if(GROUP.compareTo("TIGRFAMs")==0) { 	ALN_METHOD="HMMER3"; ALN_PARAM="--cut_tc"; }
		else if(GROUP.compareTo("Adhoc")==0) { 	      	ALN_METHOD="FastBLAST-topHomologs.pl"; ALN_PARAM=""; }
	}
	
	public static void main(String[] args) 
	{		
		// do the work of actually querying microbes online and writing the files
		long startTime = System.currentTimeMillis();
		BufferedWriter BW_trees, BW_treeAttribute, BW_treeNodeAttribute, BW_aln, BW_aln_row, BW_alnAttribute, BW_containsProtein, BW_containsNucleotide;
		
		// open buffers to all the primary output files we need
		boolean ignoreExistingFiles=true;
		System.out.println(" -> creating file \"Tree.tab\"");
		if(!ignoreExistingFiles) BW_trees   = openOutputFileStreamNicely(pathToDumpDir+"/Tree.tab");
		else BW_trees   = openOutputFileStreamNoMatterWhat(pathToDumpDir+"/Tree.tab");
		System.out.println(" -> creating file \"TreeAttribute.tab\"");
		if(!ignoreExistingFiles) BW_treeAttribute   = openOutputFileStreamNicely(pathToDumpDir+"/TreeAttribute.tab");
		else BW_treeAttribute   = openOutputFileStreamNoMatterWhat(pathToDumpDir+"/TreeAttribute.tab");
		System.out.println(" -> creating file \"TreeNodeAttribute.tab\"");
		if(!ignoreExistingFiles) BW_treeNodeAttribute   = openOutputFileStreamNicely(pathToDumpDir+"/TreeNodeAttribute.tab");
		else BW_treeNodeAttribute   = openOutputFileStreamNoMatterWhat(pathToDumpDir+"/TreeNodeAttribute.tab");
		System.out.println(" -> creating file \"Alignment.tab\"");
		if(!ignoreExistingFiles) BW_aln     = openOutputFileStreamNicely(pathToDumpDir+"/Alignment.tab");
		else BW_aln     = openOutputFileStreamNoMatterWhat(pathToDumpDir+"/Alignment.tab");
		System.out.println(" -> creating file \"AlignmentRow.tab\"");
		if(!ignoreExistingFiles) BW_aln_row = openOutputFileStreamNicely(pathToDumpDir+"/AlignmentRow.tab");
		else BW_aln_row = openOutputFileStreamNoMatterWhat(pathToDumpDir+"/AlignmentRow.tab");
		System.out.println(" -> creating file \"AlignmentAttribute.tab\"");
		if(!ignoreExistingFiles) BW_alnAttribute = openOutputFileStreamNicely(pathToDumpDir+"/AlignmentAttribute.tab");
		else BW_alnAttribute = openOutputFileStreamNoMatterWhat(pathToDumpDir+"/AlignmentAttribute.tab");
		System.out.println(" -> creating file \"ContainsAlignedProtein.tab\"");
		if(!ignoreExistingFiles) BW_containsProtein = openOutputFileStreamNicely(pathToDumpDir+"/ContainsAlignedProtein.tab");
		else BW_containsProtein = openOutputFileStreamNoMatterWhat(pathToDumpDir+"/ContainsAlignedProtein.tab");
		System.out.println(" -> creating file \"ContainsAlignedNucleotides.tab\"");
		if(!ignoreExistingFiles) BW_containsNucleotide = openOutputFileStreamNicely(pathToDumpDir+"/ContainsAlignedNucleotides.tab");
		else BW_containsNucleotide = openOutputFileStreamNoMatterWhat(pathToDumpDir+"/ContainsAlignedNucleotides.tab");

		
		// do the work of actually querying microbes online and writing the files
		if(BW_trees!=null && BW_treeAttribute!=null && BW_treeNodeAttribute!=null && BW_aln!=null && 
			BW_aln_row!=null && BW_alnAttribute!=null && BW_containsProtein!=null && BW_containsNucleotide!=null) {
			
			doTheWork(
					BW_trees,
					BW_treeAttribute,
					BW_treeNodeAttribute,
					BW_aln,
					BW_aln_row,
					BW_alnAttribute,
					BW_containsProtein,
					BW_containsNucleotide,
					startTime);
		}
		
		// close the streams
		try {
			BW_trees.close();
			BW_treeAttribute.close();
			BW_treeNodeAttribute.close();
			BW_aln.close();
			BW_aln_row.close();
			BW_alnAttribute.close();
			BW_containsProtein.close();
			BW_containsNucleotide.close();
		} catch (IOException ex) { System.err.println("IOException: "+ex.getMessage()); }
		

		// give us some stats on how we did
		long estimatedTime = System.currentTimeMillis() - startTime;
		System.out.println(" -> elapsedtime="+estimatedTime*0.001+"s");
		System.out.println(" -> done");
	}
	
	


	

	public static void doTheWork(
			BufferedWriter BW_trees,
			BufferedWriter BW_treeAttribute,
			BufferedWriter BW_treeNodeAttribute,
			BufferedWriter BW_aln,
			BufferedWriter BW_aln_row,
			BufferedWriter BW_alnAttribute,
			BufferedWriter BW_containsProtein,
			BufferedWriter BW_containsNucleotide,
			long startTime) {

		try
		{
			
			// read in the file list of alignments/trees to process
			DataInputStream in = new DataInputStream(new FileInputStream(pathToTreeList));
			BufferedReader br = new BufferedReader(new InputStreamReader(in));
			String line=""; int row_count = 1; int written_count=0;
			while ((line=br.readLine()) != null)   {
				long iterationStartTime = System.currentTimeMillis();
			
				line=line.trim();
				String [] tokens = line.split("\\s+");
				String treeId = tokens[0];
				String name = tokens[1];
				String type = GROUP;
				System.out.println(" -> ["+row_count+"]: processing "+treeId+", named: "+name);
				row_count++;
					
				// for each ID, grab the associated KBase ID
				String ids[] = kbaseIdMapping.find(Long.parseLong(treeId));
				String KBaseTreeID = ids[0];
				String KBaseAlnID = ids[1];
				System.out.println("     | tree is mapped to kbase aln id: "+KBaseAlnID+" and kbase tree id: "+KBaseTreeID);
				
				// FIND, LOAD THE ALIGNMENT FILE, IDENTIFY THE PRIVATE GENES, AND WRITE THE NEW ALIGNMENT FILE (WITHOUT EVER STORING ALL THE SEQUENCES)
				String alignmentFileName = pathToAlnDir+"/"+name+".trim.fasta";
				System.out.println("     | processing alignment file: "+alignmentFileName);
				SingleGeneAlignmentInformation ai = processSingleGeneAlignmentFile(alignmentFileName,pathToDumpDir+"/Raw_Alignment_Files/"+KBaseAlnID+".fasta");
				System.out.println("     | alignment contains "+ai.n_rows+" total rows and "+ai.n_private+" private rows");
				if((ai.n_rows-ai.n_private)==0) {
					System.out.println("     | no public rows to publish to kbase!  skipping this alignment/tree pair.");
					continue;
				}
				System.out.println("     | final alignment with removed private genes was written containing "+(ai.n_rows-ai.n_private) +" rows.");
				written_count++;
	
				// PARSE THE NEWICK TREE, REMOVE PRIVATE GENES, WRITE THE FILE
				String treeFileName = pathToTreeDir+"/"+name+".newick";
				
				System.out.println("     | processing tree file: "+treeFileName);
				DataInputStream inTREE = new DataInputStream(new FileInputStream(treeFileName));
				BufferedReader brTREE = new BufferedReader(new InputStreamReader(inTREE));
				String newick=""; String treeFileLine="";
				while ((treeFileLine=brTREE.readLine()) != null) { newick+=treeFileLine.trim(); };
				processNewickGeneTree(newick, ai, pathToDumpDir+"/Raw_Tree_Files/"+KBaseTreeID+".newick");
					
				// (5) WRITE THE ALIGNMENT RECORD IN ALIGNMENT.TAB FILE
				BW_aln.write(KBaseAlnID+"\t"); // kb_aln_id	 M	 unique kbase id reserved for the alignment from ID server: 'kb|aln.XXXXX'
				BW_aln.write((ai.n_rows-ai.n_private)+"\t");   // n_rows	 M	 number of rows in the alignment, must be an integer valued 1 or greater
				BW_aln.write(ai.n_cols+"\t");   // n_cols	 R	 number of columns in the alignment, must be an integer valued 1 or greater
				BW_aln.write("active\t");       // status	 M	 string indicating if the alignment is "active", "superseded" or "bad"
				BW_aln.write("0\t");            // is_concatenation	 M	 boolean to indicate if the alignment was composed by concatenating multiple alignments together; use numeric 0 and 1
				BW_aln.write("Protein\t");      // sequence_type	 M	 string indicating the type of sequence; initial support should include "Protein", "DNA", "RNA", and "Mixed"; the first letter needs to be capitalized for protein and mixed
				BW_aln.write(timestampInSecondsSinceEpoch+"\t");      // timestamp	 M	 the time at which this alignment was loaded into KBase. Other timestamps can be added to AlignmentAttribute?; the time format is an integer indicating seconds since epoch
				BW_aln.write(ALN_METHOD+"\t");  // method	 R	 string that either maps to another object that captures workflows, or is simple alignment method name, e.g. "MOPipeline"
				BW_aln.write(ALN_PARAM+"\t");       // parameters	 R	 free form string that might be a hash to provide additional alignment parameters e.g., the program option values used
				BW_aln.write("MO_Pipeline("+name+")\t"); // protocol	 O	 human readable description of the alignment, if needed
				BW_aln.write("MOL:Tree\t");           // source_db	 M	 the database where this alignment originated, eg MO, SEED
				BW_aln.write(treeId);      // source_db_aln_id	 M	 the id of this alignment in the original database
				BW_aln.write("\n");
				BW_aln.flush();
					
				// (6) WRITE THE TREE RECORD IN TREE.TAB FILE
				BW_trees.write(KBaseTreeID+"\t");  // kb_tree_id	 M	 unique kbase id reserved for the tree from ID server: 'kb|tree.XXXXX'
				BW_trees.write(KBaseAlnID+"\t");   // kb_aln_id	 M	 the kbase id of the alignment from which this tree was built
				BW_trees.write("active\t");        // status	 M	 string indicating if the tree is "active", "superseded" or "bad"
				BW_trees.write("sequence_alignment\t");  // data_type	 M	 lowercase string indicating the type of data this tree is built from; we set this to "sequence_alignment" for all alignment-based trees, but we may support "taxonomy", "gene_content" trees and more in the future
				BW_trees.write(timestampInSecondsSinceEpoch+"\t");      // timestamp	 M	 the time at which this alignment was loaded into KBase. Other timestamps can be added to AlignmentAttribute?; the time format is an integer indicating seconds since epoch
				BW_trees.write("FastTree2\t");  // method	 R	 string that either maps to another object that captures workflows, or is simple alignment method name, e.g. "MOPipeline"
				BW_trees.write("-fastest\t");       // parameters	 R	 free form string that might be a hash to provide additional alignment parameters e.g., the program option values used
				BW_trees.write("MO_Pipeline("+name+")\t"); // protocol	 O	 human readable description of the alignment, if needed
				BW_trees.write("MOL:Tree\t");           // source_db	 M	 the database where this alignment originated, eg MO, SEED
				BW_trees.write(treeId);      // source_db_aln_id	 M	 the id of this alignment in the original database   
				BW_trees.write("\n");
				BW_trees.flush();

				// (7) ADD TO THE ALIGNMENT ROW TABLE
				writeAlignmentRowDataForProtAln(KBaseAlnID, BW_aln_row, BW_containsProtein, ai);
				
				// (8) WRITE ANY OTHER ATTRIBUTES WE NEED TO THE APPROPRIATE FILES
				BW_alnAttribute.write(KBaseAlnID+"\t"+"seeded_by_src\tMOL:"+type+"\n");
				BW_alnAttribute.write(KBaseAlnID+"\t"+"seeded_by_id\t"+name+"\n");
					
				BW_treeAttribute.write(KBaseTreeID+"\t"+"seeded_by_src\tMOL:"+type+"\n");
				BW_treeAttribute.write(KBaseTreeID+"\t"+"seeded_by_id\t"+name+"\n");
				BW_treeAttribute.write(KBaseTreeID+"\t"+"style\t"+"phylogram\n");
				BW_treeAttribute.write(KBaseTreeID+"\t"+"bootstrap_type\t"+"Shimodaira-Hasegawa Test\n");
				BW_treeAttribute.write(KBaseTreeID+"\t"+"rooted\t"+"midpoint\n");

				// dump some stats to see how we are progressing
				
				long estimatedTime = System.currentTimeMillis() - startTime;
				long iterationTime = System.currentTimeMillis() - iterationStartTime;
				System.out.println("     | elapsedtime="+estimatedTime*0.001+"s, iterationTime="+iterationTime*0.001+"s, elapsedtime per row="+(((double)iterationTime)/(double)ai.n_rows)+"ms");
				System.gc();
			}
		}
		catch (IOException ex)            {System.err.println("IOException: "+ex.getMessage());}

	}
	
	static class SingleGeneAlignmentInformation {
		
		// need to be vectors because they are created as the file is read
		ArrayList <String> ids;
		ArrayList <String> descriptions;
		
		// indicates whether a gene is private or not
		ArrayList <Boolean> isPrivate;
		
		// can be arrays for efficiency since they are computed after everything
		// has been read in already
		ArrayList <Integer> row_start_pos_in_alignment;
		ArrayList <Integer> row_end_pos_in_alignment;
		ArrayList <String> MO_locusId;
		ArrayList <String> versionNumber;
		ArrayList <String> MD5ofGapRemovedSequences;
		
		// info on parent seq
		ArrayList <Integer> begin_pos_in_parent;
		ArrayList <Integer> end_pos_in_parent;
		ArrayList <String> parent_MD5;
		ArrayList <Integer> parent_seq_length;
		ArrayList <String> feature_reference;
		
		// rows and columns of the alignment
		int n_rows;
		int n_cols;
		
		int n_private;
		
		SingleGeneAlignmentInformation() {
			int initialCapacity = 10000;
			ids = new ArrayList <String> (initialCapacity);
			descriptions = new ArrayList <String> (initialCapacity);
			isPrivate = new ArrayList <Boolean> (initialCapacity);
			row_start_pos_in_alignment = new ArrayList <Integer> (initialCapacity);
			row_end_pos_in_alignment = new ArrayList <Integer> (initialCapacity);
			MO_locusId = new ArrayList <String> (initialCapacity);
			versionNumber = new ArrayList <String> (initialCapacity);
			MD5ofGapRemovedSequences = new ArrayList <String> (initialCapacity);
			begin_pos_in_parent = new ArrayList <Integer> (initialCapacity);
			end_pos_in_parent = new ArrayList <Integer> (initialCapacity);
			parent_MD5 = new ArrayList <String> (initialCapacity);
			parent_seq_length = new ArrayList <Integer> (initialCapacity);
			feature_reference = new ArrayList <String> (initialCapacity);
			n_rows=0;
			n_cols=0;
			n_private=0;
		}
	}
	
	/**
	 * Given a path to an alignment file, parse the file and return info about the
	 * alignment in an alignment data structure.
	 * @param file_path
	 * @return
	 */
	public static SingleGeneAlignmentInformation processSingleGeneAlignmentFile(String file_path, String output_path) {

		SingleGeneAlignmentInformation ai = new SingleGeneAlignmentInformation();
		try {
			// open up a stream to the desired output file
			File file=null; BufferedWriter out=null;
			try {
				file =new File(output_path);
				if(!file.exists()){ file.createNewFile(); }
				out = new BufferedWriter(new FileWriter(file.getAbsolutePath()));
			} catch (Exception e) {
				System.err.println("Error with connecting to output directory.  Make sure folder structures are correct.");
				System.err.println("Error: " + e.getMessage());
				System.exit(33);
			} 
			
			//open up a stream and read in the file
			DataInputStream in = new DataInputStream(new FileInputStream(file_path));
			BufferedReader br = new BufferedReader(new InputStreamReader(in));
			String line="",nextLine="", id=""; int currentPos = 0;
			while (true)   {
				if(nextLine.length()>0) { line=nextLine; nextLine=""; }
				else {
					line=br.readLine();
					if(line==null) { break; }
				}
				line=line.trim();
				if(line.startsWith(">")) {
					String sequence="";
					// drop the line identifier and split on whitespace
					String [] tokens = (line.substring(1)).split("\\s");
					if(tokens.length==0) { System.err.println ("error in parsing " + file_path); System.exit(1); }
					id = tokens[0];
					ai.ids.add(new String(id)); 
					ai.descriptions.add(new String( (line.substring(id.length()+1)).trim() ));
					// populate the locus ids and start/stop pos based on the FASTA ID string
					currentPos = ai.ids.size()-1;
					String [] idTokens = (ai.ids.get(currentPos)).split("_");
					ai.MO_locusId.add(idTokens[0]);
					ai.versionNumber.add(idTokens[1]);
					ai.begin_pos_in_parent.add(Integer.parseInt(idTokens[2]));
					ai.end_pos_in_parent.add(Integer.parseInt(idTokens[3]));

					// Loop over the next lines until we get to the next comment or and end of file null
					// to grab that sequence
					while(true) {
						line=br.readLine();
						if(line==null) { break; }
						line=line.trim();
						if(line.startsWith(">")) {nextLine=line; break; }
						sequence+=line;
					}
					if(ai.n_cols==0) { ai.n_cols = sequence.length(); }
					if(ai.n_cols!=0 && ai.n_cols!=sequence.length()) {
						System.err.println ("error in parsing " + file_path); 
						System.err.println ("alignment has sequences that are not all the same length! "+sequence.length()+" "+ai.n_cols); 
						System.exit(1);
					}
					

					// figure out if we are private or not, and act accordingly
					deterineIfCurrentLocusIsPrivate(ai,currentPos);
					if(ai.isPrivate.get(currentPos)) {
						ai.row_start_pos_in_alignment.add(0);
						ai.row_end_pos_in_alignment.add(0);
						ai.MD5ofGapRemovedSequences.add("");
						ai.n_private++;
					} else {
						// find where each row in this alignment starts and ends
						for(int i=0; i<sequence.length(); i++) {
							if(sequence.charAt(i)!='-' && sequence.charAt(i)!=' ') {
								ai.row_start_pos_in_alignment.add(i+1);
								break;
							}
						}
						for(int i=sequence.length()-1; i>=0; i--) {
							if(sequence.charAt(i)!='-' && sequence.charAt(i)!=' ') {
								ai.row_end_pos_in_alignment.add(i+1);
								break;
							}
						}
						// remove gaps and compute the MD5
						ai.MD5ofGapRemovedSequences.add(computeMD5(sequence.replace("-","")));
						// write the row to the alignment file
						writeNextFASTAfileEntry(ai.ids.get(currentPos),ai.descriptions.get(currentPos), sequence, out);
					}
					
				}
			}
			//Close the input and output streams
			in.close();
			out.close();
			
			// delete the file if nothing was in it.
			if(ai.ids.size()-ai.n_private==0) { file.delete(); }
			
			
//			System.out.println(" ");
//			System.out.println(ai.ids.size());
//			System.out.println(ai.descriptions.size());
//			System.out.println(ai.isPrivate.size());
//			System.out.println(ai.row_start_pos_in_alignment.size());
//			System.out.println(ai.row_end_pos_in_alignment.size());
//			System.out.println(ai.MO_locusId.size());
//			System.out.println(ai.versionNumber.size());
//			System.out.println(ai.MD5ofGapRemovedSequences.size());
//			System.out.println(ai.begin_pos_in_parent.size());
//			System.out.println(ai.end_pos_in_parent.size());
//			System.out.println(ai.parent_MD5.size());
//			System.out.println(ai.parent_seq_length.size());
//			System.out.println(" ");
//		    	if(false) {
//			    for(int k=0; k<ai.ids.size(); k++) {
//				    System.out.println("\n\n"+ai.ids.get(k));
//				    System.out.println(ai.descriptions.get(k));
//				    System.out.println("s:"+ai.row_start_pos_in_alignment.get(k)+",e:"+ai.row_end_pos_in_alignment.get(k));
//				    System.out.println("MO_Id:"+ai.MO_locusId.get(k)+" v:"+ai.versionNumber.get(k));
//				    System.out.println("begin:"+ai.begin_pos_in_parent.get(k)+",end:"+ai.end_pos_in_parent.get(k));
//			    }
//			    System.out.println("++++");
//		   	}
		} catch (Exception e) {
			System.err.println("Error: " + e.getMessage());
			System.exit(33);
		}

		// save the final alignment number of rows
		ai.n_rows=ai.ids.size();
		return ai;
	}
	
	
	/**
	 * Given an alignment read in from file, this file queries MO to discover which locus IDs are
	 * public, and sets a boolean value to mark the private IDs.  These private IDs may have to
	 * be removed from the trees and alignments.
	 * @param ai
	 * @param st
	 */
	public static void deterineIfCurrentLocusIsPrivate(SingleGeneAlignmentInformation ai,int currentPos) {
		try {
			// create a list to keep track of the private sequences.  we assume things
			// are private unless we can find them in the locus table
			String result[]=publicLoci.find(Long.parseLong(ai.MO_locusId.get(currentPos)));
			if(result!=null) {
				// found!  so we are in business
				ai.isPrivate.add(false);
				ai.parent_MD5.add(result[0]);
				ai.parent_seq_length.add(Integer.parseInt(result[1]));
				if(result[2].equals("0")) {
					System.out.println("!! could not find the kb feature!  "+result[2]+" MO ID="+ai.MO_locusId.get(ai.MO_locusId.size()-1));
					ai.feature_reference.add("");
				} else {
					ai.feature_reference.add(result[2]);
				}
			} else {
				ai.isPrivate.add(true);
				ai.parent_MD5.add("");
				ai.parent_seq_length.add(0);
				ai.feature_reference.add("");
			}
		} catch (IOException e) {
			System.err.println("Lost connection to public loci file.  Cannot continue.");
			System.err.println(e.getMessage());
			e.printStackTrace();
			System.exit(1);
		}
	}
	

	
	
	/**
	 * Writes a fasta file with only the public genes
	 * @param ai
	 * @param file_path
	 */
	public static void writeNextFASTAfileEntry(String id, String description, String sequence, BufferedWriter bw) {
		try {
			bw.write(">"+id+" "+description+"\n");
			bw.write(sequence+"\n");
		} catch (IOException e) { System.err.println("IOException when writing FASTA file: "+e.getMessage()); }
	}
	
	
	
	
	
	public static void processNewickGeneTree(String newick, SingleGeneAlignmentInformation ai, String finalTreeFilename) 
	{
		//NOTE FROM MO DOC: For gene trees, the leaf ids are of the form locusId_version_begin_end or locusId_begin_end. 
		//                : For species trees, the leaf ids are taxonomy ids.
		// Parse the newick string
		boolean verboseTreeOutput = false;
		boolean assumeInternalNodeNamesAreBootstrapValues=true;
		KBTree t = new KBTree(newick,verboseTreeOutput,assumeInternalNodeNamesAreBootstrapValues);
		
		// remove the private genes (keeping some tallies to make sure we got em all)
		long originalLeafCount = t.getLeafCount(); long originalNodeCount = t.getNodeCount();
		System.out.println("     | read tree, node count="+originalNodeCount+", leaf count="+originalLeafCount);
		String privateIdList = "";
		for(int k=0; k<ai.ids.size(); k++) {
			if(ai.isPrivate.get(k)) {
				privateIdList += ai.ids.get(k)+";";
			}
		}
		t.removeNodesByNameAndSimplify(privateIdList);
		System.out.println("     | simplified tree, node count="+t.getNodeCount()+", leaf count="+t.getLeafCount()+", removed nodes="+(originalNodeCount-t.getNodeCount())+", removed leaves="+(originalLeafCount-t.getLeafCount()));
		
		// write the simplified tree to newick format
		t.writeNewickToFile(finalTreeFilename);
		System.out.println("     | wrote simplified tree to file: "+finalTreeFilename);
	}
	

	
	
	public static void writeAlignmentRowDataForProtAln(String KBaseAlnID, BufferedWriter BW_aln_row, BufferedWriter BW_containsProtein, SingleGeneAlignmentInformation ai) throws IOException
	{
		int currentRow = 1;
		for(int k=0; k<ai.ids.size(); k++) {
			if(ai.isPrivate.get(k)) continue;
			
			BW_aln_row.write(KBaseAlnID+"\t");    // kb_aln_id	 M	 unique kbase id reserved for the alignment from ID server
			BW_aln_row.write(currentRow+"\t");    // row_number	 M	 row number in the alignment file, count starts at '1'
			BW_aln_row.write(ai.ids.get(k)+"\t"); // row_id	 M	 identifier for this row which must be unique in this alignment and must also be the first word in the alignment fasta file.
			BW_aln_row.write(ai.descriptions.get(k)+"\t");     // row_description	 O	 optional text description of the row copied from the original fasta file
			BW_aln_row.write(1+"\t");             // n_components	 M	 the number of components (e.g. concatenated sequences) that correspond to this alignment row
			BW_aln_row.write(ai.row_start_pos_in_alignment.get(k)+"\t");  //beg_pos_in_aln	 R	 the column (index starting at pos '1') in the alignment where this sequence row begins (ie. truncating any ending gaps)
			BW_aln_row.write(ai.row_end_pos_in_alignment.get(k)+"\t");    //end_pos_in_aln	 R	 the column (index starting at pos '1') in the alignment where this sequence row ends (ie. truncating any ending gaps)
			BW_aln_row.write(ai.MD5ofGapRemovedSequences.get(k));            // md5_of_ungapped_seq	 M	 the MD5 (uppercase) of the aligned sequence on this row with gaps stripped; U should be converted to T in nucleotide sequences (even for RNA)
			BW_aln_row.write("\n");
			
			BW_containsProtein.write(KBaseAlnID+"\t");    // kb-aln-id	 M	 maps this component to a particular alignment identified by the kbase id
			BW_containsProtein.write(currentRow+"\t");    // aln-row-number	 M	 row number in alignment file, count starts at '1'
			BW_containsProtein.write(1+"\t");             // index-in-concatenation	 M	 ordering starting from left to right in alignment row starting at '1'
			BW_containsProtein.write(ai.parent_MD5.get(k)+"\t");     // parent-seq-id	 M	 MD5 for protein sequence
			BW_containsProtein.write(ai.begin_pos_in_parent.get(k)+"\t");           // beg-pos-in-parent	 M	 the alignment includes the original sequence starting at this postion, 1-based
			BW_containsProtein.write(ai.end_pos_in_parent.get(k)+"\t");             // end-pos-in-parent	 M	 the alignment includes the original sequence ending at this postion, 1-based
			BW_containsProtein.write(ai.parent_seq_length.get(k)+"\t");     // parent-seq-len	 M	 the length of the untrimmed sequence for quick reference of the coverage of this alignment
			BW_containsProtein.write(ai.row_start_pos_in_alignment.get(k)+"\t");   // beg-pos-in-aln	 M	 integer value providing a coordinate/mapping to the starting column in the alignment where this sequence component begins
			BW_containsProtein.write(ai.row_end_pos_in_alignment.get(k)+"\t");     // end-pos-in-aln	 M	 integer value providing a coordinate/mapping to the ending column in the alignment where this sequence component ends
			BW_containsProtein.write(ai.feature_reference.get(k));                           // kb-feature-id	 O	 associated kbase feature id, e.g., when intending to refer to a particular genome
			BW_containsProtein.write("\n");
			currentRow++;
		}
	}
	
	
	
	public static void processNewickSpeciesTree(String treeId, String newick, Connection conn) throws IOException,SQLException {
		System.err.println("i do not know how to process a newick species tree yet.");
		System.exit(2);
	}
	
		
	/** given a sequence, compute the MD5 in the same style as KBase */
	public static String computeMD5(String MD5) {
		//String testSeq = "MIQEENQNMSFAQVISILGVILMGSFVTILNQTLMSTALPSIMREFSITATQGQWLTTAYMLINGIMVPITAY
		//LVNRFTTRQLYLFSMIVFSIGTFVAATSSVYGVLIAGRMIQAVGAGIILPLQMIVVLYIFPIEKRGSAMGLIGLAMNFAPAIGPTFSGWVVQN
		//YHWNMLFYFILPFAIIDVIVAIFVLKNVGKTGRPKLDLISVIYSTLGFGGLLFGLSNASSHDFISVNVALPIVVGIISLILLVNRSNHSKEPL
		//LNFGIFKYRGYRLNLIISFVLTAGMYGAIMLLPIYLQNIREMTPMESGMTLLPGAIVMAVMSPITGRMFDKYGSKRLAMSGLTLVTIGTFIIG
		//LIDLNTPIVYIVLLQVVRSLGFALTLMPIQTAAFNAVPLELASHASAMFNTQRQLAGSMGTALFVVVMTVVSQNGVSQHLPSELADLAGFQTVF
		//KLVGVFSLVAFIMTLFIKENPYLPKAKLAENH";
		//System.out.println(computeMD5(testSeq));
		// should be: 05b66e1a9fef4a63878e80febcbd6b95
		//System.exit(1);
		try {
			java.security.MessageDigest md = java.security.MessageDigest.getInstance("MD5");
			byte[] array = md.digest(MD5.getBytes(java.nio.charset.Charset.forName("UTF8")));
			StringBuffer sb = new StringBuffer();
			for (int i = 0; i < array.length; ++i) {
				sb.append(Integer.toHexString((array[i] & 0xFF) | 0x100).substring(1,3));
			}
			return sb.toString();
		} catch (java.security.NoSuchAlgorithmException e) { }
		return null;
	}
	/** method to make sure we don't overwrite an existing file */
	public static BufferedWriter openOutputFileStreamNicely(String absolute_path) {
		BufferedWriter bw = null;
		try {
			File file =new File(absolute_path);
			if(!file.exists()){
				file.createNewFile();
			} else {
				System.out.println("File: \""+absolute_path+"\" already exists. Overwrite? (y/n)");
				BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
			    String response = null;
			    try {
			         response = br.readLine();
			    } 
			    catch (IOException ex) {System.err.println("IOException: "+ex.getMessage());}
			    if(!response.trim().equals("y")) {
			    	System.out.println("Can't do anything if file exists and you refuse to overwrite it.");
			    	System.exit(1);
			    }
			}
			bw = new BufferedWriter(new FileWriter(file.getAbsolutePath()));
		} catch (IOException ex) {
			System.err.println("IOException: "+ex.getMessage());
		}
		return bw;
	}
	/** method that overwrites whatever already exists, use with caution */
	public static BufferedWriter openOutputFileStreamNoMatterWhat(String absolute_path) {
		BufferedWriter bw = null;
		try {
			File file =new File(absolute_path);
			if(!file.exists()){
				file.createNewFile();
			}
			bw = new BufferedWriter(new FileWriter(file.getAbsolutePath()));
		} catch (IOException ex) {
			System.err.println("IOException: "+ex.getMessage());
		}
		return bw;
	}

}
