package Bio::KBase::PlantExpressionService::Client;

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

Bio::KBase::PlantExpressionService::Client

=head1 DESCRIPTION


Plant Expression Service APIs 

 This module provides services for plant expression data in support of the coexpression
 network and ontology driven data needs of the plant sciences community. This version of
 the modules supports retrieval of the following information:
 1. Retrieval of GEO sample ID list for given EO (environmental ontology) and/or PO (plant ontology -plant tissues/organs of interest).
 2. Retrieval of the expression values for given GEO sample ID list.  
 3. For given expression values tables, it computes co-expression clusters or network (CLI only).

It will serve queries for tissue and condition specific gene expression co-expression network for biologically interesting genes/samples. Users can search differentially expressed genes in different tissues or in numerous experimental conditions or treatments (e.g various biotic or abiotic stresses). Currently the metadata annotation is provided for a subset of gene expression experiments from the NCBI GEO microarray experiments for Arabidopsis and Poplar. The samples of these experiments are manually annotated using plant ontology (PO) [http://www.plantontology.org/] and environment ontology (EO) [http://obo.cvs.sourceforge.net/viewvc/obo/obo/ontology/phenotype/environment/environment_ontology.obo]


=cut

sub new
{
    my($class, $url, @args) = @_;
    

    my $self = {
	client => Bio::KBase::PlantExpressionService::Client::RpcClient->new,
	url => $url,
    };


    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);
    bless $self, $class;
    #    $self->_validate_version();
    return $self;
}




=head2 get_repid_by_sampleid

  $results = $obj->get_repid_by_sampleid($ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$ids is a SampleIDList
$results is a Sample
SampleIDList is a reference to a list where each element is a SampleID
SampleID is a string
Sample is a reference to a hash where the key is a SampleID and the value is a ValueList
ValueList is a reference to a list where each element is a float

</pre>

=end html

=begin text

$ids is a SampleIDList
$results is a Sample
SampleIDList is a reference to a list where each element is a SampleID
SampleID is a string
Sample is a reference to a hash where the key is a SampleID and the value is a ValueList
ValueList is a reference to a list where each element is a float


=end text

=item Description

This function takes a list a GSM id. The GSM id can be stored as a csv file, containing one line. The output is the corresponding replicate id

=back

=cut

sub get_repid_by_sampleid
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_repid_by_sampleid (received $n, expecting 1)");
    }
    {
	my($ids) = @args;

	my @_bad_arguments;
        (ref($ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"ids\" (value was \"$ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_repid_by_sampleid:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_repid_by_sampleid');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "PlantExpression.get_repid_by_sampleid",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_repid_by_sampleid',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_repid_by_sampleid",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_repid_by_sampleid',
				       );
    }
}



