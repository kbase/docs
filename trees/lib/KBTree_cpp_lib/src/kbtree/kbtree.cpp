/**
 * @file kbtree.cpp
 * @brief KBase Tree Utility Library Implementation
 *
 * @author Michael Sneddon, mwsneddon@lbl.gov
 * @date created Jun 6, 2012, last edited Nov 2012
 */


/**
 * The tree library makes use of the C library assert functionality
 * for internal testing of the code.  Uncomment this define statement
 * when debugging, leave this statement commented to test assertions.
 * @see http://www.cplusplus.com/reference/clibrary/cassert/assert/
 */
//#define NDEBUG

// for parsing Newick strings, it is useful to define a set of
// characters we will need to identify and match frequently
#define OPEN_PARAN '('
#define CLOSE_PARAN ')'
#define COMMA ','
#define SEMICOLON ';'
#define COLON ':'
#define OPEN_BRACKET '['
#define CLOSE_BRACKET ']'
#define DBL_QUOTE '"'
#define SGL_QUOTE '\''


#include "kbtree.hh"
#include "tree.hh"
#include <iostream>
#include <fstream>
#include <algorithm>
#include <cassert>
#include <cmath>
#include <sstream>


using namespace std;
using namespace KBTreeLib;



void KBTreeLib::trim(std::string& str) {
	size_t startpos = str.find_first_not_of(" \t");
	size_t endpos = str.find_last_not_of(" \t");
	if(( string::npos == startpos ) || (string::npos == endpos)) {
		str="";
	} else {
		str = str.substr(startpos,endpos-startpos+1);
	}
}

double KBTreeLib::convertToDouble(const std::string& s)
{
	bool failIfLeftoverChars = true;
	std::istringstream i(s);
	double x; char c;
	if (!(i >> x) || (failIfLeftoverChars && i.get(c))) {
		cerr<<"Cannot convert string '"+s+"' to double value."<<endl; //,"Util::convertToDouble(\"" + s + "\")");
		throw "error in convertToDouble";
	}
	return x;
}

std::string KBTreeLib::toString(double x)
{
	std::ostringstream o;
	if (!(o << x)) {
		cerr<<"Cannot convert double to string value."<<endl;
		throw "error in toString";
	}
	return o.str();
}

std::string KBTreeLib::getQuotedString(const std::string& s)
{
	string quoted_string=""; char C;
	bool reqQuote = false;
	for(unsigned int k=0;k<s.size();k++) {
		C = s.at(k);
		if(C==DBL_QUOTE) { quoted_string+='\\'; reqQuote=true; }
		if(!reqQuote) {
			if(  C==OPEN_PARAN || C==CLOSE_PARAN  || C==COMMA         || C==SEMICOLON ||
			     C==COLON      || C==OPEN_BRACKET || C==CLOSE_BRACKET  ) {
				reqQuote=true;
			}
		}
		quoted_string+=C;
	}
	if(reqQuote) { quoted_string = "\""+quoted_string+"\""; }
	return quoted_string;
}


const unsigned int KBNode::NAME_AND_DISTANCE=0;
const unsigned int KBNode::NAME_DISTANCE_AND_COMMENTS=1;
const unsigned int KBNode::NAME_ONLY=2;
const unsigned int KBNode::DISTANCE_ONLY=3;
const unsigned int KBNode::STRUCTURE_ONLY=4;
const unsigned int KBNode::ORIGINAL_LABEL=5;

KBNode::KBNode() { clear(); }
KBNode::~KBNode() { }
void KBNode::clear()
{
	this->original_label="";
	this->name="";
	this->pre_name_decoration="";
	this->post_name_decoration="";
	this->pre_dist_decoration="";
	this->post_dist_decoration="";
	this->distanceToParent=NAN;
	this->bootstrapValue=NAN;
	this->hidden_marker="";
}

std::string KBNode::getLabelFromComponents(bool with_label, bool with_distance, bool with_comments, bool with_bootstrap_value_as_label)
{
	string constructedLabel = "";

	//add pre name comments
	if(pre_name_decoration.size()>0 && with_comments) { constructedLabel+=("["+getQuotedString(pre_name_decoration)+"]"); }
	//add label name
	if(with_label) { constructedLabel+=getQuotedString(name); }
	//or possibly a bootstrap value if name is empty and bootstrap value exists
	if(name.size()==0 && !isnan(bootstrapValue) && with_bootstrap_value_as_label) { constructedLabel+=toString(bootstrapValue); }
	//add post name comments
	if(post_name_decoration.size()>0) { constructedLabel+=("["+getQuotedString(post_name_decoration)+"]"); }

	//if we are outputting comments or distances, we need a colon.
	if( (with_distance && !isnan(distanceToParent)) || (with_comments && (pre_dist_decoration.size()>0 || post_dist_decoration.size()>0)) ) {
		constructedLabel+=":";
	}

	//add pre dist comments
	if(pre_dist_decoration.size()>0) { constructedLabel+=("["+getQuotedString(pre_dist_decoration)+"]"); }
	//add distance
	if(!isnan(distanceToParent) && with_distance) { constructedLabel+= toString(distanceToParent); }
	//add post dist comments
	if(post_dist_decoration.size()>0) {constructedLabel+=("["+getQuotedString(post_dist_decoration)+"]"); }

	return constructedLabel;
}


