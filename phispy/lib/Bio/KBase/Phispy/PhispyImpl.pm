package Bio::KBase::Phispy::PhispyImpl;
use strict;
use Bio::KBase::Exceptions;
# Use Semantic Versioning (2.0.0-rc.1)
# http://semver.org 
our $VERSION = "0.1.0";

=head1 NAME

Phispy

=head1 DESCRIPTION

This service wraps the PhiSpy service as defined at
http://sourceforge.net/projects/phispy.

=cut

#BEGIN_HEADER
use File::Temp;
#END_HEADER

sub new
{
    my($class, @args) = @_;
    my $self = {
    };
    bless $self, $class;
    #BEGIN_CONSTRUCTOR
    #END_CONSTRUCTOR

    if ($self->can('_init_instance'))
    {
	$self->_init_instance();
    }
    return $self;
}

=head1 METHODS



=head2 get_all_training_sets

  $return = $obj->get_all_training_sets()

=over 4

=item Parameter and return types

=begin html

<pre>
$return is a reference to a list where each element is a TrainingSet
TrainingSet is a reference to a hash where the following keys are defined:
	training_set_id has a value which is an int
	genome_name has a value which is a string

</pre>

=end html

=begin text

$return is a reference to a list where each element is a TrainingSet
TrainingSet is a reference to a hash where the following keys are defined:
	training_set_id has a value which is an int
	genome_name has a value which is a string


=end text



=item Description

Retrieve all available training sets.

=back

=cut

sub get_all_training_sets
{
    my $self = shift;

    my $ctx = $Bio::KBase::Phispy::Service::CallContext;
    my($return);
    #BEGIN get_all_training_sets
    my $training_set_file = "$ENV{KB_RUNTIME}/phispy/data/trainingGenome_list.txt";
    $return = [];
    if (open(F, "<", $training_set_file))
    {
	while (<F>)
	{
	    chomp;
	    my($id, $x1, $name, $multiple_flag) = split(/\t/);
	    if ($multiple_flag)
	    {
		push(@$return, { training_set_id => $id, 
				 genome_name => $name });
	    }
	}
	close(F);
    }
    else
    {
	warn "Could not open training set file $training_set_file: $!";
    }
    #END get_all_training_sets
    my @_bad_returns;
    (ref($return) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"return\" (value was \"$return\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_all_training_sets:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_all_training_sets');
    }
    return($return);
}




=head2 find_prophages

  $return_1, $analysis = $obj->find_prophages($training_set_id, $genomeTO)

=over 4

=item Parameter and return types

=begin html

<pre>
$training_set_id is an int
$genomeTO is a genomeTO
$return_1 is a genomeTO
$analysis is a reference to a list where each element is a prophage_feature
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	contigs has a value which is a reference to a list where each element is a contig
	features has a value which is a reference to a list where each element is a feature
genome_id is a string
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
contig_id is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	annotations has a value which is a reference to a list where each element is an annotation
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 3 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
prophage_feature is a reference to a list containing 15 items:
	0: a feature_id
	1: a contig_id
	2: (start) an int
	3: (stop) an int
	4: (position) an int
	5: (rank) a float
	6: (my_status) a float
	7: (pp) a float
	8: (final_status) an int
	9: (start_of_attL) an int
	10: (end_of_attL) an int
	11: (start_of_attR) an int
	12: (end_of_attR) an int
	13: (sequence_of_attL) a string
	14: (sequence_of_attR) a string

</pre>

=end html

=begin text

$training_set_id is an int
$genomeTO is a genomeTO
$return_1 is a genomeTO
$analysis is a reference to a list where each element is a prophage_feature
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	contigs has a value which is a reference to a list where each element is a contig
	features has a value which is a reference to a list where each element is a feature
genome_id is a string
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
contig_id is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	annotations has a value which is a reference to a list where each element is an annotation
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 3 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
prophage_feature is a reference to a list containing 15 items:
	0: a feature_id
	1: a contig_id
	2: (start) an int
	3: (stop) an int
	4: (position) an int
	5: (rank) a float
	6: (my_status) a float
	7: (pp) a float
	8: (final_status) an int
	9: (start_of_attL) an int
	10: (end_of_attL) an int
	11: (start_of_attR) an int
	12: (end_of_attR) an int
	13: (sequence_of_attL) a string
	14: (sequence_of_attR) a string


=end text



=item Description

Find prophages in the given genome.

The underlying tool uses the following files from a SEED directory:
  contigs
  Features/peg/tbl
  assigned_functions
  Feature/rna/tbl

=back

=cut

