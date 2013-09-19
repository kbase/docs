#!/usr/bin/perl -w
use strict;
use warnings;

use Test::More tests => 875;
use LWP::UserAgent;
use HTTP::Request;
use Data::Dumper;
use JSON;
my $json = new JSON;
$json = $json->allow_singlequote(1);

my $HOST = "http://kbase.us/services/communities/";
my $uri = "$HOST";
my $response;
my $browser;

#
#	Get Resource List off the main page
#	e.g., abundanceprofile, library, metagenome
#	http://api.metagenomics.anl.gov/api2.cgi
sub resources
{
	my $rary = shift ;
	foreach my $key (@$rary)
	{
#		print "Resources: KEY=$key\n";
		if (ref($key) eq 'HASH')
		{
			my $name = $key->{'name'};
			my $url  = $key->{'url'};
#			next unless ($name =~ /sequenceset/);
			&parse_resource($name,$url);	
		}
	}
}

#
#	Get and Parse an individual Resource Page
#	e.g., abundanceprofile, library, metagenome, etc.
#	http://api.metagenomics.anl.gov/api2.cgi/abundanceprofile
#	http://api.metagenomics.anl.gov/api2.cgi/library
sub parse_resource
{
	my ($name,$url) = @_;
	my $req = HTTP::Request->new( 'GET', $url );

#
#  Send POST request - was it a redirect as expected
#
	my $response = $browser->request($req);
	my $rhash = $json->decode($response->content);
	my %attrib;
	foreach my $key (keys(%$rhash))
	{
		$attrib{$key} = $rhash->{$key};
#		print "Service $name: KEY=$key VALUE=$rhash->{$key}\n";
	}
	print "Resource $name\n\tURL=$rhash->{'url'}\n";
#	print "\tDescription $rhash->{'description'}\n\tRequests $rhash->{'requests'}";
	&requests($rhash->{'requests'});

}

