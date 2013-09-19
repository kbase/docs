package Bio::KBase::PlantExpressionService::PlantExpressionServiceImpl;
use strict;
use Bio::KBase::Exceptions;
# Use Semantic Versioning (2.0.0-rc.1)
# http://semver.org 
our $VERSION = "0.1.0";

=head1 NAME

PlantExpression

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

#BEGIN_HEADER
use DBI;
use Config::Simple;
#END_HEADER

sub new
{
    my($class, @args) = @_;
    my $self = {
    };
    bless $self, $class;
    #BEGIN_CONSTRUCTOR
  my %params;
  my @list = qw(mysqldb-host dbname dbuser dbpass dbport);
  if ((my $e = $ENV{KB_DEPLOYMENT_CONFIG}) && -e $ENV{KB_DEPLOYMENT_CONFIG}) {  
    my $service = $ENV{KB_SERVICE_NAME};
    if (defined($service)) {
      my $c = Config::Simple->new();
      $c->read($e);
      for my $p (@list) {
        my $v = $c->param("$service.$p");
        if ($v) {
          $params{$p} = $v;
        }
      }
    }
  }

  # set default values for testing
  $params{'mysqldb-host'} = 'devdb1.newyork.kbase.us' if! defined $params{'mysqldb-host'};
  $params{dbname} = 'kbase_plant' if! defined $params{dbname};
  $params{dbuser} = 'networks_pdev' if! defined $params{dbuser};
  $params{dbpass} = '' if! defined $params{dbpass};
  $params{dbport} = '3306' if! defined $params{dbport};

  my $dbh = DBI->connect("DBI:mysql:$params{dbname};host=$params{'mysqldb-host'};port=$params{dbport}","$params{dbuser}", "$params{dbpass}",  { RaiseError => 1, mysql_auto_reconnect => 1 } );
  #$dbh->{mysql_auto_reconnect} = 1;
  $self->{_dbh} = $dbh;
    #END_CONSTRUCTOR

    if ($self->can('_init_instance'))
    {
	$self->_init_instance();
    }
    return $self;
}