std::string KBNode::getLabelFromComponents(unsigned int style) {

	string constructedLabel = "";
	if(style==NAME_AND_DISTANCE) { //name:distance, distance left blank if no distance
		constructedLabel=getQuotedString(name);
		if(name.size()==0 && !isnan(bootstrapValue)) { constructedLabel+=toString(bootstrapValue); }
		if(!isnan(distanceToParent)) {
			constructedLabel+= (":"+toString(distanceToParent));
		}
	} else if (style==NAME_ONLY) { //name
		constructedLabel=getQuotedString(name);
		if(name.size()==0 && !isnan(bootstrapValue)) { constructedLabel+=toString(bootstrapValue); }
	} else if (style==DISTANCE_ONLY) { //:distance, left blank if no distance
		if(!isnan(distanceToParent)) {
			constructedLabel+= (":"+toString(distanceToParent));
		}
	} else if (style==NAME_DISTANCE_AND_COMMENTS) { //name:distance + all comments, leave nothing out
		if(pre_name_decoration.size()>0) { constructedLabel+=("["+getQuotedString(pre_name_decoration)+"]"); }
		constructedLabel+=getQuotedString(name);
		if(name.size()==0 && !isnan(bootstrapValue)) { constructedLabel+=toString(bootstrapValue); }
		if(post_name_decoration.size()>0) { constructedLabel+=("["+getQuotedString(post_name_decoration)+"]"); }
		if(pre_dist_decoration.size()>0 || !isnan(distanceToParent)) {
			constructedLabel+=":";
			if(pre_dist_decoration.size()>0) { constructedLabel+=("["+getQuotedString(pre_dist_decoration)+"]"); }
			if(!isnan(distanceToParent)) { constructedLabel+= toString(distanceToParent); }
			if(post_dist_decoration.size()>0) {constructedLabel+=("["+getQuotedString(post_dist_decoration)+"]"); }
		}
	} else if (style==ORIGINAL_LABEL) { //original parsed label
		constructedLabel=original_label;
	}
	else if (style==STRUCTURE_ONLY) { //no label, just the structure is asked for
		constructedLabel="";
	}
	return constructedLabel;
}





KBTree::KBTree(const std::string &newickString)
{
	this->nodeCount=0;
	this->verbose=false;
	this->assumeBootstrapNames=false;
	this->with_labels=true;
	this->with_distances=true;
	this->with_comments=true;
	this->with_bootstrap_values_as_labels=true;
	this->initializeFromNewick(newickString);
	this->resetBreadthFirstIterToRoot();
}
KBTree::KBTree(const std::string &newickString,bool verbose)
{
	this->nodeCount=0;
	this->verbose=verbose;
	this->assumeBootstrapNames=false;
	this->with_labels=true;
	this->with_distances=true;
	this->with_comments=true;
	this->with_bootstrap_values_as_labels=true;
	this->initializeFromNewick(newickString);
	this->resetBreadthFirstIterToRoot();
}
KBTree::KBTree(const std::string &newickString,bool verbose,bool assumeBootstrapNames)
{
	this->nodeCount=0;
	this->verbose=verbose;
	this->assumeBootstrapNames=assumeBootstrapNames;
	this->with_labels=true;
	this->with_distances=true;
	this->with_comments=true;
	this->with_bootstrap_values_as_labels=true;
	this->initializeFromNewick(newickString);
	this->resetBreadthFirstIterToRoot();
}

KBTree::~KBTree()
{
	this->tr.clear();
}

void KBTree::initializeFromNewick(const std::string &newickString)
{
	// create and add the root node
	if(verbose) { cout<<"KBTREE-- initializing tree from newick string"<<endl; }
	tr.set_head(KBNode());
	this->nodeCount++;
	unsigned int curserPosition = 0;
	// go on and parse the rest recursively
	tree<KBNode>::iterator rootIter = tr.begin();
	parseNewick(newickString,curserPosition,rootIter);
}


void printPos(const std::string &newickString, unsigned int &k)
{
	for(unsigned int j=0;j<k;j++) { cout<<" "; }
	cout<<"|"<<endl;
	cout<<newickString<<endl;
}

void KBTree::parseNewick(const std::string &newickString, unsigned int &k, tree<KBNode>::iterator &currentNode)
{
	// ditch leading white space first
	passLeadingWhiteSpace(newickString, k);
	if( k >= newickString.length() ) return;

	// if we get to an open parenthesis, then create a child and recurse down
	if( newickString.at(k)==OPEN_PARAN ) {
		//cout<<"OPEN"<<endl;printPos(newickString,k);
		// note here that the begin iterator points to the first child of the current node
		tree<KBNode>::iterator newChild = tr.insert(currentNode.begin(),KBNode());
		this->nodeCount++;
		k=k++;
		if( k >= newickString.length() ) { cerr<<"syntax error in tree"<<endl; exit(1); }
		if(newickString.at(k)!=CLOSE_PARAN) {
			parseNewick(newickString,k,newChild);
		}
	}

	// If we get here, then we are ready to label it
	getNextLabel(newickString,k,(*currentNode));
	// if it is an internal node and has a name and we are assuming that internal node names are bootstrap values,
	// then update the parsing. (note that this is the case for most MO trees)
	if(this->assumeBootstrapNames && currentNode.number_of_children()>0 && (*currentNode).getName().size()>0) {
		try {
			(*currentNode).bootstrapValue = convertToDouble((*currentNode).name);
			(*currentNode).name="";
		} catch (...) {
			this->assumeBootstrapNames = false;
			cerr<<"assuming that internal nodes are NOT bootstrap values"<<endl;
		}
	}

	// if we get to a close parenthesis, then go on to the next position in the string
	// and return back up the hierarchy
	if( k >= newickString.length() ) { return; }
	if (newickString.at(k)==CLOSE_PARAN) {
		//cout<<"CLOSE"<<endl;printPos(newickString,k);
		k++;
		return;
	}

	//again make sure we can go further
	if( k >= newickString.length() ) return;

	// If we get to a comma, then the current node has some siblings, so recurse on the sibling node
	if (newickString.at(k)==COMMA) {
		//cout<<"COMMA"<<endl;printPos(newickString,k);
		tree<KBNode>::iterator newSibling = tr.insert_after(currentNode,KBNode());
		this->nodeCount++;
		k++;
		parseNewick(newickString,k,newSibling);
	}
}