=head2 get_experiments_by_seriesid

  $results = $obj->get_experiments_by_seriesid($ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$ids is a SeriesIDList
$results is an Experiments
SeriesIDList is a reference to a list where each element is a SeriesID
SeriesID is a string
Experiments is a reference to a hash where the key is a SeriesID and the value is an Experiment
Experiment is a reference to a hash where the following keys are defined:
	series has a value which is a Sample
	genes has a value which is a GeneIDList
Sample is a reference to a hash where the key is a SampleID and the value is a ValueList
SampleID is a string
ValueList is a reference to a list where each element is a float
GeneIDList is a reference to a list where each element is a GeneID
GeneID is a string

</pre>

=end html

=begin text

$ids is a SeriesIDList
$results is an Experiments
SeriesIDList is a reference to a list where each element is a SeriesID
SeriesID is a string
Experiments is a reference to a hash where the key is a SeriesID and the value is an Experiment
Experiment is a reference to a hash where the following keys are defined:
	series has a value which is a Sample
	genes has a value which is a GeneIDList
Sample is a reference to a hash where the key is a SampleID and the value is a ValueList
SampleID is a string
ValueList is a reference to a list where each element is a float
GeneIDList is a reference to a list where each element is a GeneID
GeneID is a string


=end text

=item Description

This function provides the expression data for each experiment corresponding to the given list of series (GSE#s). It first retrieves the experiments sample ids (GSM#s) for each series and subsequently, it extracts the expressed genes and their corresponding expression values for each experiment. It then returns a table of data containing GSE#, GSM#, Expressed Gene ID, and Expression Value.

=back

=cut

sub get_experiments_by_seriesid
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_experiments_by_seriesid (received $n, expecting 1)");
    }
    {
	my($ids) = @args;

	my @_bad_arguments;
        (ref($ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"ids\" (value was \"$ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_experiments_by_seriesid:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_experiments_by_seriesid');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "PlantExpression.get_experiments_by_seriesid",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_experiments_by_seriesid',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_experiments_by_seriesid",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_experiments_by_seriesid',
				       );
    }
}



=head2 get_experiments_by_sampleid

  $results = $obj->get_experiments_by_sampleid($ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$ids is a SampleIDList
$results is an Experiment
SampleIDList is a reference to a list where each element is a SampleID
SampleID is a string
Experiment is a reference to a hash where the following keys are defined:
	series has a value which is a Sample
	genes has a value which is a GeneIDList
Sample is a reference to a hash where the key is a SampleID and the value is a ValueList
ValueList is a reference to a list where each element is a float
GeneIDList is a reference to a list where each element is a GeneID
GeneID is a string

</pre>

=end html

=begin text

$ids is a SampleIDList
$results is an Experiment
SampleIDList is a reference to a list where each element is a SampleID
SampleID is a string
Experiment is a reference to a hash where the following keys are defined:
	series has a value which is a Sample
	genes has a value which is a GeneIDList
Sample is a reference to a hash where the key is a SampleID and the value is a ValueList
ValueList is a reference to a list where each element is a float
GeneIDList is a reference to a list where each element is a GeneID
GeneID is a string


=end text

=item Description

This function provides the expression values  corresponding to each given experiment sample in the input list of sample ids (GSM#s).For each sample in the input list of samples, it extracts the expressed genes (kbase gene identifier) and their corresponding expression values.

=back

=cut

sub get_experiments_by_sampleid
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_experiments_by_sampleid (received $n, expecting 1)");
    }
    {
	my($ids) = @args;

	my @_bad_arguments;
        (ref($ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"ids\" (value was \"$ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_experiments_by_sampleid:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_experiments_by_sampleid');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "PlantExpression.get_experiments_by_sampleid",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_experiments_by_sampleid',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_experiments_by_sampleid",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_experiments_by_sampleid',
				       );
    }
}



=head2 get_experiments_by_sampleid_geneid

  $results = $obj->get_experiments_by_sampleid_geneid($ids, $gl)

=over 4

=item Parameter and return types

=begin html

<pre>
$ids is a SampleIDList
$gl is a GeneIDList
$results is an Experiment
SampleIDList is a reference to a list where each element is a SampleID
SampleID is a string
GeneIDList is a reference to a list where each element is a GeneID
GeneID is a string
Experiment is a reference to a hash where the following keys are defined:
	series has a value which is a Sample
	genes has a value which is a GeneIDList
Sample is a reference to a hash where the key is a SampleID and the value is a ValueList
ValueList is a reference to a list where each element is a float

</pre>

=end html

=begin text

$ids is a SampleIDList
$gl is a GeneIDList
$results is an Experiment
SampleIDList is a reference to a list where each element is a SampleID
SampleID is a string
GeneIDList is a reference to a list where each element is a GeneID
GeneID is a string
Experiment is a reference to a hash where the following keys are defined:
	series has a value which is a Sample
	genes has a value which is a GeneIDList
Sample is a reference to a hash where the key is a SampleID and the value is a ValueList
ValueList is a reference to a list where each element is a float


=end text

=item Description

This function provides the expression values corresponding to the given sample and for given list of kbase gene identifiers.
Retrieve the expression values corresponding to each given sample in the input list of samples ((typically NCBI GEO series sample ids: GSM#s) for given list of genes (kbase identifier).

=back

=cut

sub get_experiments_by_sampleid_geneid
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_experiments_by_sampleid_geneid (received $n, expecting 2)");
    }
    {
	my($ids, $gl) = @args;

	my @_bad_arguments;
        (ref($ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"ids\" (value was \"$ids\")");
        (ref($gl) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 2 \"gl\" (value was \"$gl\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_experiments_by_sampleid_geneid:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_experiments_by_sampleid_geneid');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "PlantExpression.get_experiments_by_sampleid_geneid",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_experiments_by_sampleid_geneid',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_experiments_by_sampleid_geneid",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_experiments_by_sampleid_geneid',
				       );
    }
}



=head2 get_eo_sampleidlist

  $results = $obj->get_eo_sampleidlist($lst)

=over 4

=item Parameter and return types

=begin html

<pre>
$lst is an EOIDList
$results is an EOID2Sample
EOIDList is a reference to a list where each element is an EOID
EOID is a string
EOID2Sample is a reference to a hash where the key is an EOID and the value is a SampleIDList
SampleIDList is a reference to a list where each element is a SampleID
SampleID is a string

</pre>

=end html

=begin text

$lst is an EOIDList
$results is an EOID2Sample
EOIDList is a reference to a list where each element is an EOID
EOID is a string
EOID2Sample is a reference to a hash where the key is an EOID and the value is a SampleIDList
SampleIDList is a reference to a list where each element is a SampleID
SampleID is a string


=end text

=item Description

Retrieve the list of expression samples (GSM#s) that correspond to one or more of the environmental conditions (EO) of interest.

=back

=cut

sub get_eo_sampleidlist
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_eo_sampleidlist (received $n, expecting 1)");
    }
    {
	my($lst) = @args;

	my @_bad_arguments;
        (ref($lst) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"lst\" (value was \"$lst\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_eo_sampleidlist:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_eo_sampleidlist');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "PlantExpression.get_eo_sampleidlist",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_eo_sampleidlist',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_eo_sampleidlist",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_eo_sampleidlist',
				       );
    }
}



=head2 get_po_sampleidlist

  $results = $obj->get_po_sampleidlist($lst)

=over 4

=item Parameter and return types

=begin html

<pre>
$lst is a POIDList
$results is a POID2Sample
POIDList is a reference to a list where each element is a POID
POID is a string
POID2Sample is a reference to a hash where the key is a POID and the value is a SampleIDList
SampleIDList is a reference to a list where each element is a SampleID
SampleID is a string

</pre>

=end html

=begin text

$lst is a POIDList
$results is a POID2Sample
POIDList is a reference to a list where each element is a POID
POID is a string
POID2Sample is a reference to a hash where the key is a POID and the value is a SampleIDList
SampleIDList is a reference to a list where each element is a SampleID
SampleID is a string


=end text

=item Description

Retrieve the list of expression samples (GSM#s) that corresponds to one or more of the plant tissue/organ (PO) type of interest.

=back

=cut

sub get_po_sampleidlist
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_po_sampleidlist (received $n, expecting 1)");
    }
    {
	my($lst) = @args;

	my @_bad_arguments;
        (ref($lst) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"lst\" (value was \"$lst\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_po_sampleidlist:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_po_sampleidlist');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "PlantExpression.get_po_sampleidlist",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_po_sampleidlist',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_po_sampleidlist",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_po_sampleidlist',
				       );
    }
}



=head2 get_all_po

  $results = $obj->get_all_po()

=over 4

=item Parameter and return types

=begin html

<pre>
$results is a POID2Description
POID2Description is a reference to a hash where the key is a POID and the value is a string
POID is a string

</pre>

=end html

=begin text

$results is a POID2Description
POID2Description is a reference to a hash where the key is a POID and the value is a string
POID is a string


=end text

=item Description

=head2 getAllPO

 Retrieve the list of all plant ontology IDs (POIDs) currently available in the database.

=back

=cut

sub get_all_po
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 0)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_all_po (received $n, expecting 0)");
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "PlantExpression.get_all_po",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_all_po',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_all_po",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_all_po',
				       );
    }
}