sub find_prophages
{
    my $self = shift;
    my($training_set_id, $genomeTO) = @_;

    my @_bad_arguments;
    (!ref($training_set_id)) or push(@_bad_arguments, "Invalid type for argument \"training_set_id\" (value was \"$training_set_id\")");
    (ref($genomeTO) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"genomeTO\" (value was \"$genomeTO\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to find_prophages:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'find_prophages');
    }

    my $ctx = $Bio::KBase::Phispy::Service::CallContext;
    my($return_1, $analysis);
    #BEGIN find_prophages


    # Construct a SEED-style genome directory with the files required to run
	
    my $tmp = File::Temp->newdir(undef, CLEANUP => 0);
    open(C, ">", "$tmp/contigs") or die "Cannot create $tmp/contigs: $!";
    for my $contig (@{$genomeTO->{contigs}})
    {
	print C ">$contig->{id}\n";
	print C "$contig->{dna}\n";
    }
    close(C);
    open(F, ">", "$tmp/assigned_functions") or die "Cannot create $tmp/assigned_functions: $!";
    mkdir("$tmp/Features");
    mkdir("$tmp/Features/peg");
    mkdir("$tmp/Features/rna");
    open(PT, ">", "$tmp/Features/peg/tbl") or die "Cannot write $tmp/Features/peg/tbl: $!";
    open(RT, ">", "$tmp/Features/rna/tbl") or die "Cannot write $tmp/Features/rna/tbl: $!";
    #     "location" : [
    #        [
    #           "kb|g.140.c.0",
    #           "631472",
    #           "+",
    #           3216
    #        ]
    #     ],

    for my $feature (@{$genomeTO->{features}})
    {
	print F "$feature->{id}\t$feature->{function}\n";
	my $loc = $feature->{location};

	#
	# Fix this - we may have multipart locations.
	#
	my($ctg, $start, $strand, $len) = @{$loc->[0]};
	my $stop;
	if ($strand eq '+')
	{
	    $stop = $start + $len - 1;
	}
	else
	{
	    $stop = $start - $len + 1;
	}
	my $sloc = join("_", $ctg, $start, $stop);
	if ($feature->{type} eq 'CDS' || $feature->{type} eq 'peg')
	{
	    print PT join("\t", $feature->{id}, $sloc), "\n";
	}
	else
	{
	    print RT join("\t", $feature->{id}, $sloc), "\n";
	}
    }
    close(F);
    close(RT);
    close(PT);

    #
    # Invoke the tool, with output to a temp directory.
    #
    my $out = File::Temp->newdir(undef, CLEANUP => 0);

    my @cmd = ("python", "$ENV{KB_RUNTIME}/phispy/phiSpy.py", 
    	       "-i", $tmp, "-o", $out, "-t", $training_set_id);
    print STDERR "Running: @cmd\n";
    my $rc = system(@cmd);
    if ($rc != 0)
    {
	die "Failure rc=$rc running @cmd\n";
    }


    # 
    # Create prophage features.
    #
    if (open(F, "<", "$out/prophage.tbl"))
    {
	while (<F>)
	{
	    chomp;
	    my($fid, $loc) = split(/\t/);
	    my($ctg, $start, $stop) = split(/_/, $loc);
	    my($strand, $len);
	    if ($start < $stop)
	    {
		$strand = '+';
		$len = $stop - $start + 1;
	    }
	    else
	    {
		$strand = '-';
		$len = $start - $stop + 1;
	    }
	    my $nloc = [[$ctg, $start, $strand, $len]];

	    # Create the feature; remember they look like this:
	    #    typedef structure {
	    #        feature_id id;
	    #        location location;
	    #        feature_type type;
	    #        string function;
	    #        string protein_translation;
	    #        list<string> aliases;
	    #        list<annotation> annotations;
	    #    } feature;

	    my $feature = { feature_id => $fid, 
		location => $nloc,
		feature_type => 'pp',
		aliases => [],
		annotations => [],
		};
	    push(@{$genomeTO->{features}}, $feature);
	}
	close(F);
    }
    $return_1 = $genomeTO;
    # 
    # Parse analysis and create return.
    #
    $analysis = [];
    if (open(F, "<", "$out/prophage_tbl.txt"))
    {
	$_ = <F>;
	while (<F>)
	{
	    chomp;
	    my($fig_no, $function, $contig, $start, $stop, $position, $rank, $my_status, $pp, 
		$final_status, $start_of_attL, $end_of_attL, $start_of_attR, $end_of_attR, 
		$sequence_of_attL, $sequence_of_attR) = split(/\t/);

	    push(@$analysis, [$fig_no, $contig, $start, $stop, $position, $rank, $my_status, $pp, 
		$final_status, $start_of_attL, $end_of_attL, $start_of_attR, $end_of_attR, 
		$sequence_of_attL, $sequence_of_attR]);
	}
	close(F);
    }

    
    #END find_prophages
    my @_bad_returns;
    (ref($return_1) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"return_1\" (value was \"$return_1\")");
    (ref($analysis) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"analysis\" (value was \"$analysis\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to find_prophages:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'find_prophages');
    }
    return($return_1, $analysis);
}