/**
 * ignores comments (normally denoted by [..]), but does detect the first colon found and splits the string into names and distances
 * simply includes quotes as is in the strings without conversion
 */
bool KBTree::getNextLabelWithoutComments(const std::string &newickString, unsigned int &k, KBNode &node)
{
	std::string label = "";
	std::string nameString="";
	std::string distanceToParentString = "";

	bool afterColonOperator = false;
	char C;
	while( k<newickString.size() ) {
		C=newickString.at(k);

		// if we have to move somewhere else in the tree structure, then break (skipping over the closing semicolon)
		if ( C==OPEN_PARAN || C==CLOSE_PARAN || C==COMMA ) { break; }
		if ( C==SEMICOLON ) { k++; break; }

		// determine if we are before or after the colon (indicates name vs. distance)
		if(afterColonOperator) { distanceToParentString += C; }
		if (C==COLON) { afterColonOperator = true; }
		if(!afterColonOperator) { nameString += C; }

		//always add the character to be part of the label
		label += C;
		k++;
	}
	trim(label);trim(nameString);trim(distanceToParentString);
	node.original_label.assign(label);
	node.name.assign(nameString);
	if(distanceToParentString.size()>0) { node.distanceToParent = convertToDouble(distanceToParentString); }
	return true;
}




void getQuotedText(const std::string &newickString, unsigned int &k, string &quotedText, string &rawLabel, char QUOTE) {
	// grab the quote, because we need to include this in the raw label
	rawLabel+=newickString.at(k);
	k++;
	assert(k>=1);
	quotedText="";
	while( k<newickString.size() ) {
		assert(k+1<newickString.size());
		char C = newickString.at(k);
		//cout<<"  *gots:"<<C<<endl;
		if(C=='\\' && newickString.at(k+1)==QUOTE ) {
			rawLabel+=C;
			k++; C=newickString.at(k);
		}
		else if(C==QUOTE && newickString.at(k-1)!='\\' ) { break; }
		rawLabel+=C;
		quotedText+=C;
		k++;
	}
	//cout<<"**got it chief!"<<endl;
}

bool KBTree::getNextLabel(const std::string &newickString, unsigned int &k, KBNode &node)
{
	// reserve all of the components that might be needed to label the Node
	std::string label = "";
	std::string distanceToParentString = "";
	std::string nameString = "";
	std::string preNameComment  = "";
	std::string postNameComment = "";
	std::string preDistComment  = "";
	std::string postDistComment = "";

	// keep track of what we are currently parsing
	unsigned int commentType = 0; // 0=name/distance/delimeter, 1=preName, 2=postName, 3=preDist, 4=postDist
	bool afterColonOperator = false;
	bool quotedTextWasFound = false;

	char C; string textToAdd;
	while( k<newickString.size() ) {

		// first things first - get the next character
		C=newickString.at(k);

		// Now handle anything in quotes.  Note how this is a bit deceptive.  We first save the character to
		// the textToAdd string.  This will be the text that we eventually add to the comment, name, or distance
		// strings.  By default we set it to be just the value of the current character that we see.  But if that
		// character is a quote, then we parse the entire quote and overwrite the variable textToAdd.  Then later,
		// we can simply add textToAdd to the appropriate string.  Note that this also advances k such that we
		// won't try to parse anything inside the quoted string as a special character
		textToAdd=""; textToAdd+=C; quotedTextWasFound=false;
		if ( C==SGL_QUOTE ) { getQuotedText(newickString,k,textToAdd,label,SGL_QUOTE); }
		if ( C==DBL_QUOTE ) { getQuotedText(newickString,k,textToAdd,label,DBL_QUOTE); }

		//detect if we have to close a comment block (asserting that a comment was previously open)
		//should we force that a ']' cannot be used unless it is in a comment or quoted string? I think so.
		if ( C==CLOSE_BRACKET ) {
			assert(commentType!=0);
			commentType = 0;
		}

		//if we aren't closing a comment, then we should add the next character or quoted text to
		//something, or detect that it is a special character
		else {
			//handle cases where we are in comments first, adding either the character or the quoted text
			if(commentType==1)       { preNameComment+=textToAdd;  }
			else if(commentType==2)  { postNameComment+=textToAdd; }
			else if(commentType==3)  { preDistComment+=textToAdd;  }
			else if(commentType==4)  { postDistComment+=textToAdd; }

			// if we are not in a comment, then we can process special characters or determine if the character or
			// quoted text should be placed in a name or distanceFromParent string
			else if(commentType==0) {

				// if we have to move somewhere else in the tree structure, then break (skipping over the closing semicolon)
				if ( C==OPEN_PARAN || C==CLOSE_PARAN || C==COMMA ) { assert(commentType==0); break; }
				if ( C==SEMICOLON ) { assert(commentType==0); k++; break; }

				// detect if we are opening a comment block, and determine where this block appears
				if ( C==OPEN_BRACKET ) {
					trim(distanceToParentString); trim(nameString);
					if(afterColonOperator) {
						if(distanceToParentString.size()==0) { commentType=3; }
						else { commentType=4; }
					} else {
						if(nameString.size()==0) { commentType = 1; }
						else {commentType = 2; }
					}
				}
				// if we get here, then we have to add the character or quoted text to the name/distance strings
				else{
					// determine if we are before or after the colon (indicates name vs. distance)
					if(afterColonOperator) { distanceToParentString += textToAdd; }
					if (newickString.at(k)==COLON) { afterColonOperator = true; }
					if(!afterColonOperator) { nameString += textToAdd; }
				}
			}
		}

		//always add the character to be part of the label (note that quoted text was already added above if it was found)
		label += C;
		k++;
	}
	trim(label); trim(nameString);

	node.original_label.assign(label);
	node.name.assign(nameString);
	trim(distanceToParentString);
	if(distanceToParentString.size()>0) { node.distanceToParent = convertToDouble(distanceToParentString); }
	node.pre_name_decoration.assign(preNameComment);
	node.post_name_decoration.assign(postNameComment);
	node.pre_dist_decoration.assign(preDistComment);
	node.post_dist_decoration.assign(postDistComment);
	if(verbose) {
		cout<<"KBTREE-- parsed node details:"<<endl;
		cout<<"KBTREE--   LABEL=>'"<<label<<"'"<<endl;
		cout<<"KBTREE--   NAME=>'"<<nameString<<"'"<<endl;
		cout<<"KBTREE--   DIST=>'"<<distanceToParentString<<"'"<<endl;

		cout<<"KBTREE--   PRENAME=>'"<<preNameComment<<"'"<<endl;
		cout<<"KBTREE--   POSTNAME=>'"<<postNameComment<<"'"<<endl;
		cout<<"KBTREE--   PREDIST=>'"<<preDistComment<<"'"<<endl;
		cout<<"KBTREE--   POSTDIST=>'"<<postDistComment<<"'"<<endl;
	}
	return true;
}