=head2 get_all_eo

  $results = $obj->get_all_eo()

=over 4

=item Parameter and return types

=begin html

<pre>
$results is an EOID2Description
EOID2Description is a reference to a hash where the key is an EOID and the value is a string
EOID is a string

</pre>

=end html

=begin text

$results is an EOID2Description
EOID2Description is a reference to a hash where the key is an EOID and the value is a string
EOID is a string


=end text

=item Description

Retrieve the list of all plant environment ontology IDs (EOIDs) currently available in the database.

=back

=cut

sub get_all_eo
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 0)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_all_eo (received $n, expecting 0)");
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "PlantExpression.get_all_eo",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_all_eo',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_all_eo",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_all_eo',
				       );
    }
}



=head2 get_po_descriptions

  $results = $obj->get_po_descriptions($ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$ids is a POIDList
$results is a POID2Description
POIDList is a reference to a list where each element is a POID
POID is a string
POID2Description is a reference to a hash where the key is a POID and the value is a string

</pre>

=end html

=begin text

$ids is a POIDList
$results is a POID2Description
POIDList is a reference to a list where each element is a POID
POID is a string
POID2Description is a reference to a hash where the key is a POID and the value is a string


=end text

=item Description

Retrieve the list of selected plant ontology IDs (POIDs) description corresponding to an input
list of POIDs.

=back

=cut

sub get_po_descriptions
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_po_descriptions (received $n, expecting 1)");
    }
    {
	my($ids) = @args;

	my @_bad_arguments;
        (ref($ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"ids\" (value was \"$ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_po_descriptions:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_po_descriptions');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "PlantExpression.get_po_descriptions",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_po_descriptions',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_po_descriptions",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_po_descriptions',
				       );
    }
}



