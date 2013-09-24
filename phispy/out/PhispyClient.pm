package PhispyClient;

use JSON::RPC::Client;
use strict;
use Data::Dumper;
use URI;
use Bio::KBase::Exceptions;

# Client version should match Impl version
# This is a Semantic Version number,
# http://semver.org
our $VERSION = "0.1.0";

=head1 NAME

PhispyClient

=head1 DESCRIPTION


This service wraps the PhiSpy service as defined at
http://sourceforge.net/projects/phispy.


=cut

sub new
{
    my($class, $url, @args) = @_;

    my $self = {
	client => PhispyClient::RpcClient->new,
	url => $url,
    };


    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);
    bless $self, $class;
    #    $self->_validate_version();
    return $self;
}




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
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 0)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_all_training_sets (received $n, expecting 0)");
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Phispy.get_all_training_sets",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_all_training_sets',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_all_training_sets",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_all_training_sets',
				       );
    }
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
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function find_prophages (received $n, expecting 2)");
    }
    {
	my($training_set_id, $genomeTO) = @args;

	my @_bad_arguments;
        (!ref($training_set_id)) or push(@_bad_arguments, "Invalid type for argument 1 \"training_set_id\" (value was \"$training_set_id\")");
        (ref($genomeTO) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 2 \"genomeTO\" (value was \"$genomeTO\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to find_prophages:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'find_prophages');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Phispy.find_prophages",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'find_prophages',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method find_prophages",
					    status_line => $self->{client}->status_line,
					    method_name => 'find_prophages',
				       );
    }
}



sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, {
        method => "Phispy.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'find_prophages',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method find_prophages",
            status_line => $self->{client}->status_line,
            method_name => 'find_prophages',
        );
    }
}

sub _validate_version {
    my ($self) = @_;
    my $svr_version = $self->version();
    my $client_version = $VERSION;
    my ($cMajor, $cMinor) = split(/\./, $client_version);
    my ($sMajor, $sMinor) = split(/\./, $svr_version);
    if ($sMajor != $cMajor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Major version numbers differ.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor < $cMinor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Client minor version greater than Server minor version.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor > $cMinor) {
        warn "New client version available for PhispyClient\n";
    }
    if ($sMajor == 0) {
        warn "PhispyClient version is $svr_version. API subject to change.\n";
    }
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

package PhispyClient::RpcClient;
use base 'JSON::RPC::Client';

#
# Override JSON::RPC::Client::call because it doesn't handle error returns properly.
#

sub call {
    my ($self, $uri, $obj) = @_;
    my $result;

    if ($uri =~ /\?/) {
       $result = $self->_get($uri);
    }
    else {
        Carp::croak "not hashref." unless (ref $obj eq 'HASH');
        $result = $self->_post($uri, $obj);
    }

    my $service = $obj->{method} =~ /^system\./ if ( $obj );

    $self->status_line($result->status_line);

    if ($result->is_success) {

        return unless($result->content); # notification?

        if ($service) {
            return JSON::RPC::ServiceObject->new($result, $self->json);
        }

        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    elsif ($result->content_type eq 'application/json')
    {
        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    else {
        return;
    }
}


sub _post {
    my ($self, $uri, $obj) = @_;
    my $json = $self->json;

    $obj->{version} ||= $self->{version} || '1.1';

    if ($obj->{version} eq '1.0') {
        delete $obj->{version};
        if (exists $obj->{id}) {
            $self->id($obj->{id}) if ($obj->{id}); # if undef, it is notification.
        }
        else {
            $obj->{id} = $self->id || ($self->id('JSON::RPC::Client'));
        }
    }
    else {
        $obj->{id} = $self->id if (defined $self->id);
    }

    my $content = $json->encode($obj);

    $self->ua->post(
        $uri,
        Content_Type   => $self->{content_type},
        Content        => $content,
        Accept         => 'application/json',
	($self->{token} ? (Authorization => $self->{token}) : ()),
    );
}



1;
