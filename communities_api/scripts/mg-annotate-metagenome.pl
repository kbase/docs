#!/kb/runtime/bin/perl

use strict;
use warnings;
no warnings('once');

use Config::Simple;
use JSON;
use File::Slurp;
use Getopt::Long;
use LWP::UserAgent;
use MIME::Base64;
use Data::Dumper;
use Pod::Usage;
umask 000;

my $CONFIG = '/kb/deployment/deployment.cfg';
my $OAUTH_URL = 'https://nexus.api.globusonline.org/goauth/token?grant_type=client_credentials';

=head1 NAME

mg-annotate-metagenome -- submit a metagenome to be annotated by the microbial communities pipeline

=head1 VERSION

1

=head1 SYNOPSIS

mg-annotate-metagenome [-h] [-b bowtie] [-d dereplicate] [-m metadata_file_id] [-p KB_password] [-u KB_user] [-w MGRAST_webkey] -f sequence_file_id -n metagenome_name

=head1 DESCRIPTION

Submit a metagenome to be annotated by the microbial communities pipeline.  If you are working in IRIS and are authenticated, you do not need to enter your KB_user and KB_password.  To have your metagenome loaded into MG-RAST, include an MG-RAST webkey.  NOTE: If you include an MG-RAST webkey you can still modify pipeline parameters, however the MG-RAST default workflow will be used to annotate your metagenome, rather than the AWE_template you may have specified.

Parameters:

=over 8

=item -f B<sequence_file_id>

sequence/read file ID in datastore

=item -n B<metagenome_name>

metagenome/file name for sequence file in datastore, must match any metagenome name in metadata file

=back

Options:

=over 8

=item -h

display this help message

=item -b B<bowtie>

switch to declare whether bowtie should be run to screen for human sequences (1 or 0, default 1)

=item -d B<dereplicate>

switch to declare whether dereplication should be run (1 or 0, default 1)

=item -m B<metadata_file_id>

metadata file ID in datastore

=item -p B<KB_password>

KBase password to authenticate against the API, requires a username to be set as well

=item -u B<KB_user>

KBase username to authenticate against the API, requires a password to be set as well

=item -w B<MGRAST_webkey>

Valid MG-RAST webkey

=back

Output:

JSON structure that contains the result data

=head1 EXAMPLES

-

=head1 SEE ALSO

-

=head1 AUTHORS

Jared Bischof, Travis Harrison, Folker Meyer, Tobias Paczian, Andreas Wilke

=cut

# vars hash is used to store anything that will be used to fill in workflow template.
# NOTE: some of the variables in the vars hash are superfluous and not used to fill
#       in the template.

my %vars = ();

# variables in config file (defaults are hard-coded here)
$vars{aweurl} = "http://localhost:7080";
$vars{shockurl} = "http://localhost:7078";
$vars{mem_host} = "10.0.4.96:11211";

# hard-coded variables
$vars{aa_pid} = 90;
$vars{ach_annotation_ver} = 1;
$vars{clientgroups} = "awe-mgr";
$vars{fgs_type} = "454";
$vars{filter_options} = "filter_options='filter_ambig:max_ambig=5:filter_ln'";
$vars{md5rna_clust} = "md5nr.clust";
$vars{prefix_length} = 50;
$vars{project} = "mgrast-pipeline";
$vars{rna_pid} = 97;
$vars{screen_indexes}='h_sapiens_asm';
$vars{totalwork} = 16;

# command line parameters
$vars{shocknode} = "";
$vars{jobname} = "";

# command line options
$vars{bowtie} = 1;
$vars{dereplicate} = 1;
$vars{metadata_file_id} = "";
my $password = "";
$vars{user} = "";
my $webkey = "";
my $help = 0;
my $options = GetOptions ("f=s"  => \$vars{shocknode},
                          "n=s"  => \$vars{jobname},
			  "b=s"  => \$vars{bowtie},
			  "d=s"  => \$vars{dereplicate},
			  "m=s"  => \$vars{metadata_file_id},
			  "p=s"  => \$password,
			  "u=s"  => \$vars{user},
			  "w=s"  => \$webkey,
                          "help" => \$help
			 );

# creating aliases for these variables because their names in this script are different than their names
#  in the MG-RAST default AWE workflow template.
$vars{metadata_file_id} = $vars{inputfile};
$vars{metagenome_name} = $vars{jobname};
$vars{sequence_file_id} = $vars{shocknode};

if ($help) {
    pod2usage( { -message => "\nFor more detailed documentation run 'perldoc $0'\n",
                 -exitval => 0
               } );
}

# error-handling inputs...
my %missing;
foreach my $i ('metagenome_name', 'sequence_file_id') {
    if($vars{$i} eq "") {
        $missing{$i} = 1;
    }
}

if(keys %missing > 0) {
    print STDERR "\nERROR, the following parameters are missing from your command:\n";
    foreach my $i (keys %missing) {
        print STDERR "  $i\n";
    }
    print "\nFor more detailed documentation run 'perldoc $0'\n\n";
    exit 1;
}

my $cfg = new Config::Simple($CONFIG);
my $p_cfg = $cfg->param(-block=>'communities_pipeline');
foreach my $i ('aweurl',
               'shockurl',
               'mem_host') {
    if(defined $p_cfg->{$i}) {
        $vars{$i} = $p_cfg->{$i};
    } else {
        $missing{$i} = 1;
    }
}