void KBTree::passLeadingWhiteSpace(const std::string &newickString, unsigned int &k)
{
	char C=newickString.at(k);
	while( k<newickString.size() ) {
		if( C!=' ' && C!='\t' && C!='\n' && C!='\r' ) {
			break;
		}
		C=newickString.at(++k);
	}
}

void KBTree::printTree() { printTree(cout); }
std::string KBTree::printSimpleTreeToString() {
	string pretty_tree;
	tree<KBNode>::pre_order_iterator it  =this->tr.begin();
	tree<KBNode>::pre_order_iterator end =this->tr.end();
	int rootdepth=tr.depth(it);
	while(it!=end) {
		for(int i=0; i<tr.depth(it)-rootdepth; ++i) { pretty_tree += "   "; }
		pretty_tree += " -";
		pretty_tree += (*it).name; pretty_tree+="\n";
		++it;
	}
	return pretty_tree;
}

std::string KBTree::printTreeToString() {
	std::stringstream ss;
	printTree(ss);
	return ss.str();
}
void KBTree::printTree(ostream &o) {
	KBTree::printTree(o,this->tr,this->tr.begin(),this->tr.end());
}

void KBTree::printTree(ostream &o, const tree<KBNode>& tr, tree<KBNode>::pre_order_iterator it, tree<KBNode>::pre_order_iterator end)
{
	o<<"*****************"<<endl;
	o<<"Tree Size: "<<tr.size()<<endl;
	if(!tr.is_valid(it)) return;
	int rootdepth=tr.depth(it);
	o << "-----" << std::endl;
	while(it!=end) {
		for(int i=0; i<tr.depth(it)-rootdepth; ++i)
			o << "  ";
		string full_label = (*it).getLabelFromComponents(KBNode::NAME_DISTANCE_AND_COMMENTS);
		o << (*it).name<<"   (dist="<<(*it).distanceToParent <<",full="<<full_label<<")"<< std::endl << std::flush;
		++it;
	}
	o << "*****************" << std::endl;
}


void printAllNodes(ostream &o)
{
//	for(int i=0;i<node_list.size();i++) {
//		o<<"["<<i<<"]:'"<<node_list.at(i)->label<<"'";
//		if(node_list.at(i)->firstChild!=NULL) o<<", firstChild='"<<node_list.at(i)->firstChild->label<<"'";
//		if(node_list.at(i)->right!=NULL) o<<", right='"<<node_list.at(i)->right->label<<"'";
//		if(node_list.at(i)->parent!=NULL) o<<", parent='"<<node_list.at(i)->parent->label<<"'";
//		o<<endl;
//	}
}




std::string KBTree::toNewick() {
	// retrieve the root node, then call the recursive version of this function
	std::string newickString="";
	tree<KBNode>::iterator rootIter = tr.begin();
	toNewick(rootIter, newickString);
	return newickString;
}

std::string KBTree::toNewick(unsigned int style)
{
	// retrieve the root node, then call the recursive version of this function
	std::string newickString="";
	tree<KBNode>::iterator rootIter = tr.begin();
	toNewick(rootIter, newickString,style);
	return newickString;
}



