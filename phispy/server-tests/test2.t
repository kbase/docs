#!/kb/runtime/bin/perl
use Bio::KBase::Phispy::PhispyImpl;
$s = Bio::KBase::Phispy::PhispyImpl->new();
$s->get_all_training_sets();
