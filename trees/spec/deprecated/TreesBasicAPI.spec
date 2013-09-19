module TreesBasicAPI {
typedef string diamond;
typedef string countVector;
typedef string rectangle;

typedef structure {
	string id;
	string fasta_alignment nullable;
	int n_rows nullable;
	string metadata nullable;
	string timestamp nullable;
	int active nullable;
	int is_concatenation nullable;
	string method nullable;
	string parameters nullable;
	string protocol nullable;
	string source_db nullable;
	string source_db_id nullable;
} fields_Alignment ;

/*
An alignment of sequences (usually 
It has the following fields:

=over 4


=item id

will be unique kbase id: 'kb|ali.XXXXX'


=item fasta_alignment

Ref to file storing the alignment (using SHOCK?)


=item n_rows

number of rows in the alignment


=item metadata

e.g. name, human readable description, etc


=item timestamp




=item active




=item is_concatenation

boolean value that indicates if leaves map to single sequences, or multiple sequences


=item method

string that either maps to another dataase, to capture workflows, or is a simple method name


=item parameters

hash that stores parameter values used in the alignment


=item protocol

human readable, how did you get here with these sequences? could also map to a separate table


=item source_db

for indicating the ID in the db where this alignment originated from


=item source_db_id

for indicating the ID in the db where this alignment originated from



=back


*/
funcdef get_entity_Alignment(list<string> ids, list<string> fields)
	returns(mapping<string, fields_Alignment>);
funcdef all_entities_Alignment(int start, int count, list<string> fields)
	returns(mapping<string, fields_Alignment>);

typedef structure {
	string id;
	string alignment_id nullable;
	int alignment_row nullable;
	int concatenation_order nullable;
	string label nullable;
	string sequence_id nullable;
	string kbase_id nullable;
	int is_protein nullable;
	int begin nullable;
	int end nullable;
} fields_AlignmentRowComponent ;

/*
Individual components that make up rows in the alignment
It has the following fields:

=over 4


=item id

will be unique kbase id: 'kb|ali.XXXXX.row.XXX'



=item alignment_id

maybe needed for efficiency


=item alignment_row

number of row in the alignment


=item concatenation_order

ordering starting from left to right in alignment row


=item label

text description copied from original fasta file


=item sequence_id

MD5 for protein, probably contigChunk for DNA/RNA


=item kbase_id

kbaseID for the sequence that was actually used in the alignment


=item is_protein




=item begin




=item end





=back


*/
funcdef get_entity_AlignmentRowComponent(list<string> ids, list<string> fields)
	returns(mapping<string, fields_AlignmentRowComponent>);
funcdef all_entities_AlignmentRowComponent(int start, int count, list<string> fields)
	returns(mapping<string, fields_AlignmentRowComponent>);

typedef structure {
	string id;
	string newick_tree nullable;
	string alignment_id nullable;
	string timestamp nullable;
	string metadata nullable;
	int active nullable;
	string method nullable;
	string parameters nullable;
	string source_db nullable;
	string source_db_id nullable;
} fields_Tree ;

/*
A tree built from a multiple sequence alignment.
It has the following fields:

=over 4


=item id

A unique kbase id: eg 'kb|tree.XXXX'


=item newick_tree

leaf nodes provide a key into the AlignmentRowComponent table


=item alignment_id

maps this tree to an alignment, needed primarily for convenience


=item timestamp

time of creation (of original tree, or of kbase version?)


=item metadata

e.g. name, human readable description, etc


=item active




=item method




=item parameters




=item source_db




=item source_db_id





=back


*/
funcdef get_entity_Tree(list<string> ids, list<string> fields)
	returns(mapping<string, fields_Tree>);
funcdef all_entities_Tree(int start, int count, list<string> fields)
	returns(mapping<string, fields_Tree>);

};