void KBTree::toNewick(tree<KBNode>::iterator &currentNode, std::string &newickString)
{
	assert(currentNode!=NULL);
	//cout<<"here:"<<newickString<<":"<<(*currentNode)->label<<endl;
	// First check if we have children, if we do then descend to that child
	if(tree<KBNode>::number_of_children(currentNode)>0) {
		//cout<<"  -num of children>0"<<endl;
		newickString+="(";
		tree<KBNode>::iterator childIter = currentNode.begin();
		toNewick(childIter,newickString);
	}

	// Next check if we have siblings, and if so we have to go there next
	tree<KBNode>::iterator sibling = tr.next_sibling(currentNode);
	if(sibling!=NULL && sibling!=tr.end()) {
		// if we have a next sibling, then go there
		//cout<<"  -num of siblings>0"<<endl;
		newickString+=(*currentNode).getLabelFromComponents(this->with_labels, this->with_distances, this->with_comments, this->with_bootstrap_values_as_labels);
		newickString+=",";
		toNewick(sibling,newickString);
	}

	// If we don't have siblings, do we have a parent? if so go back up
	else if(tr.parent(currentNode)!=NULL && tr.parent(currentNode)!=tr.end()) {
		//cout<<"  -has parent"<<endl;
		newickString+=(*currentNode).getLabelFromComponents(this->with_labels, this->with_distances, this->with_comments, this->with_bootstrap_values_as_labels);
		newickString+=")";
	}

	// And finally, if we don't have a parent, then we're back at root,
	// so print the label and close the tree with a semicolon.
	else {
		//cout<<"  -no siblings, no parent"<<endl;
		newickString+=(*currentNode).getLabelFromComponents(this->with_labels, this->with_distances, this->with_comments, this->with_bootstrap_values_as_labels);
		newickString+=";";
	}
}


void KBTree::toNewick(tree<KBNode>::iterator &currentNode, std::string &newickString, unsigned int style)
{
	assert(currentNode!=NULL);
	//cout<<"here:"<<newickString<<":"<<(*currentNode)->label<<endl;
	// First check if we have children, if we do then descend to that child
	if(tree<KBNode>::number_of_children(currentNode)>0) {
		//cout<<"  -num of children>0"<<endl;
		newickString+="(";
		tree<KBNode>::iterator childIter = currentNode.begin();
		toNewick(childIter,newickString,style);
	}

	// Next check if we have siblings, and if so we have to go there next
	tree<KBNode>::iterator sibling = tr.next_sibling(currentNode);
	if(sibling!=NULL && sibling!=tr.end()) {
		// if we have a next sibling, then go there
		//cout<<"  -num of siblings>0"<<endl;
		newickString+=(*currentNode).getLabelFromComponents(style);
		newickString+=",";
		toNewick(sibling,newickString,style);
	}

	// If we don't have siblings, do we have a parent? if so go back up
	else if(tr.parent(currentNode)!=NULL && tr.parent(currentNode)!=tr.end()) {
		//cout<<"  -has parent"<<endl;
		newickString+=(*currentNode).getLabelFromComponents(style);
		newickString+=")";
	}

	// And finally, if we don't have a parent, then we're back at root,
	// so print the label and close the tree with a semicolon.
	else {
		//cout<<"  -no siblings, no parent"<<endl;
		newickString+=(*currentNode).getLabelFromComponents(style);
		newickString+=";";
	}
}


void KBTree::removeNodesByNameAndSimplify(const std::string &nodeNames)
{
	map<string,string> nodeNameMap;
	string delimiters = ";",name="";
	size_t current; size_t next = -1;
	do {
		current = next + 1;
		next = nodeNames.find_first_of( delimiters, current );
		name = nodeNames.substr( current, next - current );
		trim(name);
		if(name.size()==0) { continue; }
		if(nodeNameMap.find(name)==nodeNameMap.end()) {
			nodeNameMap.insert(pair<string,string>(name,""));
		} else {
			cout<<"++KBTREE WARNING--  YOU PROVIDED TWO NODES TO BE REMOVED IN THE LIST THAT HAVE THE SAME NAME: '"<<name<<"'"<<endl;
		}
	}
	while (next != string::npos);
	removeNodesByNameAndSimplify(nodeNameMap);
}


