import java.io.IOException;
import java.io.RandomAccessFile;

public class IdLookup {
	
	private RandomAccessFile db;
	
	/**
	 * Expects a long text file in the format:
	 * MO_LOCUS_ID KB_TREE_ID KB_ALN_ID
	 * @param idFilename
	 */
	public IdLookup(String idFilename) throws IOException {
		db = new RandomAccessFile(idFilename,"r");
	}
	
	public void close() throws IOException {
		db.close();
	}
	
	public void reload(String idFilename) throws IOException {
		db.close();
		db = new RandomAccessFile(idFilename,"r");
	}
	
	public String[] find(long queryID) throws IOException {
		search(queryID);
		String line = db.readLine();
		if(line==null) { return null; }
		if(Long.parseLong(line.split(" ")[0])!=queryID) { return null; }
		String tokens[]=line.split(" ");
		String result[] = new String[3];
		result[0]=tokens[1];
		result[1]=tokens[2];
		return result;
	}
	
	protected long search(long queryID) throws IOException 
	{
		// because we read the second line after each seek there is no way the
		// binary search will find the first line, so check it first.
	    db.seek(0);
	    String str = db.readLine(); if(str==null) { return 0; }
	    long line = Long.parseLong(str.split(" ")[0]);
	    //System.out.println("searching: "+line);
	    if (line>=queryID) {
	    	//The first line is greater than or equal to the target, so we found the location
	        return 0;
	    }
	    
	    long beg = 0;
	    long end = db.length();
	    //System.out.println("--"+beg+"--"+end);
	    while (beg <= end) {
	    	// find midpoint of the file
	        long mid = beg + (end - beg) / 2;
	        db.seek(mid);
	        db.readLine();

		    str = db.readLine(); if(str==null) { end = mid-1; continue; }
	        line = Long.parseLong(str.split(" ")[0]);
	        //System.out.println("searching: "+line);

	        if (line>=queryID) {
	        	// what we found is greater than or equal to the query, so look
	        	// at the segment before this line
	            end = mid - 1;
	        } else {
	        	// line is not quite high enough, so bump up a notch
	            beg = mid + 1;
	        }
	    }

	    // got here, then we narrowed down the search to a single line, so reset
	    // the pointers and return this position so that the next readLine is
	    // ready to go.
	    db.seek(beg);
	    db.readLine();
	    return db.getFilePointer();
	}
	
}
