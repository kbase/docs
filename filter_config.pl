use strict;
use Getopt::Long; 
use JSON;
use Pod::Usage;

my $man  = 0;
my $help = 0;
my ($in, $out);
my $names;

GetOptions(
	'h'	=> \$help,
        'i=s'   => \$in,
        'o=s'   => \$out,
	'help'	=> \$help,
	'man'	=> \$man,
	'input=s'  => \$in,
	'output=s' => \$out,
	'n=s'      => \$names,

) or pod2usage(0);


pod2usage(-exitstatus => 0,
	  -output => \*STDOUT,
	  -verbose => 1,
	  -noperldoc => 1,
	 ) if $help;

pod2usage(-exitstatus => 0,
          -output => \*STDOUT,
          -verbose => 2,
          -noperldoc => 1,
         ) if $man;


# do a little validation on the parameters


my ($ih, $oh);

if ($in) {
    open $ih, "<", $in or die "Cannot open input file $in: $!";
}
else {
    $ih = \*STDIN;
}
if ($out) {
    open $oh, ">", $out or die "Cannot open output file $out: $!";
}
else {
    $oh = \*STDOUT;
}


# main logic
my $repos       = {};
my $perl_scalar = deserialize_handle($ih);
foreach my $name (split /\s+/, $names) {
	$repos->{$name} = $perl_scalar->{repos}->{$name};
}
$perl_scalar->{repos} = $repos;
serialize_handle($perl_scalar, $oh);


sub serialize_handle {
	my $handle = shift or
		die "handle not passed to serialize_handle";
	my $oh = shift or
		die "output file handle not passed to serialize_handle";
        my $json_text = to_json( $handle, { ascii => 1, pretty => 1 } );
	print $oh $json_text;
}	


sub deserialize_handle {
	my $ih = shift or
		die "in not passed to deserialize_handle";
	my ($json_text, $perl_scalar);
	$json_text .= $_ while ( <$ih> );
	$perl_scalar = from_json( $json_text, { utf8  => 1 } );
}

 

=pod

=head1	NAME

[% kb_method %]

=head1	SYNOPSIS

[% kb_method %] <options>

=head1	DESCRIPTION

The [% kb_method %] command calls the [% kb_method %] method of a [% kb_client %] object.

=head1	OPTIONS

=over

=item	-h, --help

Basic usage documentation

=item   --man

More detailed documentation

=item   -i, --input

The input file, default is STDIN

=item   -o, --output

The output file, default is STDOUT

=back

=head1	AUTHORS

[% kb_author %]

=cut

1;

