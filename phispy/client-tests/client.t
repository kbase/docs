use Test::More;
BEGIN { use_ok( 'Bio::KBase::Phispy::Client' ) };
my $c = Bio::KBase::Phispy::Client->new("http://localhost:7072");
isa_ok($c, 'Bio::KBase::Phispy::Client', 'c isa Bio::KBase::Phispy::Client');
can_ok($c, 'get_all_training_sets');
can_ok($c, ,'find_prophages');

# functional tests
my $training_sets = $c->get_all_training_sets();
isa_ok($training_sets, "ARRAY");
ok(@$training_sets > 0, "training sets > 0");

done_testing;