=head1 METHODS



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
    my $self = shift;
    my($ids) = @_;

    my @_bad_arguments;
    (ref($ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"ids\" (value was \"$ids\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_repid_by_sampleid:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_repid_by_sampleid');
    }

    my $ctx = $Bio::KBase::PlantExpressionService::Service::CallContext;
    my($results);
    #BEGIN get_repid_by_sampleid
  my %rep = (); # 
    $results = \%rep;

  my $pstmt;
  my $dbh = $self->{_dbh};
  $pstmt = $dbh->prepare("select replicate_id from sample where  sid_extern = ?");  
  foreach my $in (@{$ids}){
    $pstmt -> bind_param(1,$in);
    $pstmt -> execute();
    my @data=$pstmt->fetchrow_array();
    $rep{$in}=$data[0];
  }




    #END get_repid_by_sampleid
    my @_bad_returns;
    (ref($results) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"results\" (value was \"$results\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_repid_by_sampleid:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_repid_by_sampleid');
    }
    return($results);
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
    my $self = shift;
    my($ids) = @_;

    my @_bad_arguments;
    (ref($ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"ids\" (value was \"$ids\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_experiments_by_seriesid:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_experiments_by_seriesid');
    }

    my $ctx = $Bio::KBase::PlantExpressionService::Service::CallContext;
    my($results);
    #BEGIN get_experiments_by_seriesid

  my $dbh = $self->{_dbh};



  my %experiments = (); # sample id to value list
    $results = \%experiments;
  my $pstmt = $dbh->prepare("select cid from eid2cid where  eid = ?");
  foreach my $experimentID (@{$ids}) {

    $pstmt->bind_param(1, $experimentID);
    $pstmt->execute();
    my @sids = ();
    while( my @data = $pstmt->fetchrow_array()) {
      push @sids, $data[0];
    } 
    $experiments{$experimentID} = get_experiments_by_seriesid($self, \@sids);
  } 

    #END get_experiments_by_seriesid
    my @_bad_returns;
    (ref($results) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"results\" (value was \"$results\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_experiments_by_seriesid:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_experiments_by_seriesid');
    }
    return($results);
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
    my $self = shift;
    my($ids) = @_;

    my @_bad_arguments;
    (ref($ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"ids\" (value was \"$ids\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_experiments_by_sampleid:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_experiments_by_sampleid');
    }

    my $ctx = $Bio::KBase::PlantExpressionService::Service::CallContext;
    my($results);
    #BEGIN get_experiments_by_sampleid
  my $dbh = $self->{_dbh};

  my %sid2values = (); # sample id to value list
    my @gids = ();
  my @genes = ();
  my %gid2gname = ();

  my $gid_rs = $dbh->prepare("select id, fid from at2id_int order by id");
  $gid_rs->execute();
  while( my @data = $gid_rs->fetchrow_array()) {
    $gid2gname{$data[0]} = $data[1];
  }

  my %gsm2cid = ();
  my $gsms = "'".join("','", @{$ids})."'";
  my $cid_rs = $dbh->prepare("select id, ci from ci2id where ci in ($gsms) order by id");
  $cid_rs->execute;
  while( my @data = $cid_rs->fetchrow_array()) {
    $gsm2cid{$data[1]} = $data[0];
  }

  my $pstmt = $dbh->prepare("select geneID, `signal` from expression where sampleID = ? order by geneID");
  my $gotGeneList = 0;
  my %experiment = ();
  $results = \%experiment;
  $experiment{"genes"} = \@genes;
  $experiment{"series"} = \%sid2values;
  foreach my $sampleID (@{$ids}) {
    $pstmt->bind_param(1, $gsm2cid{$sampleID});
    $pstmt->execute();
    my @values = ();
    while( my @data = $pstmt->fetchrow_array()) {
      push @genes, $gid2gname{$data[0]} if $gotGeneList == 0;
      push @values, $data[1];
    } 
    $gotGeneList = 1;
# TODO: throw Exception here if # of values not matched to # of genes;
# It shouldn't be problem for now but it may happen in the future
    $sid2values{$sampleID} = \@values;
  } 

    #END get_experiments_by_sampleid
    my @_bad_returns;
    (ref($results) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"results\" (value was \"$results\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_experiments_by_sampleid:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_experiments_by_sampleid');
    }
    return($results);
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
    my $self = shift;
    my($ids, $gl) = @_;

    my @_bad_arguments;
    (ref($ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"ids\" (value was \"$ids\")");
    (ref($gl) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"gl\" (value was \"$gl\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_experiments_by_sampleid_geneid:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_experiments_by_sampleid_geneid');
    }

    my $ctx = $Bio::KBase::PlantExpressionService::Service::CallContext;
    my($results);
    #BEGIN get_experiments_by_sampleid_geneid


      my $dbh = $self->{_dbh};

      my %sid2values = (); # sample id to value list
        my $genes_str = "'".join("','", @{$gl})."'";
      my @gids = ();
      my @genes = ();
      my %gid2gname = ();

      my $gid_rs = $dbh->prepare("select id, fid from at2id_int where fid in ($genes_str) order by id");
      $gid_rs->execute();
      while( my @data = $gid_rs->fetchrow_array()) {
        $gid2gname{$data[0]} = $data[1];
        push @genes, $data[1];
        push @gids, $data[0];
      }
      my $qgids = "'".join("','", @gids)."'";

      my %gsm2cid = ();
      my $gsms = "'".join("','", @{$ids})."'";
      my $cid_rs = $dbh->prepare("select id, ci from ci2id where ci in ($gsms) order by id");
      $cid_rs->execute;
      while( my @data = $cid_rs->fetchrow_array()) {
        $gsm2cid{$data[1]} = $data[0];
      }

      my $pstmt = $dbh->prepare("select geneID, `signal` from expression where geneID in ($qgids) and sampleID = ? order by geneID");
      my %experiment = ();
      $results = \%experiment;
      $experiment{"genes"} = \@genes;
      $experiment{"series"} = \%sid2values;
      foreach my $sampleID (@{$ids}) {
        $pstmt->bind_param(1, $gsm2cid{$sampleID});
        $pstmt->execute();
        my @values = ();
        while( my @data = $pstmt->fetchrow_array()) {
          push @values, $data[1];
        } 
# TODO: throw Exception here if # of values not matched to # of genes;
# It shouldn't be problem for now but it may happen in the future
        $sid2values{$sampleID} = \@values;
      } 

    #END get_experiments_by_sampleid_geneid
    my @_bad_returns;
    (ref($results) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"results\" (value was \"$results\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_experiments_by_sampleid_geneid:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_experiments_by_sampleid_geneid');
    }
    return($results);
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
    my $self = shift;
    my($lst) = @_;

    my @_bad_arguments;
    (ref($lst) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"lst\" (value was \"$lst\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_eo_sampleidlist:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_eo_sampleidlist');
    }

    my $ctx = $Bio::KBase::PlantExpressionService::Service::CallContext;
    my($results);
    #BEGIN get_eo_sampleidlist
  my $dbh = $self->{_dbh};

  my %eo2series = (); # sample id to value list
    $results = \%eo2series;
  my $pstmt = $dbh->prepare("SELECT DISTINCT s.species, s.sid_extern AS 'GSM_ID' FROM sample s, smpl_eo se, eo e WHERE se.sid = se.sid AND se.eoid=e.eoid AND e.eoid_extern = ?");
  foreach my $eo (@{$lst}) {

    $pstmt->bind_param(1, $eo);
    $pstmt->execute();
    my @sids = ();
    while( my @data = $pstmt->fetchrow_array()) {
      push @sids, [$data[0], $data[1]];
    } 
    $eo2series{$eo} = \@sids;
  } 
    #END get_eo_sampleidlist
    my @_bad_returns;
    (ref($results) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"results\" (value was \"$results\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_eo_sampleidlist:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_eo_sampleidlist');
    }
    return($results);
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
    my $self = shift;
    my($lst) = @_;

    my @_bad_arguments;
    (ref($lst) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"lst\" (value was \"$lst\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_po_sampleidlist:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_po_sampleidlist');
    }

    my $ctx = $Bio::KBase::PlantExpressionService::Service::CallContext;
    my($results);
    #BEGIN get_po_sampleidlist
  my $dbh = $self->{_dbh};

  my %po2series = (); # sample id to value list
    $results = \%po2series;
# TODO: when I have Internet connection, fill the correct SQL stmt
# my $species=pop(@{$lst}) ;  
  my $pstmt = $dbh->prepare("SELECT DISTINCT s.species, s.sid_extern AS 'GSM_ID' FROM sample s, smpl_po sp, po p WHERE s.sid = sp.sid AND sp.poid=p.poid AND p.poid_extern = ? ");
  foreach my $po (@{$lst}) {

    $pstmt->bind_param(1, $po);
    $pstmt->execute();
    my @sids = ();
    while( my @data = $pstmt->fetchrow_array()) {
      push @sids, [$data[0], $data[1]];
    } 
    $po2series{$po} = \@sids;
  } 
    #END get_po_sampleidlist
    my @_bad_returns;
    (ref($results) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"results\" (value was \"$results\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_po_sampleidlist:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_po_sampleidlist');
    }
    return($results);
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
    my $self = shift;

    my $ctx = $Bio::KBase::PlantExpressionService::Service::CallContext;
    my($results);
    #BEGIN get_all_po
  my $dbh = $self->{_dbh};



  my %po2desc = ();
  $results = \%po2desc;
  my $pstmt = $dbh->prepare("SELECT poid_extern AS 'PO_ID', po_anatomy AS 'PO_Anatomy' FROM po");

  $pstmt->execute();
  while( my @data = $pstmt->fetchrow_array()) {
    $po2desc{$data[0]} = $data[1];
  } 
    #END get_all_po
    my @_bad_returns;
    (ref($results) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"results\" (value was \"$results\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_all_po:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_all_po');
    }
    return($results);
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
    my $self = shift;

    my $ctx = $Bio::KBase::PlantExpressionService::Service::CallContext;
    my($results);
    #BEGIN get_all_eo
  my $dbh = $self->{_dbh};


  my %po2desc = ();
  $results = \%po2desc;
  my $pstmt = $dbh->prepare("SELECT eoid_extern AS 'EO_ID', eo_desc AS 'EO_Description' FROM eo");

  $pstmt->execute();
  while( my @data = $pstmt->fetchrow_array()) {
    $po2desc{$data[0]} = $data[1];
  } 
    #END get_all_eo
    my @_bad_returns;
    (ref($results) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"results\" (value was \"$results\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_all_eo:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_all_eo');
    }
    return($results);
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
    my $self = shift;
    my($ids) = @_;

    my @_bad_arguments;
    (ref($ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"ids\" (value was \"$ids\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_po_descriptions:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_po_descriptions');
    }

    my $ctx = $Bio::KBase::PlantExpressionService::Service::CallContext;
    my($results);
    #BEGIN get_po_descriptions
  my $dbh = $self->{_dbh};


  my %po2desc = ();
  $results = \%po2desc;
  my $pstmt = $dbh->prepare("SELECT poid_extern AS 'PO_ID', po_anatomy AS 'PO_Anatomy' FROM po WHERE poid_extern = ?");
  foreach my $po (@{$ids}) {

    $pstmt->bind_param(1, $po);
    $pstmt->execute();
    while( my @data = $pstmt->fetchrow_array()) {
      $po2desc{$data[0]} = $data[1];
    } 
  } 
    #END get_po_descriptions
    my @_bad_returns;
    (ref($results) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"results\" (value was \"$results\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_po_descriptions:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_po_descriptions');
    }
    return($results);
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
    my $self = shift;
    my($ids) = @_;

    my @_bad_arguments;
    (ref($ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"ids\" (value was \"$ids\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_eo_descriptions:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_eo_descriptions');
    }

    my $ctx = $Bio::KBase::PlantExpressionService::Service::CallContext;
    my($results);
    #BEGIN get_eo_descriptions
  my $dbh = $self->{_dbh};


  my %po2desc = ();
  $results = \%po2desc;
  my $pstmt = $dbh->prepare("SELECT eoid_extern AS 'EO_ID', eo_desc AS 'EO_Description' FROM eo WHERE eoid_extern = ?");
  foreach my $po (@{$ids}) {

    $pstmt->bind_param(1, $po);
    $pstmt->execute();
    while( my @data = $pstmt->fetchrow_array()) {
      $po2desc{$data[0]} = $data[1];
    } 
  } 
    #END get_eo_descriptions
    my @_bad_returns;
    (ref($results) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"results\" (value was \"$results\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_eo_descriptions:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_eo_descriptions');
    }
    return($results);
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

1;
