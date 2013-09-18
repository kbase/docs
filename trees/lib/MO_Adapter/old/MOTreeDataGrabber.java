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


public class MOTreeDataGrabber {

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
	
	
	public static String pathToTreeDumpDir = "/homes/oakland/msneddon/mo_tree_dump/input/trees/"+GROUP;
	public static boolean use_KB_DB = false;
	
	public static void main(String[] args) 
	{		
		long startTime = System.currentTimeMillis();
		doTheWork();
		
		// give us some stats on how we did
		long estimatedTime = System.currentTimeMillis() - startTime;
		System.out.println(" -> elapsedtime="+estimatedTime*0.001+"s");
		System.out.println(" -> done");
	}
	

	public static void doTheWork( ) {

		try
		{
			Class.forName("com.mysql.jdbc.Driver").newInstance();
			String url = "jdbc:mysql://pub.microbesonline.org:3306/genomics";
			if(use_KB_DB) { url = "jdbc:mysql://db2.chicago.kbase.us:3306/genomics"; }
			System.out.println(" -> opening connection to "+url);
			Connection conn = DriverManager.getConnection(url, "guest", "guest");
			
			String query = "SELECT * FROM Tree WHERE type='"+GROUP+"'";
			try
			{
				// Make sure we connect with some kind of stream rather than load it all at once
				Statement st = conn.createStatement(java.sql.ResultSet.TYPE_FORWARD_ONLY,
						java.sql.ResultSet.CONCUR_READ_ONLY);
				st.setFetchSize(Integer.MIN_VALUE);

				System.out.println(" -> executing the query: "+query);
				ResultSet rs = st.executeQuery(query);
				long iterationTime=0,iterationStartTime=0; int row_count = 0,written_count=0;
				while (rs.next())
				{
					iterationStartTime = System.currentTimeMillis();
					
					//(1) Parse out the result set
					row_count++;
					String treeId     = rs.getString(1);
					String name       = rs.getString(2);
					String type       = rs.getString(3);
					String modified   = rs.getString(4);
					String newick     = rs.getString(5);
					System.out.println(" -> ["+row_count+"]: processing "+treeId+", named: "+name+", type:"+type+", modified:"+modified);
					
					//(2) put it in a file with the same name as the treeId
					BufferedWriter bw = null;
					try {
						File file =new File(pathToTreeDumpDir+"/"+name+".newick");
						if(!file.exists()){
							file.createNewFile();
						}
						bw = new BufferedWriter(new FileWriter(file.getAbsolutePath()));
					} catch (IOException ex) {
						System.err.println("IOException: "+ex.getMessage());
					}
					bw.write(newick);
					bw.close();
				}
				System.out.println(" -> found "+row_count+" trees, wrote "+written_count);
			}
			catch (SQLException ex) {System.err.println("SQLException: "+ex.getMessage());}

			//close shop
			conn.close();
		}
		catch (ClassNotFoundException ex) {System.err.println("classnotfound: "+ex.getMessage());}
		catch (IllegalAccessException ex) {System.err.println("IllegalAccessException: "+ex.getMessage());}
		catch (InstantiationException ex) {System.err.println("InstantiationException: "+ex.getMessage());}
		catch (SQLException ex)           {System.err.println("SQLException: "+ex.getMessage());}
		catch (IOException ex)            {System.err.println("IOException: "+ex.getMessage());}

	}
	
	

}