if(keys %missing > 0) {
    print STDERR "\nERROR, the following parameters are missing from your config file ($CONFIG):\n";
    foreach my $i (keys %missing) {
        print STDERR "  $i\n";
    }
    print "\nFor more detailed documentation run 'perldoc $0'\n\n";
    exit 1;
}

my $token = "";
if(exists $ENV{"KB_AUTH_TOKEN"}) {
    $token = $ENV{"KB_AUTH_TOKEN"};
} elsif($vars{user} ne "" && $password ne "") {
    my $encoded = encode_base64($vars{user}.':'.$password);
    my $json = new JSON();
    my $pre = `curl -s -H "Authorization: Basic $encoded" -X POST "https://nexus.api.globusonline.org/goauth/token?grant_type=client_credentials"`;
    eval {
        my $res = $json->decode($pre);
        unless(exists $res->{access_token}) {
            print STDERR "ERROR, could not authenticate user, exiting.\n\n";
            exit 1;
        }
        $token = $res->{access_token};
    };
    if ($@) {
        print STDERR "could not reach auth server: $@\n";
        exit 1;
    }
} else {
    print STDERR "ERROR, user not authenticated, exiting.\n\n";
    exit 1;
}
print "$token\n";

###############################################################################
#
# Done handling inputs, now to check the Shock nodes for valid data and
#  validate the inputs.
#
###############################################################################

my $md_filename = "";
# Checking if files are in Shock and have a non-zero size.
print "\nINFO, validating file in Shock nodes.\n";
foreach my $var_name ('metadata_file_id', 'sequence_file_id') {
    if($var_name eq 'sequence_file_id' || ($var_name eq 'metadata_file_id' && $vars{metadata_file_id} ne "")) {
        my $snode_url = "http://".$vars{shockurl}.'/node/'.$vars{$var_name};
        my $ua = LWP::UserAgent->new();
        my $get = $ua->get($snode_url);
        unless ($get->is_success) {
            print STDERR "ERROR, could not retrieve Shock node for '$var_name' via url: $snode_url\n";
            exit 1;
        }

        my $json = new JSON();
        my $res = $json->decode( $get->content );
        my $size = $res->{data}->{file}->{size};
        if($size =~ /^\d+$/ && $size > 0) {
            print "INFO, Shock node for '$var_name' has a size of $size bytes.\n";
        } else {
            print STDERR "ERROR, Shock node for '$var_name' does not exist or is 0 bytes in size.\n";
            exit 1;
        }

        if($var_name eq 'metadata_file_id') {
            $md_filename = $res->{data}->{file}->{name};
        } elsif($var_name eq 'sequence_file_id') {
            $vars{inputfile} = $res->{data}->{file}->{name};
        }
    }
}

# Downloading metadata file to validate it if file metadata was submitted.
if($vars{metadata_file_id} ne "") {
    print "INFO, downloading metadata file for validation.\n";
    my $ua = LWP::UserAgent->new();
    my $get = $ua->get("http://".$vars{shockurl}.'/node/'.$vars{'metadata_file_id'}."?download", ":content_file" => $md_filename);

    print "INFO, validating metdata file.\n";
    my $post = $ua->post("http://dev.metagenomics.anl.gov/api.cgi/metadata/validate",
                         Content_Type => 'form-data',
                         Content      => [ upload => [$md_filename] ]
                        );

    my $json = new JSON();
    my $res = $json->decode( $post->content );
    if($res->{is_valid} == 0) {
        print STDERR "ERROR, your metadata file did not validate.\n";
        print STDERR $res->{message}."\n";
        print STDERR "Exiting without job submission.\n\n";
        exit 1;
    } else {
        print "INFO, metadata validated.\n";
    }

    print "INFO, checking if metagenome_name exists in metadata file as file_name or metagenome_name.\n";
    my $job_found = 0;
    foreach my $sample (@{$res->{metadata}->{samples}}) {
        foreach my $library (@{$sample->{libraries}}) {
            if((exists $library->{data}->{metagenome_name}->{value} && $vars{metagenome_name} eq $library->{data}->{metagenome_name}->{value}) ||
               (exists $library->{data}->{file_name}->{value} && $vars{inputfile} eq $library->{data}->{file_name}->{value})) {
               $job_found = 1;
            }
        }
    }

    if($job_found == 0) {
        print STDERR "ERROR, metagenome_name '".$vars{metagenome_name}."' not found in any 'metagenome_name' field in metadata.\n";
        print STDERR "       and input file name '".$vars{inputfile}."' not found in any 'file_name' field in metadata.\n";
        print STDERR "Exiting without job submission.\n\n";
        exit 1;
    } else {
        print "INFO, job found in metadata.\n";
    }
}

###############################################################################
#
#  Now submit the pipeline!
#
###############################################################################

# If a webkey was supplied, then we need to submit this job to MG-RAST and get
# back an MG-RAST ID and then get a KBase ID using this command:
# curl -X POST -d '{"method":"IDServerAPI.register_ids","version":"1.1","params":["mg","MG-RAST",["mgm4441681.3"]]}' http://www.kbase.us/services/idserver

# Allocate a KBase ID for this metagenome

my $ua = LWP::UserAgent->new();
my $post = $ua->post("http://www.kbase.us/services/idserver",
                     Content_Type => 'form-data',
                     Content      => { method => "IDServerAPI.register_ids",
                                       version => 1.1,
                                       params => ["mg", 1] }
                    );

my $json = new JSON();
my $res = $json->decode( $post->content );
print Dumper($res);
