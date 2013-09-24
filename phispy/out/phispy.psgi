use PhispyImpl;

use PhispyServer;



my @dispatch;

{
    my $obj = PhispyImpl->new;
    push(@dispatch, 'Phispy' => $obj);
}


my $server = PhispyServer->new(instance_dispatch => { @dispatch },
				allow_get => 0,
			       );

my $handler = sub { $server->handle_input(@_) };

$handler;