void KBTree::removeNodesByNameAndSimplify(std::map<std::string,std::string> &nodeNames)
{
	// loop through the nodes in a depth-first, post-order traversal
	// thus, as we look at each node, we can assume all nodes below have been processed
	bool nodeWasErased=false;
	tree<KBNode>::post_order_iterator node = tr.begin_post();
	while(node!=tr.end_post()) {
		// look for this node in the removal list (only if it has some non-empty name)
		if((*node).getName().size()>0) {
			map<string,string>::iterator nodeIter=nodeNames.find((*node).getName());
			if( nodeIter!=nodeNames.end() ) {
				if( (nodeIter->second).size()!=0) {
					if(verbose) { cout<<"++KBTREE WARNING--   MORE THAN ONE NODE NAMED: '"<<(*node).getName()<<"' IS BEING REMOVED"<<endl;}
				}
				nodeIter->second="+";
				// if we are a leaf node, then just erase
				if(tr.number_of_children(node)==0) {
					if(verbose) { cout<<"KBTREE--   REMOVING LEAF NODE NAMED: '"<<(*node).getName()<<"'"<<endl;}
					tree<KBNode>::post_order_iterator nodeToBeAxed(node); node++;
					tr.erase(nodeToBeAxed); nodeCount--;
					nodeWasErased=true;
				}
				// if we have children, then we must replace this node with its child
				else {
					if(verbose) { cout<<"KBTREE--   REMOVING INTERNAL NODE NAMED: '"<<(*node).getName()<<"'"<<endl;}
					//refactor distances to the child by adding the edge lengths
					if(node.has_parent()) {
						double distFromThisNodeToParent = (*node).distanceToParent;
						for(tree<KBNode>::sibling_iterator child=node.begin(); child!=tr.end(child); child++) {
							(*child).distanceToParent += distFromThisNodeToParent;
						}
						tree<KBNode>::post_order_iterator nodeToBeAxed(node); node++;
						tr.erase_and_reparent_children(nodeToBeAxed); nodeCount--;
						nodeWasErased=true;
					} else {
						cerr<<"!!KBTREE ERROR-- CANNOT REMOVE ROOT NODE FROM TREE."<<endl;
						exit(1);
					}
				}
			}
		}
		else {
			// if node is unamed and has only zero or one children and is not the root node (has no parent), then remove
			if(node.has_parent()) {
				if(((*node).getName()).size()==0) {
					if(tr.number_of_children(node)==0) {
						if(verbose) { cout<<"KBTREE--   REMOVING UNAMED LEAF NODE"<<endl;}
						tree<KBNode>::post_order_iterator nodeToBeAxed(node); node++;
						tr.erase(nodeToBeAxed); nodeCount--;
						nodeWasErased=true;
					}
					else if (tr.number_of_children(node)==1) {
						if(verbose) { cout<<"KBTREE--   REMOVING UNAMED INTERNAL NODE WITH ONE CHILD"<<endl;}
						// manage distances! distance from the removal node's parent to it's new child should be the sum of the
						// distances (so that the total distance to the leaf nodes are conserved).  So update that first.  Note
						// that if we are here, there is only one possible child, so we only have to update that single child.
						double distFromThisNodeToParent = (*node).distanceToParent;
						(*(node.begin())).distanceToParent += distFromThisNodeToParent;
						tree<KBNode>::post_order_iterator nodeToBeAxed(node); node++;
						tr.erase_and_reparent_children(nodeToBeAxed); nodeCount--;
						nodeWasErased=true;
					}

				}
			}
		}
		// finally, check if the current node was erased, and handle accordingly
		if(nodeWasErased) {
			nodeWasErased=false;
		} else {
			node++; // only advance here if the node was not erased (if it was, the iter was already advanced)
		}
	}
	for(std::map<std::string,std::string>::iterator it=nodeNames.begin();it!=nodeNames.end();it++) {
		if(it->second.size()==0) {
			cout<<"++KBTREE WARNING--   UNABLE TO FIND AND REMOVE NODE NAMED: '"<<it->first<<"'"<<endl;
		}
	}

}



void KBTree::replaceNodeNames(const std::string &replacements) {
	map<string,string> nodeNameMap;
	string delimiters = ";",fromName="",toName="";
	size_t current; size_t next = -1;
	do {
		current = next + 1;
		next = replacements.find_first_of( delimiters, current );
		fromName = replacements.substr( current, next - current );
		trim(fromName);

		current = next + 1;
		next = replacements.find_first_of( delimiters, current );
		toName = replacements.substr( current, next - current );
		trim(toName);

		if(fromName.size()==0) { continue; }
		if(nodeNameMap.find(fromName)==nodeNameMap.end()) {
			nodeNameMap.insert(pair<string,string>(fromName,toName));
		} else {
			cout<<"++KBTREE WARNING--  YOU PROVIDED TWO NODES TO BE RENAMED IN THE LIST THAT HAVE THE SAME NAME: '"<<fromName<<"'"<<endl;
		}
	}
	while (next != string::npos);
	replaceNodeNames(nodeNameMap);
}

void KBTree::replaceNodeNamesOrMakeBlank(const std::string &replacements) {
	map<string,string> nodeNameMap;
	string delimiters = ";",fromName="",toName="";
	size_t current=0; size_t next = 0;
	do {
		//if we are starting the list, then start at zero
		if(next==0) { current=0; }
		else { current = next + 1; }
		if(current>replacements.length()-1) { break; }
		next = replacements.find_first_of( delimiters, current );
		fromName = replacements.substr( current, next - current );
		trim(fromName);
		
		current = next + 1;
		next = replacements.find_first_of( delimiters, current );
		toName = replacements.substr( current, next - current );
		trim(toName);

		if(fromName.size()==0) { continue; }
		if(nodeNameMap.find(fromName)==nodeNameMap.end()) {
			nodeNameMap.insert(pair<string,string>(fromName,toName));
		} else {
			cout<<"++KBTREE WARNING--  YOU PROVIDED TWO NODES TO BE RENAMED IN THE LIST THAT HAVE THE SAME NAME: '"<<fromName<<"'"<<endl;
		}
	}
	while (next != string::npos);
	replaceNodeNames(nodeNameMap,true);
}

void KBTree::replaceNodeNames(std::map<std::string,std::string> &nodeNames) {
	replaceNodeNames(nodeNames,false);
}
void KBTree::replaceNodeNames(std::map<std::string,std::string> &nodeNames, bool defaultToBlankIfNotFound)
{
	tree<KBNode>::post_order_iterator node;
	map<string,string>::iterator name;
	for(node=tr.begin_post(); node!=tr.end_post(); node++) {
		name = nodeNames.find((*node).getName());
		if(verbose) { cout<<"looking at node:"<<(*node).getName()<<endl; }
		if( name!=nodeNames.end() ) {
			(*node).name=name->second;
		} else if(defaultToBlankIfNotFound) {
			(*node).name="";
		}
	}
}