=head2 version 

  $return = $obj->version()

=over 4

=item Parameter and return types

=begin html

<pre>
$return is a string
</pre>

=end html

=begin text

$return is a string

=end text

=item Description

Return the module version. This is a Semantic Versioning number.

=back

=cut

sub version {
    return $VERSION;
}

=head1 TYPES



=head2 genome_id

=over 4



=item Description

* Following are the standard genome typed object defintions as copied from
* the genome_annotation service specification.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 feature_id

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 contig_id

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 feature_type

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 region_of_dna

=over 4



=item Description

A region of DNA is maintained as a tuple of four components:

                the contig
                the beginning position (from 1)
                the strand
                the length

           We often speak of "a region".  By "location", we mean a sequence
           of regions from the same genome (perhaps from distinct contigs).


=item Definition

=begin html

<pre>
a reference to a list containing 4 items:
0: a contig_id
1: (begin) an int
2: (strand) a string
3: (length) an int

</pre>

=end html

=begin text

a reference to a list containing 4 items:
0: a contig_id
1: (begin) an int
2: (strand) a string
3: (length) an int


=end text

=back



=head2 location

=over 4



=item Description

a "location" refers to a sequence of regions


=item Definition

=begin html

<pre>
a reference to a list where each element is a region_of_dna
</pre>

=end html

=begin text

a reference to a list where each element is a region_of_dna

=end text

=back



=head2 annotation

=over 4



=item Definition

=begin html

<pre>
a reference to a list containing 3 items:
0: (comment) a string
1: (annotator) a string
2: (annotation_time) an int

</pre>

=end html

=begin text

a reference to a list containing 3 items:
0: (comment) a string
1: (annotator) a string
2: (annotation_time) an int


=end text

=back



=head2 feature

=over 4



=item Description

represents a feature on the genome
location on the contig with a type,
and if a protein has translation,
any aliases associated
current history of annoation in style of SEED


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a feature_id
location has a value which is a location
type has a value which is a feature_type
function has a value which is a string
protein_translation has a value which is a string
aliases has a value which is a reference to a list where each element is a string
annotations has a value which is a reference to a list where each element is an annotation

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a feature_id
location has a value which is a location
type has a value which is a feature_type
function has a value which is a string
protein_translation has a value which is a string
aliases has a value which is a reference to a list where each element is a string
annotations has a value which is a reference to a list where each element is an annotation


=end text

=back



=head2 contig

=over 4



=item Description

Data for DNA contig


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a contig_id
dna has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a contig_id
dna has a value which is a string


=end text

=back



=head2 genomeTO

=over 4



=item Description

All of the information about particular genome


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a genome_id
scientific_name has a value which is a string
domain has a value which is a string
genetic_code has a value which is an int
source has a value which is a string
source_id has a value which is a string
contigs has a value which is a reference to a list where each element is a contig
features has a value which is a reference to a list where each element is a feature

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a genome_id
scientific_name has a value which is a string
domain has a value which is a string
genetic_code has a value which is an int
source has a value which is a string
source_id has a value which is a string
contigs has a value which is a reference to a list where each element is a contig
features has a value which is a reference to a list where each element is a feature


=end text

=back



=head2 TrainingSet

=over 4



=item Description

* We define a type that represents the available phispy training sets.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
training_set_id has a value which is an int
genome_name has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
training_set_id has a value which is an int
genome_name has a value which is a string


=end text

=back



=head2 prophage_feature

=over 4



=item Description

* Analysis results from the prophage finder.


=item Definition

=begin html

<pre>
a reference to a list containing 15 items:
0: a feature_id
1: a contig_id
2: (start) an int
3: (stop) an int
4: (position) an int
5: (rank) a float
6: (my_status) a float
7: (pp) a float
8: (final_status) an int
9: (start_of_attL) an int
10: (end_of_attL) an int
11: (start_of_attR) an int
12: (end_of_attR) an int
13: (sequence_of_attL) a string
14: (sequence_of_attR) a string

</pre>

=end html

=begin text

a reference to a list containing 15 items:
0: a feature_id
1: a contig_id
2: (start) an int
3: (stop) an int
4: (position) an int
5: (rank) a float
6: (my_status) a float
7: (pp) a float
8: (final_status) an int
9: (start_of_attL) an int
10: (end_of_attL) an int
11: (start_of_attR) an int
12: (end_of_attR) an int
13: (sequence_of_attL) a string
14: (sequence_of_attR) a string


=end text

=back



=cut

1;
