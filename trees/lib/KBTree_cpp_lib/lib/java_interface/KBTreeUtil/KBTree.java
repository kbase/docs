/* ----------------------------------------------------------------------------
 * This file was automatically generated by SWIG (http://www.swig.org).
 * Version 2.0.4
 *
 * Do not make changes to this file unless you know what you are doing--modify
 * the SWIG interface file instead.
 * ----------------------------------------------------------------------------- */

package KBTreeUtil;

public class KBTree {
  private long swigCPtr;
  protected boolean swigCMemOwn;

  public KBTree(long cPtr, boolean cMemoryOwn) {
    swigCMemOwn = cMemoryOwn;
    swigCPtr = cPtr;
  }

  public static long getCPtr(KBTree obj) {
    return (obj == null) ? 0 : obj.swigCPtr;
  }

  protected void finalize() {
    delete();
  }

  public synchronized void delete() {
    if (swigCPtr != 0) {
      if (swigCMemOwn) {
        swigCMemOwn = false;
        KBTreeUtilJNI.delete_KBTree(swigCPtr);
      }
      swigCPtr = 0;
    }
  }

  public KBTree(String newickString) {
    this(KBTreeUtilJNI.new_KBTree__SWIG_0(newickString), true);
  }

  public KBTree(String newickString, boolean verbose) {
    this(KBTreeUtilJNI.new_KBTree__SWIG_1(newickString, verbose), true);
  }

  public KBTree(String newickString, boolean verbose, boolean assumeBootstrapNames) {
    this(KBTreeUtilJNI.new_KBTree__SWIG_2(newickString, verbose, assumeBootstrapNames), true);
  }

  public String toNewick() {
    return KBTreeUtilJNI.KBTree_toNewick__SWIG_0(swigCPtr, this);
  }

  public void setOutputFlagLabel(boolean flag) {
    KBTreeUtilJNI.KBTree_setOutputFlagLabel(swigCPtr, this, flag);
  }

  public void setOutputFlagDistances(boolean flag) {
    KBTreeUtilJNI.KBTree_setOutputFlagDistances(swigCPtr, this, flag);
  }

  public void setOutputFlagComments(boolean flag) {
    KBTreeUtilJNI.KBTree_setOutputFlagComments(swigCPtr, this, flag);
  }

  public void setOutputFlagBootstrapValuesAsLabels(boolean flag) {
    KBTreeUtilJNI.KBTree_setOutputFlagBootstrapValuesAsLabels(swigCPtr, this, flag);
  }

  public String toNewick(long style) {
    return KBTreeUtilJNI.KBTree_toNewick__SWIG_1(swigCPtr, this, style);
  }

  public boolean writeNewickToFile(String filename) {
    return KBTreeUtilJNI.KBTree_writeNewickToFile__SWIG_0(swigCPtr, this, filename);
  }

  public boolean writeNewickToFile(String filename, long style) {
    return KBTreeUtilJNI.KBTree_writeNewickToFile__SWIG_1(swigCPtr, this, filename, style);
  }

  public void removeNodesByNameAndSimplify(String nodeNames) {
    KBTreeUtilJNI.KBTree_removeNodesByNameAndSimplify(swigCPtr, this, nodeNames);
  }

  public void mergeZeroDistLeaves() {
    KBTreeUtilJNI.KBTree_mergeZeroDistLeaves(swigCPtr, this);
  }

  public void replaceNodeNames(String replacements) {
    KBTreeUtilJNI.KBTree_replaceNodeNames(swigCPtr, this, replacements);
  }

  public void replaceNodeNamesOrMakeBlank(String replacements) {
    KBTreeUtilJNI.KBTree_replaceNodeNamesOrMakeBlank(swigCPtr, this, replacements);
  }

  public void stripReservedCharsFromLabels() {
    KBTreeUtilJNI.KBTree_stripReservedCharsFromLabels(swigCPtr, this);
  }

  public void printTree() {
    KBTreeUtilJNI.KBTree_printTree(swigCPtr, this);
  }

  public String printSimpleTreeToString() {
    return KBTreeUtilJNI.KBTree_printSimpleTreeToString(swigCPtr, this);
  }

  public String printTreeToString() {
    return KBTreeUtilJNI.KBTree_printTreeToString(swigCPtr, this);
  }

  public long getNodeCount() {
    return KBTreeUtilJNI.KBTree_getNodeCount(swigCPtr, this);
  }

  public long getLeafCount() {
    return KBTreeUtilJNI.KBTree_getLeafCount(swigCPtr, this);
  }

  public String getAllLeafNames() {
    return KBTreeUtilJNI.KBTree_getAllLeafNames(swigCPtr, this);
  }

  public String getAllNodeNames() {
    return KBTreeUtilJNI.KBTree_getAllNodeNames(swigCPtr, this);
  }

  public void resetBreadthFirstIterToRoot() {
    KBTreeUtilJNI.KBTree_resetBreadthFirstIterToRoot(swigCPtr, this);
  }

  public boolean breadthFirstIterNext() {
    return KBTreeUtilJNI.KBTree_breadthFirstIterNext(swigCPtr, this);
  }

  public String breadthFirstIterGetName() {
    return KBTreeUtilJNI.KBTree_breadthFirstIterGetName__SWIG_0(swigCPtr, this);
  }

  public String breadthFirstIterGetParentName() {
    return KBTreeUtilJNI.KBTree_breadthFirstIterGetParentName__SWIG_0(swigCPtr, this);
  }

  public long breadthFirstIterMarkNode() {
    return KBTreeUtilJNI.KBTree_breadthFirstIterMarkNode(swigCPtr, this);
  }

  public boolean breadthFirstIterSetToNode(long nodeMarker) {
    return KBTreeUtilJNI.KBTree_breadthFirstIterSetToNode(swigCPtr, this, nodeMarker);
  }

  public String breadthFirstIterGetName(long nodeMarker) {
    return KBTreeUtilJNI.KBTree_breadthFirstIterGetName__SWIG_1(swigCPtr, this, nodeMarker);
  }

  public String breadthFirstIterGetPathToRoot(long nodeMarker) {
    return KBTreeUtilJNI.KBTree_breadthFirstIterGetPathToRoot(swigCPtr, this, nodeMarker);
  }

  public String breadthFirstIterGetParentName(long nodeMarker) {
    return KBTreeUtilJNI.KBTree_breadthFirstIterGetParentName__SWIG_1(swigCPtr, this, nodeMarker);
  }

  public String breadthFirstIterGetAllChildrenNames(long nodeMarker) {
    return KBTreeUtilJNI.KBTree_breadthFirstIterGetAllChildrenNames(swigCPtr, this, nodeMarker);
  }

  public String breadthFirstIterGetAllDescendantNames(long nodeMarker) {
    return KBTreeUtilJNI.KBTree_breadthFirstIterGetAllDescendantNames(swigCPtr, this, nodeMarker);
  }

}
