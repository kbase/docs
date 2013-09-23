use strict;
use warnings;
use Data::Dumper;

use lib "/Users/Andi/Development/kbase/communities_qc/client" ;
use lib "/Users/Andi/Development/kbase/kb_seed/lib/" ;




use Microbial_Communities_QCClient ;

=pod

=head1 Communities QC 

=head2 Tutorials

=over 2

=item DRISEE

How good is the sequence quality of my WGS metagenome

=item K-mer

=item Nucleotide Profile

=back

=cut


=pod 

=head2 Initializing data object

I order to get started a client object has to be initialzed.
First define the service url and then create the client:

 my $HOST='http://kbase.us/services/communities/';
 my $client = Microbial_Communities_QCClient->new($HOST);


=cut

my $HOST='http://kbase.us/services/qc/';
my $HOST='http://0.0.0.0:7052';
my $client = Microbial_Communities_QCClient->new($HOST); # create a new object with the URL

=pod

=head2 Compute DRISEE scores 

For a metagenome in KBase Auxiliary Store compute the DRISEE scores. 
Please substitue the ID with your data set ID 

 my $id = "kb|mg.1"
 $client->get_drisee_compute( { id => $id } )

=cut

my $id = "kb|mg.1";
my $status = $client->get_drisee_compute( { id => $id } );

while($status->{status} ne "complete"){
  $status = $client->get_drisee_compute( { id => $id } );
}


=pod

=head2 Retrieve DRISEE scores 

For a metagenome in KBase Auxiliary Store retrieve the DRISEE scores. 
Please substitue the ID with your data set ID. 

 my $drisee = $client->get_drisee_instance( { id => $id } )
 
=cut

my $drisee = $client->get_drisee_instance( { id => $id } );

print Dumper $drisee ;