=head2 get_eo_descriptions

  $results = $obj->get_eo_descriptions($ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$ids is an EOIDList
$results is an EOID2Description
EOIDList is a reference to a list where each element is an EOID
EOID is a string
EOID2Description is a reference to a hash where the key is an EOID and the value is a string

</pre>

=end html

=begin text

$ids is an EOIDList
$results is an EOID2Description
EOIDList is a reference to a list where each element is an EOID
EOID is a string
EOID2Description is a reference to a hash where the key is an EOID and the value is a string


=end text

=item Description

Retrieve the list of selected plant environment ontology IDs (EOIDs) description corresponding to an input list of EOIDs.

=back

=cut

sub get_eo_descriptions
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_eo_descriptions (received $n, expecting 1)");
    }
    {
	my($ids) = @args;

	my @_bad_arguments;
        (ref($ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"ids\" (value was \"$ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_eo_descriptions:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_eo_descriptions');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "PlantExpression.get_eo_descriptions",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_eo_descriptions',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_eo_descriptions",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_eo_descriptions',
				       );
    }
}



sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, {
        method => "PlantExpression.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'get_eo_descriptions',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method get_eo_descriptions",
            status_line => $self->{client}->status_line,
            method_name => 'get_eo_descriptions',
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
        warn "New client version available for Bio::KBase::PlantExpressionService::Client\n";
    }
    if ($sMajor == 0) {
        warn "Bio::KBase::PlantExpressionService::Client version is $svr_version. API subject to change.\n";
    }
}

=head1 TYPES



=head2 EOID

=over 4



=item Description

external environment ontology id 

     The supported EO ids are :
       EO:0007001        UV-B light regimen
       EO:0007002        UV-A light regimen
       EO:0007041        antibiotic regimen
       EO:0007049        soil environment
       EO:0007066        cytokinin regimen
       EO:0007067        hydroponic plant culture media
       EO:0007071        suspension cell culture media
       EO:0007075        high light intensity regimen
       EO:0007079        sulfate fertilizer regimen
       EO:0007105        abscisic acid regimen
       EO:0007106        Stramenopiles
       EO:0007107        Ascomycota
       EO:0007108        Proteobacteria
       EO:0007116        Hemiptera
       EO:0007128        intermittent light regimen
       EO:0007144        Pseudomonas spp.
       EO:0007149        chemical mutagen
       EO:0007158        sandy soil
       EO:0007162        continuous light regimen
       EO:0007173        warm/hot temperature regimen
       EO:0007174        cold temperature regimen
       EO:0007175        temperature environment
       EO:0007183        herbicide regimen
       EO:0007185        salt regimen
       EO:0007193        day light intensity
       EO:0007199        long day length regimen
       EO:0007200        short day length regimen
       EO:0007203        far red light regimen
       EO:0007207        red light regimen
       EO:0007218        blue light regimen
       EO:0007221        visible light regimen
       EO:0007233        Fungi
       EO:0007265        liquid growth media
       EO:0007266        tissue culture growth media
       EO:0007270        continuous dark (no light) regimen
       EO:0007271        low light intensity regimen
       EO:0007303        carbon nutrient regimen
       EO:0007373        mechanical damage
       EO:0007404        drought environment
       EO:0007409        brassinosteroid


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



