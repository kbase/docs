//
//
// for problems compiling this code, see http://www.swig.org/Doc1.3/Java.html#dynamic_linking_problems

import KBTreeUtil.KBTree;
import KBTreeUtil.KBTreeUtil;

public class Example {
    public static void main(String argv[]) {
        System.loadLibrary("KBTreeUtil");
        String treeString = "((A,C)D,)E;";
        KBTree t = new KBTree(treeString,false);
        t.printTree();
        System.out.println("node count="+t.toNewick());
        t.removeNodesByNameAndSimplify("A");
        System.out.println("node count="+t.getNodeCount());
        System.out.println("node count="+t.toNewick());
    }
}