#
#	Get and Parse Requests Page
#	e.g., info, query, instance
#	Get the options, attributes, and IDs
sub requests
{
	my $rary = shift;
	my @ids;

	foreach my $key (@$rary)
	{
#		print "\tRequest: KEY=$key REF=".ref($key)."\n";
		if (ref($key) eq 'HASH')
		{
			my $name = $key->{'name'};
			my $meth = $key->{'method'};
			print "\tRequest NAME=$name METHOD=$meth ATTRIBUTES=$key->{'attributes'}\n";

#			print "\tDESC=$key->{'description'}\n";

			my %option_hash = &parse_options($key->{'parameters'});
			my %attrib_hash = &parse_attribute($key->{'attributes'}) unless ($name eq 'info');
			@ids = &parse_query($key->{'request'},\%option_hash,\%attrib_hash) if ($key->{'name'} eq 'query');	
			if ($#ids < 1)
			{
				@ids = qw (mgm4440026.3 mgm4440036.3 mgm4440038.3 mgm4440054.3);
			}

			&parse_instance($key->{'request'},\%option_hash,\%attrib_hash,@ids) if ($key->{'name'} eq 'instance' || $key->{'name'} eq 'md5' || $key->{'name'} eq 'annotation' || $key->{'name'} eq 'setlist');	
		}
	}

}

#
#	Pull all of the options out of the Parameters hash
#
sub parse_options
{
	my ($parms) = @_;

	my $option = $parms->{'options'};

	my %option_hash;
	$option_hash{'limit'} = 'N';
	$option_hash{'offset'}  = 'N';

	foreach my $key (keys(%$option ))
	{
		$option_hash{'limit'} = 'Y' if ($key eq 'limit');
		$option_hash{'offset'}  = 'Y' if ($key eq 'offset');

#		Loop through all the types that have a controlled vocabulary
		if ($key eq 'order' || $key eq 'source' || $key eq 'type' || $key eq 'verbosity')
		{
#			print "\t\tOPTION KEY=$key VALUE=$option->{$key} \n";
			my $orders = $option->{$key};
			if ($orders->[0] eq 'cv')
			{
				my $rary = $orders->[1];
				my @ary = ();
				foreach my $key2 (@$rary)
				{
					push(@ary,$key2->[0]);
#					print "\t\t\tDEBUG: TYPE=$key CV=$key2->[0]\n"; 
				}
				$option_hash{$key} = \@ary;
			}
		}
		else
		{
#			print "\t\tOPTION KEY=$key --- Manually set value \n";
			$option_hash{'limit'} = 3 if ($key eq 'limit');
			$option_hash{'offset'} = 56 if ($key eq 'offset');
		}
	}

	return %option_hash;
}

#
#	Pull all of the attributes out of the Parameters hash
#
sub parse_attribute
{
	my ($attrib) = @_;
	my @attrib_ary ;
	my %attrib_hash ;
#	Do the Query but not other things which happen to have 'data'
	if (exists $attrib->{'data'} && exists $attrib->{'next'} )
	{
			my $tmp = $attrib->{'data'}->[1]->[1];
			$attrib = $tmp;
	}

	foreach my $key (keys(%$attrib ))
	{
#		print "\t\tATTRIB KEY=$key  TYPE=$attrib->{$key}->[0]\n";
		$attrib_hash{$key} = $attrib->{$key}->[0];
	}
	return %attrib_hash;
}


sub parse_query
{
	my ($request,$options,$attrib) = @_;

#	print "\t\tRequired = $parms->{'required'} BODY=$parms->{'body'} OPTIONS=$parms->{'options'} \n";
	
	my $limit = $options->{'limit'};
	my $offset = $options->{'offset'};
	my $verbosity = '';
	my %option_hash = %$options;

	my @ids;
	if ($limit && $offset )
	{
#		print "DEBUG: BOTH limit and offset\n";
		foreach my $key2 (keys(%option_hash))
		{	
			next unless (ref($option_hash{$key2}) eq 'ARRAY');
			foreach (@{$option_hash{$key2}})
			{
				my $url = "$request?limit=$limit&offset=$offset";
				my $type = $_;
				$url .= "&$key2=$_" if ($key2 gt ' ');
#				print "DEBUG:    TYPE=$type KEY=$key2     URL=$url\n";
				my @myid = &get_minimal($url,$attrib);
				push(@ids,@myid);
				$verbosity = 'Y' if ($key2 eq 'verbosity' && $_ eq 'full');
			}
		}
	}
	elsif ($limit )
	{
		print "DEBUG: limit and NO offset\n";
		foreach my $key2 (keys(%option_hash))
		{	
			next unless (ref($option_hash{$key2}) eq 'ARRAY');
			foreach (@{$option_hash{$key2}})
			{
				my $url = "$request?limit=$limit";
				my $type = $_;
				$url .= "&$key2=$_" if ($key2 gt ' ');
#				print "DEBUG:    TYPE=$type KEY=$key2     URL=$url\n";
				my @myid = &get_minimal($url,$attrib);
				push(@ids,@myid);
				$verbosity = 'Y' if ($key2 eq 'verbosity' && $_ eq 'full');
			}
		}
	}
	elsif ($offset eq 'Y')
	{
		print "DEBUG: NO limit and offset\n";
		foreach my $key2 (keys(%option_hash))
		{	
			next unless (ref($option_hash{$key2}) eq 'ARRAY');
			foreach (@{$option_hash{$key2}})
			{
				my $url = "$request?offset=$offset";
				my $type = $_;
				$url .= "&$key2=$_" if ($key2 gt ' ');
#				print "DEBUG:    TYPE=$type KEY=$key2     URL=$url\n";
				my @myid = &get_minimal($url,$attrib);
				push(@ids,@myid);
				$verbosity = 'Y' if ($key2 eq 'verbosity' && $_ eq 'full');
			}
		}
	}
	else
	{
		print "DEBUG: NO limit and NO offset\n";
		foreach my $key2 (keys(%option_hash))
		{	
			next unless (ref($option_hash{$key2}) eq 'ARRAY');
			foreach (@{$option_hash{$key2}})
			{
				my $url = "$request";
				my $type = $_;
				$url .= "&$key2=$_" if ($key2 gt ' ');
#				print "DEBUG:    TYPE=$type KEY=$key2     URL=$url\n";
				my @myid = &get_minimal($url,$attrib);
				push(@ids,@myid);
				$verbosity = 'Y' if ($key2 eq 'verbosity' && $_ eq 'full');
			}
		}
	}

	if ($verbosity eq 'Y')
	{
		my $url = "$request?verbosity=full";
		$url .= "&limit=2" if ($limit );
		&get_verbose($url,$attrib);
	}

	return(@ids);
}

sub get_minimal
{
	my ($url,$attrib) = @_;
	my $req = HTTP::Request->new( 'GET', $url );
	my $response = $browser->request($req);
	my @ids = ();
	print "\t\tOptTest: REQUEST=$url\n";

	my $rhash = $json->decode($response->content);
	my $data = $rhash->{'data'};
	foreach my $key (@$data)
	{
#		print "KEY=$key ID=$key->{'id'}\n";
		if ($url =~ /id/ && exists $key->{'id'})
		{
			push(@ids,$key->{'id'});
		}
	}

#
#	Only need to test the first one returned
#
	$data = pop($rhash->{'data'});
	foreach my $key (keys(%$data))
	{
#		print "\t\t\t$key=$data->{$key}\n";
		ok(exists $attrib->{$key}, "Is the Attribute $key Valid");

		if (exists $attrib->{$key} && $attrib->{$key} =~ /^list/)
		{
			is(ref($data->{$key}),'ARRAY',"Is Attribute $key is a list");
		}
		if (exists $attrib->{$key} && $attrib->{$key} =~ /^hash/)
		{
			is(ref($data->{$key}),'HASH',"Is Attribute $key is a hash");
		}
	}

	return(@ids);
}

sub get_verbose
{
	my ($url,$attrib) = @_;
	my @find_att = keys(%$attrib);
	print "\t\tAttTest REQUEST=$url\n";
	my $req = HTTP::Request->new( 'GET', $url );
	my $response = $browser->request($req);

	my $rhash = $json->decode($response->content);
#
#	Only need to test the first one returned
#
	my $data = pop($rhash->{'data'});

	my %found_att ;
	foreach my $key (@find_att)
	{
		$found_att{$key} = 'Y';
	}

	foreach my $key (keys(%$data))
	{
		ok(exists $attrib->{$key}, "Is the Attribute $key Valid");

		if (exists $attrib->{$key} && $attrib->{$key} =~ /^list/)
		{
			is(ref($data->{$key}),'ARRAY',"Is Attribute $key is a list");
		}
		if (exists $attrib->{$key} && $attrib->{$key} =~ /^hash/)
		{
			is(ref($data->{$key}),'HASH',"Is Attribute $key is a hash");
		}
		$found_att{$key} = 'U';
	}

	foreach my $key (@find_att)
	{
		next if ($found_att{$key} eq 'U');
		print "\t\t\tATTRIBUTE $key of type $attrib->{$key} NOT FOUND in the returned data\n";
	}
}

sub parse_instance
{
	my ($request,$option_hash,$attrib,@ids) = @_;
	return if ($request =~ /sequenceset/ && exists ($attrib->{'data'}) && $attrib->{'data'} eq 'file');

	$request =~ s/\{ID\}//;
	my $first_id = shift(@ids);

	foreach my $option_type (keys(%$option_hash))
	{
		my $options = $option_hash->{$option_type};
		next unless (ref($options) eq 'ARRAY');
		foreach my $opt (@$options)
		{
			my $url = "$request$first_id?$option_type=$opt";
			$url .= "&type=function" if ($opt eq 'NOG' || $opt eq 'COG' || $opt eq 'KO' || $opt eq 'GO' || $opt eq 'Subsystems' );
			print "\t\tOptTest: REQUEST=$url\n";
			&get_instance($url,$attrib);
		}
	}

	foreach my $key (@ids)
	{
		print "\t\tNoOptTest: REQUEST=$request$key \n";
		my $url = "$request$key";
		&get_instance($url,$attrib);
	}
}

sub get_instance
{
	my ($url,$attrib) = @_;
#	print "\t\tDEBUG: URL=$url\n";
	my $req = HTTP::Request->new( 'GET', $url );
	my $response = $browser->request($req);
	my $length = length($response->content);
#	print "RETURN=".$response->content."\n";
	my $rary;  
	eval ( ($rary) = $json->decode($response->content) );
	if ($@)
	{
		print "The return was not a well-formed JSON object";
		print "ERROR=$@\n";
	}

#	print Dumper($rary);  

	my $data;
	if (ref($rary) eq 'ARRAY')
	{
		$data = pop(@$rary);
	}
	else
	{
		$data = $rary;
	}

	foreach my $key (keys(%$data))
	{
#		print "\t\t\tKEY=$key VALUE=$data->{$key}\n" ;
		ok(exists $attrib->{$key}, "Is the Attribute $key Valid");

		if (exists $attrib->{$key} && $attrib->{$key} =~ /^list/)
		{
			is(ref($data->{$key}),'ARRAY',"Is Attribute $key is a list");
		}
		if (exists $attrib->{$key} && $attrib->{$key} =~ /^hash/)
		{
			is(ref($data->{$key}),'HASH',"Is Attribute $key is a hash");
		}
	}

}

########################         MAIN       #######################
$browser = LWP::UserAgent->new;
# Get the starting documentation
my $req = HTTP::Request->new( 'GET', $uri );

#
#  Send POST request - was it a redirect as expected
#
$response = $browser->request($req);

my $rhash = $json->decode($response->content);
my %attrib;
foreach my $key (keys(%$rhash))
{
	$attrib{$key} = $rhash->{$key};
#	print "Service: KEY=$key VALUE=$rhash->{$key}\n";
}

&resources($attrib{'resources'});