void KBTree::mergeZeroDistLeaves() {

	// we proceed in two steps.  First, we go through the entire tree and find the children
	// that are zero distance.  We mark the parent if we found one for the first node we encounter,
	// so that siblings can be marked for deletion. Marking for deletion is as simple as renaming
	// the node to some string that (probably :) ) no one will use as a valid node name. Step
	// two, we simply call the method to remove marked nodes and simplify the tree.
	tree<KBNode>::post_order_iterator node;
	map<string,string>::iterator name;
	for(node=tr.begin_post(); node!=tr.end_post(); node++) {
	
		if (tr.number_of_children(node)==0) {
			if( !isnan((*node).getDistanceToParent()) ) {
				if( (*node).getDistanceToParent()==0 ) {
					if(verbose) {
						cout<<"looking at node:"<<(*node).getName()<<endl;
						cout<<"distance to parent: "<<(*node).getDistanceToParent()<<endl;
						cout<<"parent marker: '" << (*tr.parent(node)).getHiddenMarkerLabel() <<"'"<< endl;
					}
					if((*tr.parent(node)).getHiddenMarkerLabel().compare("")==0) {
						(*tr.parent(node)).setHiddenMarkerLabel("marked");
						if(verbose) { cout<<"unmarked parent is now marked"<<endl; }
					} else {
						(*node).name="THE_SECRET_CODE_TO_DELETE_THIS_NODE_HACK";
						if(verbose) { cout<<"i have decided to delete this node."<<endl; }
					}
				}
			}
		}
		
	}
	
	// carry out step 2
	map<string,string> nodeNameMap;
	nodeNameMap.insert(pair<string,string>("THE_SECRET_CODE_TO_DELETE_THIS_NODE_HACK",""));
	removeNodesByNameAndSimplify(nodeNameMap);
}







bool KBTree::writeNewickToFile(const std::string &filename) {
	return writeNewickToFile(filename,KBNode::NAME_AND_DISTANCE);
}
bool KBTree::writeNewickToFile(const std::string &filename,unsigned int style) {
	ofstream outputFileStream;
	outputFileStream.open(filename.c_str());
	if(!outputFileStream.is_open()) {
		cerr<<"!!KBTREE ERROR-- CANNOT OPEN OUTPUT STREAM TO FILE: '"<<filename<<"'"<<endl;
		return false;
	}
	outputFileStream << toNewick(style);
	outputFileStream.close();
	return true;
}



std::string KBTree::getAllLeafNames()
{
	std::string leafNames="";
	tree<KBNode>::leaf_iterator leafIter;
	for(leafIter=tr.begin_leaf(); leafIter!=tr.end_leaf(); leafIter++) {
		string name = (*leafIter).getName();
		if(name.size()>0) { leafNames += name; leafNames+=";"; }
	}
	return leafNames;
}
void KBTree::getAllLeafNames(vector<string> &names) {
	tree<KBNode>::leaf_iterator leafIter;
	names.reserve((size_t)(1+getNodeCount()/2)); //assume full binary tree of leaves
	for(leafIter=tr.begin_leaf(); leafIter!=tr.end_leaf(); leafIter++) {
		string name = (*leafIter).getName();
		if(name.size()>0) { names.push_back(name); }
	}
}

std::string KBTree::getAllNodeNames()
{
	std::string nodeNames="";
	tree<KBNode>::post_order_iterator nodeIter;
	for(nodeIter=tr.begin_post(); nodeIter!=tr.end_post(); nodeIter++) {
		string name = (*nodeIter).getName();
		if(name.size()>0) { nodeNames += name; nodeNames+=";"; }
	}
	return nodeNames;
}
void KBTree::getAllNodeNames(vector<string> &names) {
	names.reserve((size_t)(1+getNodeCount()));
	tree<KBNode>::post_order_iterator nodeIter;
	for(nodeIter=tr.begin_post(); nodeIter!=tr.end_post(); nodeIter++) {
		string name = (*nodeIter).getName();
		if(name.size()>0) { names.push_back(name); }
	}

}


void KBTree::stripReservedCharsFromLabels() {
	tree<KBNode>::post_order_iterator nodeIter;
	for(nodeIter=tr.begin_post(); nodeIter!=tr.end_post(); nodeIter++) {
		string name = (*nodeIter).getName();
		string stripped_name = "";
		for (size_t i=0; i < name.length(); i++) {
			if(name.at(i)==' ') { stripped_name += '_'; }
			else if(name.at(i)==':') { stripped_name += '-'; }
			else if(name.at(i)==';') { stripped_name += '-'; }
			else if(name.at(i)==',') { stripped_name += '-'; }
			else if(name.at(i)=='(') { stripped_name += '{'; }
			else if(name.at(i)==')') { stripped_name += '}'; }
			else if(name.at(i)=='[') { stripped_name += '{'; }
			else if(name.at(i)==']') { stripped_name += '}'; }
			else { stripped_name += name.at(i); }
		}
		(*nodeIter).name = stripped_name;
	}
}