=head2 POID

=over 4



=item Description

external plant ontology id 

     The supported PO ids are :
       PO:0000003        whole plant
       PO:0000005        cultured cell
       PO:0000006        cultured protoplast
       PO:0009005        root
       PO:0009006        shoot
       PO:0009025        leaf
       PO:0009046        flower
       PO:0009049        Inflorescence
       PO:0009001        fruit
       PO:0009010        seed


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



=head2 GeneID

=over 4



=item Description

external gene id


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



=head2 SampleID

=over 4



=item Description

expression sample id from GEO (GSM#)


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



=head2 SeriesID

=over 4



=item Description

Series id from GEO (GSE#)


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



=head2 GeneIDList

=over 4



=item Description

list of external gene ids from species of interest


=item Definition

=begin html

<pre>
a reference to a list where each element is a GeneID
</pre>

=end html

=begin text

a reference to a list where each element is a GeneID

=end text

=back



=head2 SampleIDList

=over 4



=item Description

list of Sample ids


=item Definition

=begin html

<pre>
a reference to a list where each element is a SampleID
</pre>

=end html

=begin text

a reference to a list where each element is a SampleID

=end text

=back



=head2 EOIDList

=over 4



=item Description

list of environment ontologies


=item Definition

=begin html

<pre>
a reference to a list where each element is an EOID
</pre>

=end html

=begin text

a reference to a list where each element is an EOID

=end text

=back



=head2 POIDList

=over 4



=item Description

list of plant ontologies


=item Definition

=begin html

<pre>
a reference to a list where each element is a POID
</pre>

=end html

=begin text

a reference to a list where each element is a POID

=end text

=back



=head2 SeriesIDList

=over 4



=item Definition

=begin html

<pre>
a reference to a list where each element is a SeriesID
</pre>

=end html

=begin text

a reference to a list where each element is a SeriesID

=end text

=back



=head2 ValueList

=over 4



=item Definition

=begin html

<pre>
a reference to a list where each element is a float
</pre>

=end html

=begin text

a reference to a list where each element is a float

=end text

=back



=head2 Sample

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the key is a SampleID and the value is a ValueList
</pre>

=end html

=begin text

a reference to a hash where the key is a SampleID and the value is a ValueList

=end text

=back



=head2 SampleList

=over 4



=item Definition

=begin html

<pre>
a reference to a list where each element is a Sample
</pre>

=end html

=begin text

a reference to a list where each element is a Sample

=end text

=back



=head2 Experiment

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
series has a value which is a Sample
genes has a value which is a GeneIDList

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
series has a value which is a Sample
genes has a value which is a GeneIDList


=end text

=back



=head2 Experiments

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the key is a SeriesID and the value is an Experiment
</pre>

=end html

=begin text

a reference to a hash where the key is a SeriesID and the value is an Experiment

=end text

=back



=head2 EOID2Sample

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the key is an EOID and the value is a SampleIDList
</pre>

=end html

=begin text

a reference to a hash where the key is an EOID and the value is a SampleIDList

=end text

=back



=head2 POID2Sample

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the key is a POID and the value is a SampleIDList
</pre>

=end html

=begin text

a reference to a hash where the key is a POID and the value is a SampleIDList

=end text

=back



=head2 POID2Description

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the key is a POID and the value is a string
</pre>

=end html

=begin text

a reference to a hash where the key is a POID and the value is a string

=end text

=back



=head2 EOID2Description

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the key is an EOID and the value is a string
</pre>

=end html

=begin text

a reference to a hash where the key is an EOID and the value is a string

=end text

=back



=cut

package Bio::KBase::PlantExpressionService::Client::RpcClient;
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
        # $obj->{id} = $self->id if (defined $self->id);
	# Assign a random number to the id if one hasn't been set
	$obj->{id} = (defined $self->id) ? $self->id : substr(rand(),2);
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
