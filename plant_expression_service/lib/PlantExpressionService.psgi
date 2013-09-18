use Bio::KBase::PlantExpressionService::PlantExpressionServiceImpl;

use Bio::KBase::PlantExpressionService::Service;
use Plack::Middleware::CrossOrigin;



my @dispatch;

{
    my $obj = Bio::KBase::PlantExpressionService::PlantExpressionServiceImpl->new;
    push(@dispatch, 'PlantExpression' => $obj);
}


my $server = Bio::KBase::PlantExpressionService::Service->new(instance_dispatch => { @dispatch },
				allow_get => 0,
			       );

my $handler = sub { $server->handle_input(@_) };

$handler = Plack::Middleware::CrossOrigin->wrap( $handler, origins => "*", headers => "*");