void KBTree::printOutNamesAllPossibleTraversals(ostream &o)
{
	tree<KBNode>::leaf_iterator leafIter;
	for(leafIter=tr.begin_leaf(); leafIter!=tr.end_leaf(); leafIter++) {
		o<<"leafIter::"<<(*leafIter).getName()<<" "<<leafIter.number_of_children()<<endl;

	}
	tree<KBNode>::post_order_iterator nodeIter;
	for(nodeIter=tr.begin_post(); nodeIter!=tr.end_post(); nodeIter++) {
		o<<"postOrderDF::"<<(*nodeIter).getName()<<endl;
	}

	tree<KBNode>::pre_order_iterator preNodeIter;
	for(preNodeIter=tr.begin(); preNodeIter!=tr.end(); preNodeIter++) {
		o<<"preOrderDF::"<<(*preNodeIter).getName()<<endl;
	}

	tree<KBNode>::breadth_first_queued_iterator bfNodeIter;
	for(bfNodeIter=tr.begin_breadth_first(); bfNodeIter!=tr.end_breadth_first(); bfNodeIter++) {
		o<<"breadthFirst::"<<(*bfNodeIter).getName()<<endl;
	}
}

unsigned int KBTree::getLeafCount()
{
	int leafNodeCount=0;
	for(tree<KBNode>::leaf_iterator leafIter=tr.begin_leaf(); leafIter!=tr.end_leaf(); leafIter++) {
		leafNodeCount++;
	}
	return leafNodeCount;
}



///////////////////////////////////////////////////////////////////////////////////////////
// set of methods to traverse a tree, node by node, in a breadth first search, and mark specific
// nodes for future fast retrieval.
void KBTree::resetBreadthFirstIterToRoot() {
	this->bfi = tr.begin_breadth_first();
}
bool KBTree::breadthFirstIterNext() {
	if(this->bfi!=tr.end_breadth_first()) {
		bfi++;
		if(this->bfi!=tr.end_breadth_first()) {
			return true;
		}
	}
	return false;
}
std::string KBTree::breadthFirstIterGetName() {
	if(this->bfi!=tr.end_breadth_first()) {
		return (*bfi).getName();
	}
	return "END_OF_KB_TREE";
}

std::string KBTree::breadthFirstIterGetParentName() {
	if(bfi.has_parent()) {
		return (*tr.parent(bfi)).getName();
	}
	return "";
}
unsigned int KBTree::breadthFirstIterMarkNode() {
	this->bfiNodeIndex.push_back(tree<KBNode>::breadth_first_iterator(this->bfi));
	return bfiNodeIndex.size()-1;
}
bool KBTree::breadthFirstIterSetToNode(unsigned int nodeMarker) {
	if(this->bfiNodeIndex.size()<=nodeMarker) {
		this->bfi = tr.end_breadth_first();
		return false;
	}
	this->bfi = tree<KBNode>::breadth_first_queued_iterator(this->bfiNodeIndex.at(nodeMarker));
	return true;
}



std::string KBTree::breadthFirstIterGetName(unsigned int nodeMarker) {
	if(this->bfiNodeIndex.size()<=nodeMarker) { return ""; }
	// grab a copy of the iterator at the marker position
	tree<KBNode>::breadth_first_queued_iterator node = tree<KBNode>::breadth_first_queued_iterator(this->bfiNodeIndex.at(nodeMarker));
	if(node!=tr.end_breadth_first()) {
		return (*node).getName();
	}
	return "";
}

std::string KBTree::breadthFirstIterGetPathToRoot(unsigned int nodeMarker) {
	if(this->bfiNodeIndex.size()<=nodeMarker) { return ""; }
	// grab a copy of the iterator at the marker position
	tree<KBNode>::breadth_first_queued_iterator node = tree<KBNode>::breadth_first_queued_iterator(this->bfiNodeIndex.at(nodeMarker));
	std::string path="";
	while( node.has_parent() ){
		node = tr.parent(node);
		path += (*node).getName()+";";
	}
	return path;
}

std::string KBTree::breadthFirstIterGetParentName(unsigned int nodeMarker) {
	if(this->bfiNodeIndex.size()<=nodeMarker) { return ""; }
	// grab a copy of the iterator at the marker position
	tree<KBNode>::breadth_first_queued_iterator node = tree<KBNode>::breadth_first_queued_iterator(this->bfiNodeIndex.at(nodeMarker));
	if(node.has_parent()) {
		return (*tr.parent(node)).getName();
	}
	return "";
}

std::string KBTree::breadthFirstIterGetAllChildrenNames(unsigned int nodeMarker) {
	if(this->bfiNodeIndex.size()<=nodeMarker) { return ""; }
	// grab a copy of the iterator at the marker position
	tree<KBNode>::breadth_first_queued_iterator node = tree<KBNode>::breadth_first_queued_iterator(this->bfiNodeIndex.at(nodeMarker));
	std::string namelist = "";
	for(tree<KBNode>::sibling_iterator child = tr.begin(node);child!=tr.end(node);child++) {
		namelist+=(*child).getName()+";";
	}
	return namelist;
}

std::string KBTree::breadthFirstIterGetAllDescendantNames(unsigned int nodeMarker) {
	if(this->bfiNodeIndex.size()<=nodeMarker) { return ""; }
	std::string namelist = "";
	// grab a copy of the iterator at the marker position
	tree<KBNode>::breadth_first_queued_iterator node( this->bfiNodeIndex.at(nodeMarker) );
	node.clear(); // clear the queue so we only search the subtree
	node++; // drop the given node, cause we don't want to return that one.
	for(; node!=tr.end_breadth_first(); node++) {
		namelist+=(*node).getName()+";";
	}
	return namelist;
}




