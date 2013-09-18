#!/usr/bin/perl -w
use strict;
package TreeUtils;

# Note -- these utilities are to help using bioperl trees
# They are *not* for use with MOTree.pm

use lib "$ENV{HOME}/Genomics/Perl/modules";
use lib "$ENV{HOME}/Genomics/browser/lib";
use GenomicsUtils;
use Vector;
use Bio::Tree::Tree;
use Bio::Tree::Node;
use Bio::TreeIO;
use Browser::Colors;

require Exporter;

our (@ISA,@EXPORT);
@ISA = qw(Exporter);

{
    # return the NCBI taxonomy tree, for genomes in MicrobesOnline, using the TaxParentChild table
    # requires a database connection; optionally specify the root to start from
    sub taxonomytree() {
	my $ancestorId = @_ ? $_[0] : 131567; # 131567 is cellular organisms
	$ancestorId = $_[0] if @_;
	my $parentChild = &GenomicsUtils::queryHashList("SELECT parentId,childId FROM TaxParentChild WHERE nDistance=1");
	my $childParent = &GenomicsUtils::queryHashList("SELECT childId,parentId FROM TaxParentChild WHERE nDistance=1");
	die "Invalid ancestor" unless defined $ancestorId && exists $parentChild->{$ancestorId};
	my %idToNode = ();
	my $root = Bio::Tree::Node->new();
	$root->id($ancestorId);
	$idToNode{$ancestorId}=$root;
	my @work = @{ $parentChild->{$ancestorId} };
	while (@work > 0) {
	    my $id = shift @work;
	    my @parents = @{ $childParent->{$id} };
	    die "Non-unique parent for $id" unless @parents==1;
	    die "Invalid parent for $id" unless exists $idToNode{$parents[0]};
	    my $node = Bio::Tree::Node->new();
	    $node->id($id);
	    $idToNode{$parents[0]}->add_Descendent($node);
	    $idToNode{$id} = $node;
	    if (exists $parentChild->{$id}) {
		push @work, @{ $parentChild->{$id} };
	    }
	}
	return new Bio::Tree::Tree('-root'=>$root,'nodelete'=>1);
    }

    # all nodes in a depth-first search, as a list-reference
    # the optional second argument should be a hash on internal_id for sorting children
    # (the version of this in Bio::Tree::Tree 1.15 2003/08/11 16:20:33 is wrong)
    sub depthfirst {
	my $tree = shift @_;
	my $sorthash = undef;
	$sorthash = shift @_ if @_;
	my @dfirst = ();
	my @work = $tree->get_root_node();
	while (@work > 0) {
	    my $node = shift @work;
	    push @dfirst, $node;
	    # print $node . "\n";
	    my @children = $node->each_Descendent;
	    if (defined $sorthash) {
		@children = sort { $sorthash->{$a->internal_id} <=> $sorthash->{$b->internal_id} } @children;
	    }
	    unshift @work, @children;
	}
	return \@dfirst;
    }

    # all nodes ordered by a breadth-first search, as a list-reference
    sub breadthfirst($) {
	my ($tree) = @_;
	my @work = ($tree->get_root_node);
	my @bfirst = ();
	while (@work > 0) { my $node = pop @work; push @bfirst, $node; unshift @work, $node->each_Descendent; }
	return \@bfirst;
    }

    # list of nodes -> least common ancestor
    sub lca(@) {
	my @nodes = @_;
	die "No nodes in lca" unless @nodes>0;
	my $lca = shift @nodes;
	while(@nodes>0) {
	    my $node1 = $lca;
	    my $node2 = shift @nodes;
	    my $path1 = &pathToRoot($node1);
	    my $path2 = &pathToRoot($node2);
	    while (@$path1 > 0 && @$path2 > 0 && $path1->[-1]->internal_id == $path2->[-1]->internal_id) { # ->[-1] refers to last element
		pop @$path1;
		$lca = pop @$path2; # point down from root where the path still agrees
	    }
	}
	return $lca;
    }

    # compute the distance *to the root* for every node; uses 1 if branch_length is not defined
    sub nodeDepth {
	my ($tree) = shift @_;
	my $useBranchLen = (@_ > 0) ? shift @_ : 1;
	my $dfirst = &depthfirst($tree);
	my %nodeDepth = ();

	foreach my $node (@$dfirst) {
	    if (!defined $node->ancestor) {
		$nodeDepth{$node->internal_id} = 0;
	    } else {
		die "Parent has no depth yet" unless exists $nodeDepth{$node->ancestor->internal_id};
		$nodeDepth{$node->internal_id} = $nodeDepth{$node->ancestor->internal_id} +
		    ($useBranchLen && defined $node->branch_length ? $node->branch_length : 1);
	    }
	}
	return \%nodeDepth;
    }

    # compute the maximum distance to child leaves from every node; uses 1 if branch_length is not defined
    sub nodeElevation {
	my ($tree) = shift @_;
	my $useBranchLength = (@_>0) ? (shift @_) : 1;
	my $dfirst = &depthfirst($tree);
	my %nodeElevation = ();
	foreach my $node (reverse @$dfirst) {
	    if($node->is_Leaf) {
		$nodeElevation{$node->internal_id} = 0;
	    } else {
		my $max = -1;
		foreach my $child ($node->each_Descendent) {
		    die "No child elevation" unless defined $nodeElevation{$child->internal_id};
		    my $total = $nodeElevation{$child->internal_id} +
			($useBranchLength && defined $child->branch_length ? $child->branch_length : 1);
		    $max = $total if $max < $total;
		}
		$nodeElevation{$node->internal_id} = $max;
	    }
	}
	return \%nodeElevation;
    }

    # Identifies clades with an "elevation" (maximum distance to leaves) within the limit 
    # Does not consider individual leaves as clades
    # Treats the tree as rooted
    # Returns a reference to a hash of group_id->[leaf1,leaf2,...leafN],
    # where group_id is the internal_id of the least common ancestor of the leaves
    # Optionally accepts a reference to a list of nodes that should not be collapsed
    sub groupByElevation($$*) {
	my $tree = shift @_;
	my $maxElevation = shift @_;
	my $keep = @_ > 0 ? shift @_ : [];

	my %nocollapse = ();
	foreach my $node (@$keep) {
	    die unless defined $node;
	    foreach (@{ pathToRoot($node) }) {
		$nocollapse{$_->internal_id} = 1;
	    }
	}
	my $elevation = &nodeElevation($tree);
	my %groups = (); # to be returned
	my @work = $tree->get_root_node->each_Descendent;
	while (@work > 0) {
	    my $node = shift @work;
	    if (!$node->is_Leaf 
		&& $elevation->{$node->internal_id} <= $maxElevation
		&& !exists $nocollapse{$node->internal_id}) {
		my @list = grep {$_->is_Leaf} $node->get_Descendents;
		$groups{$node->internal_id} = \@list;
	    } else {
		push @work, $node->each_Descendent;
	    }
	}
	return \%groups;
    }

    # A fancier version of groupByElevation, with three different keep lists
    # The first keep list is not collapsed
    # The second keep list is a "highlight" list that can be collapsed, but
    #      only with non-highlighted leaves
    # The third list is a no-collapse list of internal nodes
    # Returns a reference to a hash of group -> list of leaves AND a hash of group -> internal_depth, where
    # internal_depth is the internal depth of that group (its branch length)
    # If $hideSides is set, may hide side-branches, e.g. if ((A,B),(C,D)) and all three are very simiar,
    # will collapse to A if $hideSides=1 but to (A,C) if $hideSides=0
    sub groupByElevation2($$$$$$) {
	my ($tree,$maxElevation,$keep,$highlight,$nocollapseList,$hideSides) = @_;
	die unless defined $highlight;

	my %nocollapse = ();
	foreach my $node (@$keep,@$nocollapseList) {
	    die unless defined $node;
	    foreach (@{ pathToRoot($node) }) {
		$nocollapse{$_->internal_id} = 1;
	    }
	}

        # if hideSides=0, is number of highlighted items beneath each node
	# if hideSides=1, is number of different nodes that contain highlighted items
	# (may pick only the highlighted one)
	my %nHighlight = map {$_=>0} $tree->get_nodes();
	foreach my $node (@$highlight) {
	    die unless defined $node;
	    die unless $node->is_Leaf;
	    $nHighlight{$node->internal_id} = 1;
	}
	my $dfirst = TreeUtils::depthfirst($tree);
	foreach my $node (reverse @$dfirst) {
	    next if $node->is_Leaf;
	    my @childN = map {$nHighlight{$_->internal_id}} $node->each_Descendent;
	    if ($hideSides) {
		@childN = map {defined($_) && $_ > 0 ? 1 : 0} @childN;
	    }
	    $nHighlight{$node->internal_id} = Vector::sum(@childN);
	}

	my %doCollapse = (); # internal_id->1 if this node is being collapsed

	my $elevation = &nodeElevation($tree);

	foreach my $node (reverse @$dfirst) {
	    if (!$node->is_Leaf
		&& $elevation->{$node->internal_id} <= $maxElevation
		&& !exists $nocollapse{$node->internal_id}
		&& $nHighlight{$node->internal_id} <= 1) {
		$doCollapse{$node->internal_id} = 1;
		foreach my $child ($node->each_Descendent) {
		    delete $doCollapse{$child->internal_id};
		}
	    }
	}

	my %alreadyDeleted = (); # nodes already in remove list

	my %groups = (); # to be returned
	my %internalDepth = (); # to be returned
	foreach my $node (reverse @$dfirst) {
	    if (exists $doCollapse{$node->internal_id}) {
		my @list = grep {$_->is_Leaf && !exists $alreadyDeleted{$_->internal_id} } $node->get_Descendents;
		$groups{$node->internal_id} = \@list;
		$internalDepth{$node->internal_id} = $node->branch_length();
 		foreach my $leaf (@list) {
		    $alreadyDeleted{$leaf->internal_id} = 1;
		}
	    }
	}
	return (\%groups, \%internalDepth);
    }

    # Because of BioPerl bugs, you should save the returned list of deleted nodes
    # Otherwise, BioPerl may destroy some of the nodes, even though they are still
    # in use
    sub simplify($$) {
	# given a tree and a list of nodes to remove, removes those leaves and then
	# removes intermediate nodes with only one child
	my %cleanup = (); # internal_id of nodes we need to check if they have multiple children, -> node object
	my %deleted = (); # internal_id of nodes we have removed -> 1
	my ($tree,$leaves) = @_;
	my @deletedNodes = ();
	foreach my $leaf (@$leaves) {
	    my $internal_id = $leaf->internal_id;
	    my $parent = $leaf->ancestor;
	    die "Removing leaf " . $leaf->id . " twice" unless defined $parent;
	    delete $parent->{'_desc'}->{$internal_id}; # note direct reference to internals, for speed
	    $cleanup{$parent->internal_id} = $parent;
	    $deleted{$internal_id} = 1;
	    push @deletedNodes, $leaf;
	}

	my $changes;
	do {
	    $changes = 0;
	    foreach my $internal_id (keys %cleanup) {
		if (!exists $deleted{$internal_id}) {
		    my $node = $cleanup{$internal_id};
		    my $nChildren = scalar($node->each_Descendent);
		    if ($nChildren < 2) {
			my $parent = $node->ancestor;
			if (defined $parent) {
			    if ($nChildren==0) { # just delete, no update
				delete $parent->{'_desc'}->{$internal_id}; # note direct reference to internals, for speed
	                    } elsif ($nChildren == 1) { # link from parent to child by summing branch lengths
				push @deletedNodes, $node;
			        removeNode($node);
			    }
			    $cleanup{$parent->internal_id} = $parent;
			    $deleted{$internal_id} = 1;
			    $changes++;
			}
		    }
		}
	    }
	} while($changes > 0);
	return \@deletedNodes;
    }

    # given a node, delete it and have its parent link to the child(ren) instead
    # the length of each new branch (the child) will be the sum of the old branch lengths
    # the bootstrap of the children will not be changed
    # returns a list of the moved children
   sub removeNode($) {
       my ($node) = @_;
       my @children = $node->each_Descendent;
       my $parent = $node->ancestor;
       die "cannot remove root" if !defined $parent;
       my $oldlen = $node->branch_length();
       foreach my $child (@children) {
	   $parent->{'_desc'}{$child->internal_id} = $child;
	   $child->{'_ancestor'} = $parent; # direct reference to internals
	   $child->branch_length($oldlen + $child->branch_length)
	       if defined $oldlen && defined $child->branch_length;
       }
       delete $parent->{'_desc'}->{$node->internal_id}; # note direct reference to internals
       return @children;
   }

   # count the total distance and number of links on the path between two nodes
   sub distance($$) {
       my ($node1,$node2) = @_;
       my $path1 = &pathToRoot($node1);
       my $path2 = &pathToRoot($node2);

       while (@$path1 > 0 && @$path2 > 0 && $path1->[-1]->internal_id == $path2->[-1]->internal_id) { # ->[-1] refers to last element
	   pop @$path1;
	   pop @$path2;
       }
       my $branches = @$path1 + @$path2;
       my $len1 = Vector::sum(map {defined $_->branch_length ? $_->branch_length : 1} @$path1);
       my $len2 = Vector::sum(map {defined $_->branch_length ? $_->branch_length : 1} @$path2);
       return ($len1+$len2,$branches);
   }

   # node -> reference to a list (includes the node as the first item and the root as the last item)
   sub pathToRoot($) {
       my ($node) = @_;
       my @path = ();
       do {
	   push @path, $node;
	   $node = $node->ancestor;
       } while (defined $node);
       return \@path;
   }

   # newick reader treats bootstraps on interior nodes as ids, so convert them back to bootstraps
   sub InternalIdsToBootstraps($) {
       my ($tree) = @_;
       foreach my $node ($tree->get_nodes()) {
	   if (!$node->is_Leaf && defined $node->id && !defined $node->bootstrap) {
	       $node->bootstrap($node->id);
               # cannot set id to undef
	       # Bio::TreeIO::newick writer ignores id if bootstrap is set, anyway
	       $node->id("");
	   }
       }
   }

   # print out tree in depth-first order, with internal ids, to STDERR
   sub DebugPrintTree($) {
       my ($tree) = @_;
       print STDERR join("\t","Node","Parent","Id","Length","Boot")."\n";
	foreach (@{ &depthfirst($tree) }) {
	    print STDERR join("\t",
			      $_->internal_id, defined $_->ancestor?$_->ancestor->internal_id:"",
			      $_->id || "",
			      defined $_->branch_length ? $_->branch_length : "",
			      defined $_->bootstrap ? $_->bootstrap : "")."\n";
	}
   }

   # Given positions for the leaves, position the internal nodes
   # leafY should be indexed by internal_id
   # Returns a hashref
   sub nodeY($$$) {
       my ($tree,$leafY,$useBranchLength) = @_;
       die "Not every leaf has a position" unless scalar(keys %$leafY) == scalar(grep{$_->is_Leaf} $tree->get_nodes);

       my %nodeY = ();

       while (my ($internal_id,$Y) = each(%$leafY)) {
	   $nodeY{$internal_id} = $Y;
       }

       foreach my $node (reverse @{ &depthfirst($tree) }) {
	   next if $node->is_Leaf;
	   my @children = $node->each_Descendent;
	   my $nY = 0;
	   my $sumY = 0;
	   foreach (@children) {
	       my $childId = $_->internal_id;
	       die "Child has no Y-position" unless exists $nodeY{$childId};
	       # weighting the contribution of children to the position by branch-lengths avoids collisions between lines
	       my $weight = defined $_->branch_length && $useBranchLength ? $_->branch_length : 1;
	       # sqrt() is part of weighting: it is an additional heuristic to prevent underweighting of short internal branches
	       $weight = 0.0001 if $weight < 0.0001;
	       $weight = sqrt($weight);
	       $nY+=$weight;
	       $sumY += $nodeY{$childId} * $weight;
	   }
	   $nodeY{$node->internal_id} = $sumY/$nY;
       }
       return \%nodeY;
   }

   # If using branch lengths, values range from 0 (root) to maximum depth of tree
   # Otherwise range from 0 to 1
   sub nodeX($$) {
       my ($tree,$useBranchLength) = @_;
       my $nodeX = $useBranchLength ? &TreeUtils::nodeDepth($tree)
	   : &TreeUtils::nodeElevation($tree,$useBranchLength);
       if (!$useBranchLength) {
	   my $maxX = Vector::max(values %$nodeX);
	   while(my ($node,$x) = each(%$nodeX)) {
	       $nodeX->{$node} = 1 - $nodeX->{$node}/$maxX;
	   }
       }
       return $nodeX;
   }

   sub drawBranches($$$$$) {
       my ($img,$tree,$nodeX,$nodeY,$branchColor) = @_;
       foreach my $node ($tree->get_nodes()) {
	   my $ancestor = $node->ancestor;
	   if(defined $ancestor && defined $ancestor->internal_id) {
	       my $xUp = $nodeX->{$ancestor->internal_id};
	       my $yUp = $nodeY->{$ancestor->internal_id};
	       my $x = $nodeX->{$node->internal_id};
	       my $y = $nodeY->{$node->internal_id};
	       $img->line($x,$y,$xUp,$yUp,$branchColor->{$node->internal_id});
	   }
       }
   }

   sub drawBranchesRectangular($$$$$) {
       my ($img,$tree,$nodeX,$nodeY,$branchColor) = @_;
       foreach my $node ($tree->get_nodes()) {
	   my $ancestor = $node->ancestor;
	   if(defined $ancestor && defined $ancestor->internal_id) {
	       my $xUp = $nodeX->{$ancestor->internal_id};
	       my $yUp = $nodeY->{$ancestor->internal_id};
	       my $x = $nodeX->{$node->internal_id};
	       my $y = $nodeY->{$node->internal_id};
	       $img->line($xUp,$yUp,$xUp,$y,$branchColor->{$node->internal_id});
	       $img->line($xUp,$y,$x,$y,$branchColor->{$node->internal_id});
	   }
       }
   }

   # ids and colors should be hashrefs; font should be a single font
   # returns a reference to a hash of the form node -> [x0,y0,x1,y1]; that
   # can be used to make (e.g.) imagemaps
   sub drawLabels($$$$$$) {
       my ($img,$nodeX,$nodeY,$colors,$ids,$font) = @_;
       my %bounds = ();
       my $width = $font->width;
       my $height = $font->height;
       while (my ($internal_id,$color) = each %$colors) {
	   next unless exists $ids->{$internal_id};
	   my $x = int(.5 + $nodeX->{$internal_id}+$width/2);
	   my $y = int(.5 + $nodeY->{$internal_id}-$height/2);
	   $img->string($font, $x, $y, $ids->{$internal_id}, $color);
	   $bounds{$internal_id} = [$x, $y, $x+ length($ids->{$internal_id})*$width+1, $y+$height];
       }
       return \%bounds;
   }

   # $rules should be a ref to a list of [cutoff,size,fillcolor,outlinecolor], sorted inversely by cutoff
   # (or empty, if you just want expandURL to link nodes)
   # colors may be undef
   # use InternalIdsToBootstraps() first
   # expandURL->{internal_id} exists if gene should have a collapse option, and gives a URL
   # expandedColor, if defined, is used to draw a vertical bar over the nodes that link to a URL
   # returns a string that be included in an image map to add popups with bootstrap values for nodes
   sub highlightBootstrap($$$$$$$) {
       my ($img,$tree,$nodeX,$nodeY,$rules,$expandURL,$expandedColor) = @_;
       my $maxSize = @$rules > 0 ? $rules->[0][1] : 3;
       my $imagemap = "";

       foreach my $node ($tree->get_nodes) {
	   if ($node->each_Descendent>1) {
	       foreach (@$rules) {
		   my ($cutoff,$size,$fill,$outline) = @$_;
		   if (defined $node->bootstrap && $node->bootstrap >= $cutoff) {
		       $img->filledEllipse($nodeX->{$node->internal_id},$nodeY->{$node->internal_id},
					   $size,$size,$fill) if defined $fill;
		       $img->ellipse($nodeX->{$node->internal_id},$nodeY->{$node->internal_id},
				     $size,$size,$outline) if defined $outline;
		       last;
		   }
	       }
	   }
           my $x = int(0.49999+$nodeX->{$node->internal_id});
           my $y = int(0.49999+$nodeY->{$node->internal_id});
	   my $title = defined $node->bootstrap ? "Support: " . $node->bootstrap :
	       ($node->each_Descendent > 1 ? "No support value" : "");
	   my $q = "\"";
	   my $URLString = "";
	   if (exists $expandURL->{$node->internal_id}) {
	       if (@$rules > 0 && defined $expandedColor) {
		   my $size = int($rules->[-1][1]/3);
		   $img->filledRectangle($nodeX->{$node->internal_id} - $size,
					 $nodeY->{$node->internal_id} - 1,
					 $nodeX->{$node->internal_id} + $size,
					 $nodeY->{$node->internal_id} + 1,
					 $expandedColor);
	       }
	       $URLString .= "HREF=$q".$expandURL->{$node->internal_id}."$q";
	   }
	   $imagemap .= "<AREA SHAPE=$q"."rect$q COORDS=$q"
	       . join(",",$x-$maxSize,$y-$maxSize,$x+$maxSize,$y+$maxSize) . $q
	       . " ALT=$q$title$q $URLString TITLE=$q$title$q>\n"
	       if ($node->each_Descendent > 1 || exists $expandURL->{$node->internal_id});
       }
       return $imagemap;
   }

   sub drawScaleBar($$$$$$$$) {
       my ($img,$barXLeft,$barXRight,$barlength,$barYPos,$barsideheight,$color,$font) = @_;
       $img->line($barXLeft,$barYPos,$barXRight,$barYPos,$color);
       $img->line($barXLeft,$barYPos-$barsideheight,$barXLeft,$barYPos+$barsideheight,$color);
       $img->line($barXRight,$barYPos-$barsideheight,$barXRight,$barYPos+$barsideheight,$color);
       $img->string($font,$barXLeft,$barYPos+$barsideheight,"$barlength/site",$color);
   }

    # returns a list of 4 items:
    # 1. a pruned species tree
    # 2. a map of internal_id->taxonomy id->nGenes (may be 0),
    # 3. a count of locusIds in each node
    # 4. a list of unmatched loci.
    # 5. a list of stale nodes in the species tree
    # Warning: will modify the passed-in species tree
    sub LociToPrunedSpeciesTree($$$$$) {
	my ($speciesTree,$loci,$speciesHeight,$anchorLocus,$pruneOutgroups) = @_;

	# get taxon affiliation of loci
	my $lociTax = &GenomicsUtils::queryHashList("SELECT l.locusId,s.taxonomyId FROM Scaffold s, Locus l"
						    . " WHERE l.priority=1 AND l.scaffoldId=s.scaffoldId"
						    . " AND s.isActive=1"
						    . " AND l.locusId IN (" . join(",",@$loci) . ")");
	my %taxLoci =();
	while (my ($locus,$list) = each(%$lociTax)) {
	    my $tax = $list->[0];
	    $taxLoci{$tax} = [] unless exists $taxLoci{$tax};
	    push @{ $taxLoci{$tax} }, $locus;
	}

	# sort taxa, pushing the one containing the anchor locus to top
	my $sortby = &TreeUtils::nodeElevation($speciesTree);
	my %genomeNodes = map { $_->id => $_ } (grep $_->is_Leaf, $speciesTree->get_nodes);
	my $anchorNode = undef;
	if (defined $anchorLocus && exists $lociTax->{$anchorLocus}) {
	    $anchorNode = $genomeNodes{$lociTax->{$anchorLocus}->[0]};
	    if (defined $anchorNode) { # won't be defined if anchor isn't in tree!
		foreach (@{ TreeUtils::pathToRoot($anchorNode) }) {
		    $sortby->{$_->internal_id} -= 1e8;
		}
	    }
	}

	my $dfirst = &TreeUtils::depthfirst($speciesTree,$sortby);
	# determine gene count for each node on tree
	my %geneCount = ();
	foreach my $node (reverse @$dfirst) {
	    if ($node->is_Leaf) {
		$geneCount{$node->internal_id} = exists $taxLoci{$node->id} ? scalar @{ $taxLoci{$node->id} } : 0;
	    } else {
		my @children = $node->each_Descendent;
		$geneCount{$node->internal_id} = Vector::sum(map { $geneCount{$_->internal_id} } @children);
	    }
	}

	foreach my $node (@$dfirst) {
	    foreach my $c ($node->each_Descendent) {
		die unless defined $c->ancestor && $c->ancestor->internal_id == $node->internal_id;
	    }
	}

	# prune to LCA
	my @keepleaves = grep {$_->is_Leaf && $geneCount{$_->internal_id}>0} @$dfirst;
	if (@keepleaves == 0) {
	    # return an empty tree
	    my @unmatchedLoci = grep {!exists $lociTax->{$_}} @$loci;
	    return (new Bio::Tree::Tree('-root' => new Bio::Tree::Node()), {}, {}, $loci, []);
	}
	my $ancestor = &lca(@keepleaves);
	$ancestor->ancestor(undef);
	$ancestor->branch_length(undef);
	$speciesTree->set_root_node($ancestor); # this will forget the rest
	$dfirst = &TreeUtils::depthfirst($speciesTree,$sortby); # reset dfirst

	foreach my $node (@$dfirst) {
	    foreach my $c ($node->each_Descendent) {
		die unless defined $c->ancestor && $c->ancestor->internal_id == $node->internal_id;
	    }
	}

	# sigh, this is an N**2 data structure in the number of genomes, if we're zoomed out
	my %taxa = (); # internal_id  -> taxonomyId -> nGenes (nGenes may be 0)
	foreach my $node (reverse @$dfirst) {
	    if ($node->is_Leaf) {
		$taxa{$node->internal_id} = { $node->id => $geneCount{$node->internal_id} };
	    } else {
		my $subtaxa = {};
		foreach my $child ($node->each_Descendent) {
		    while (my ($taxId,$nGenes) = each %{$taxa{$child->internal_id}}) {
			$subtaxa->{$taxId} = $nGenes;
		    }
		}
		$taxa{$node->internal_id} = $subtaxa;
	    }
	}

	# collapse genes according to speciesHeight
	# if $pruneOutgroups=0, will not collapse a group that does have children with a group that does not
	my @nocollapse = ();
	push @nocollapse, $anchorNode if defined $anchorNode;
	if (!$pruneOutgroups) {
	    foreach my $node ($speciesTree->get_nodes) {
		my $nWith = 0;
		my $nWithout = 0;
		foreach my $child ($node->each_Descendent) {
		    my $n = $geneCount{$child->internal_id};
		    if ($n > 0) { $nWith++; } else { $nWithout++; }
		}
		push @nocollapse, $node if $nWith > 0 && $nWithout > 0;
	    }
	}
	my @removed = ();
	if (defined $speciesHeight) {
	    my $groups = groupByElevation($speciesTree,$speciesHeight, \@nocollapse);
	    foreach my $node (reverse @$dfirst) {
		if (exists $groups->{$node->internal_id}) {
		    foreach my $child ($node->each_Descendent) {
			die unless $child->ancestor->internal_id == $node->internal_id;
			push @removed, $child;
			RemoveDesc($node,$child);
		    }
		    die unless $node->is_Leaf;
		}
	    }
	}
	$dfirst = &TreeUtils::depthfirst($speciesTree,$sortby); # reset dfirst

	# prune boring groups (empty clades)
	foreach my $node (reverse @$dfirst) {
	    if (defined $node->ancestor && $geneCount{$node->internal_id}==0 &&
		$geneCount{$node->ancestor->internal_id}==0) {
		push @removed, $node;
		RemoveDesc($node->ancestor,$node);
	    }
	}
	$dfirst = &TreeUtils::depthfirst($speciesTree,$sortby); # reset dfirst

	# prune other outgroups: classify nodes as all, switch, none, or switch_and_none
	# (switch_and_none has 1 switch node and >= 1 none node)
	# if this node combines 1 or more nones with a parent_of_switch, remove
	# the nones, but add their taxa to the none-child of parent_of_switch, and
	# remove self
	if ($pruneOutgroups) {
	    my ($ALL,$SWITCH,$NONE,$SWITCHNONE) = (0,1,2,3);
	    my %nodeClass = ();
	    foreach my $node (reverse @{ &TreeUtils::depthfirst($speciesTree,$sortby) }) {
		if ($node->is_Leaf) {
		    $nodeClass{$node->internal_id} = $geneCount{$node->internal_id} > 0 ?  $ALL : $NONE;
		} else {
		    # First, if have multiple none children, collapse them
		    my @childNone = grep { $nodeClass{$_->internal_id} == $NONE } $node->each_Descendent;
		    if (@childNone > 1) {
			my $keep = shift @childNone;
			foreach my $child (@childNone) {
			    while (my ($taxId,$nGenes) = each %{$taxa{$child->internal_id}}) {
				$taxa{$keep->internal_id}{$taxId} = $nGenes;
			    }
			    $geneCount{$keep->internal_id} += $geneCount{$child->internal_id};
			    push @removed, $child;
			    RemoveDesc($node,$child);
			}
		    }

		    # Then, recompute counts of each type of node
		    my @children = $node->each_Descendent;
		    my @childC = map {$nodeClass{$_->internal_id}} @children;
		    my %nChildC = map { $_ => 0 } ($ALL,$SWITCH,$NONE,$SWITCHNONE);
		    foreach(@childC) { $nChildC{$_}++; }

		    if (@childC == $nChildC{$NONE}) {
			$nodeClass{$node->internal_id} = $NONE;
		    } elsif ($nChildC{$NONE} >= 1 && $nChildC{$SWITCH} == scalar(@childC)-$nChildC{$NONE}) {
			$nodeClass{$node->internal_id} = $SWITCHNONE;
		    } elsif ($nChildC{$ALL} >= 1 && $nChildC{$NONE} >= 1) {
			$nodeClass{$node->internal_id} = $SWITCH;
		    } elsif ($nChildC{$SWITCHNONE} == 1 && $nChildC{$NONE} >= 1) {
			$nodeClass{$node->internal_id} = $SWITCHNONE;

			# delete the none grandchild of the switchnone child, and put
			# taxa into the none child
			my $child = (grep {$nodeClass{$_->internal_id}==$SWITCHNONE} @children)[0];
			my $grandchild = (grep {$nodeClass{$_->internal_id}==$NONE} $child->each_Descendent)[0];
			my $nonechild = (grep {$nodeClass{$_->internal_id}==$NONE} @children)[0];
			die "Have no grandchild" unless defined $grandchild;
			die "Have no nonechild" unless defined $nonechild;

			while (my ($taxId,$nGenes) = each %{$taxa{$grandchild->internal_id}}) {
			    $taxa{$nonechild->internal_id}{$taxId} = $nGenes;
			}
			$geneCount{$nonechild->internal_id} += $geneCount{$grandchild->internal_id};
			push @removed, $grandchild;
			RemoveDesc($child,$grandchild);
		    } elsif (($nChildC{$SWITCHNONE}+$nChildC{$SWITCH}) >= 1 && $nChildC{$ALL}==0) {
			$nodeClass{$node->internal_id} = $SWITCH;
		    } else {
			$nodeClass{$node->internal_id} = $ALL; # if complex, assume is interesting
		    }
		}
	    }
	}

	my @unmatchedLoci = grep {!exists $lociTax->{$_}} @$loci;
	return ($speciesTree, \%taxa, \%geneCount, \@unmatchedLoci, \@removed);
    }

    sub RemoveDesc($$) {
	my ($node,$child) = @_;
	die unless $child->ancestor->internal_id == $node->internal_id
	    && exists $node->{'_desc'}{$child->internal_id};
	$child->{'_ancestor'} = undef;
	delete $node->{'_desc'}{$child->internal_id};
    }

    # midpoint rooting -- returns 1 on success and 0 on failure
    # only for non-multifurcating trees (but 3 at original root is allowed)
    sub rerootMidpoint {
	my ($tree) = @_;

	my $root = $tree->get_root_node;

	my $maxLeafDist = nodeElevation($tree); # max distance to leaves, going down
	my $rootDist = nodeDepth($tree); # distance to root
	my $dfirst = depthfirst($tree);

	# next, compute the maximum distance to a leaf going up (but not necessarily through the root)
	my %maxLeafDistUp = ();
	$maxLeafDistUp{$root->internal_id} = 0; # so topmost will compute diameter from siblings
	foreach my $node (@$dfirst) {
	    my $internal_id = $node->internal_id;
	    my $len = $node->branch_length;
	    $len = 0 if !defined $len; # b/c of root
	    my @children = $node->each_Descendent;

	    foreach my $child (@children) {
		my @sibs = grep {$_->internal_id != $child->internal_id} @children;
		my @sibups = map {$maxLeafDist->{$_->internal_id} + $_->branch_length} @sibs;

		$maxLeafDistUp{$child->internal_id} = $child->branch_length
		    + Vector::max($maxLeafDistUp{$internal_id}, @sibups);
	    }
	}

	# now select a new "best" node; we will split on the branch up from the node
	# We want to maximize maxLeafDistUp+maxLeafDist (the diameter), but this still leaves a whole
	# path on the tree. 
	# We also want to chose a node that, when we reroot, will become balanced.
	# This requires maxLeafDistUp >= maxLeafDist, because when we reroot, maxLeafDistUp will
	# be reduced and maxLeafDist will be increased, and also
	# maxLeafDist >= maxLeafDistUp - 2*length,
	# because if we (e.g.) split at the top of the branch we decrease maxLeafDistUp by length
	# and increase maxLeafDist by the same amount
	#
	# Because of possible negative branch lengths we actually compute the minimum badness
	# instead of enforcing these requirements strictly
	my %diam = map {$_ => $maxLeafDist->{$_} + $maxLeafDistUp{$_}} (keys %maxLeafDistUp);
	my $maxDiam = Vector::max(values %diam);
	my $bestI = undef;
	my $bestScore = -1e20; # higher is better
	foreach my $node (@$dfirst) {
	    next unless defined $node->ancestor;
	    my $internal_id = $node->internal_id;
	    my $len = $node->branch_length;
	    my $diam = $diam{$internal_id};
	    next unless $diam >= $maxDiam - 1e-6;
	    # minimum of scores (attempt to satisfy both >= criteria)
	    my $score = Vector::min($maxLeafDistUp{$internal_id} - $maxLeafDist->{$internal_id}, # up >= down
				    $maxLeafDist->{$internal_id} + 2*$len - $maxLeafDistUp{$internal_id});
	    if ($score > $bestScore) {
		$bestScore = $score;
		$bestI = $internal_id;
	    }
	}
	die "bestDiam $maxDiam but no nodes with a score?" unless defined $bestI;

	my $best = (grep {$_->internal_id == $bestI} $tree->get_nodes())[0];
	die unless defined $best;
	die unless defined $best->ancestor;
	
	# lenNew is distance from best node up to new root
	# otherLen is distance down from new root to what used to be best's parent
	# (they sum to best->branch_len)
	my $lenNew = ($maxLeafDistUp{$bestI} - $maxLeafDist->{$bestI})/2;
	my $otherLen = $best->branch_length - $lenNew;
	if ($lenNew < -1e-6 || $otherLen < -1e-6) {
	    print STDERR "TreeUtils.pm::rerootMidpoint -- chose node ". $best->internal_id . " -- warning --"
		. " lenNew $lenNew otherLen $otherLen -- may be OK if had negative branch lengths\n";
	}

	# now reroot
	# The node up from the best becomes the new root's other child (besides best),
	# that node's parent becomes its child, etc. etc.
	# The branch lengths down from root (up from best and bests_former_parent) are lenNew and otherLen
	# The next branch length is the branch length up from best_parent, etc.
	# Similarly for bootstraps

	$best->branch_length($lenNew);
	my @upToRoot = @{ &pathToRoot($best) };
	my %onPath = map { $_->internal_id => 0 } @upToRoot; # to distinguish nodes to move from their siblings
	shift @upToRoot; # remove best itself from the path (so it starts with best's parent)

	my $newRoot = Bio::Tree::Node->new([$best]);
	my @newNodes = (); # one for each of the old path; starting with the new root
	push @newNodes, $newRoot;
	my $lastLen = $otherLen; # for new sibling of best (its former parent)
	my $lastBoot = $best->bootstrap;
	foreach my $onpath (@upToRoot) {
	    my @children = grep { !exists $onPath{$_->internal_id} } $onpath->each_Descendent;
	    if ($onpath->internal_id == $root->internal_id && @children==1) {
                # throw out old root (note @children==1 only if old tree was rooted)
		# don't set lastLen (last round)
		push @newNodes, @children;
	    } else {
		my $newnode = Bio::Tree::Node->new(\@children);
 		$newnode->branch_length($lastLen) if defined $lastLen;
		$lastLen = $onpath->branch_length;
		$newnode->bootstrap($lastBoot) if defined $lastBoot;
		$lastBoot = $onpath->bootstrap;
		push @newNodes, $newnode;
	    }
	}
	# link them in
	do {
	    my $newNode = shift @newNodes;
	    $newNode->add_Descendent($newNodes[0]);
	} while (@newNodes >=2);
	$tree->set_root_node($newRoot);
	return 1;
    }

    # $tree = new Bio::TreeIO('-format'=>'newick','-file'=>"big")->next_tree;
    # takes >7 s on lut to read a tree with 7.3K nodes
    #
    # This takes 0.8s, but, I rewrote add_Descendent to be faster, so it is dependent on internals
    # of Node.pm, and I set nodelete=1 in the tree (could that cause memory leaks? I dunno)
    #
    # Also, this routine was originally written to require that branch lengths be present
    # That restriction has been removed, but this has not be thoroughly tested
    # w/o branch lengths.
    sub StringToTree {
	my $line = shift;
	chomp $line;
	die "Cannot parse $line" unless $line =~ m/;$/;
	$line =~ s/;$//;
	my @tokens = split /,/, $line;

	my $root = new Bio::Tree::Node();
	my @sofar = (); # the stack we are at inside the tree
	push @sofar, $root;
	my $firsttoken = 1;
	foreach my $token (@tokens) {
	    my $nDown = 0;

	    # go down
	    if ($token =~ m/^([\(]+)(.*)$/) {
		$nDown = length($1);
		$token = $2;
	    }
	    
	    # if not first, then had a comma, which implies up and then down
	    if ($firsttoken) {
		$firsttoken = 0;
	    } else {
		die scalar(@sofar) if @sofar < 1;
		pop @sofar;
		$nDown++;
	    }
	    
	    while ($nDown-- > 0) {
		my $newnode = new Bio::Tree::Node();
		my $parent = $sofar[-1];
		# Performance optimization on $parent->add_Descendent($newnode);
		$newnode->ancestor($parent);
		$parent->{'_desc'}->{$newnode->internal_id} = $newnode;
		push @sofar, $newnode; 
	    }
	    
	    my @pieces = split /[\)]/, $token, -1; # -1 means keep trailing empty fields
	    my $first = 1;
            # We've removed leading left-parens (from first piece), commas (we're within a token),
            # and these pieces are separated by right-parens
            # Possibilities are:
            # leading right-paren (implied up), which leads to recursion
            # nodename:length
            # bootstrap:length
            # :length
            # name       (no length)
            # 
	    while (@pieces > 0) {
		my $piece = shift @pieces;
		if ($piece ne "") {
		    my ($name, $length);
		    if ($piece =~ m/^([^:]*):([0-9e.-]+)$/) {
			$name = $1;
			$length = $2;
		    } elsif (@pieces == 1 && $pieces[0] eq "" && $piece =~ m/^([0-9.]+)$/) {
			$name = $1;
			$length = undef;
		    } elsif ($piece =~ m/^([^:]+)$/) {
			#die $piece . " " . join("\t",@pieces); # allow missing lengths now
			$name = $1;
			$length = undef;
		    }
		    my $node = $sofar[-1];
		    if (defined $name) {
				# $first name in piece is true iff. this is a leaf
				if ($first) {
					$node->id($name);
				} else { $node->bootstrap($name); }
		    }
		    $node->branch_length($length) if defined $length;
		}
		if (@pieces > 0) {
		    die scalar(@pieces) if @sofar==0;
		    pop @sofar;
		}
		$first = 0;
	    }
	}
	die "Imbalance in left and right parentheses: " . scalar(@sofar) unless @sofar==1; # we should end at root!
	return new Bio::Tree::Tree('-root'=>$root,'nodelete'=>1);
    }

    sub StringToTreeMembers {
	my $line = shift;
	chomp $line;
	my @listMembers;
	die "Cannot parse $line" unless $line =~ m/;$/;
	$line =~ s/;$//;
	my @tokens = split /,/, $line;

	my $firsttoken = 1;
	foreach my $token (@tokens) {
	    my $nDown = 0;

	    # go down
	    if ($token =~ m/^([\(]+)(.*)$/) {
		$nDown = length($1);
		$token = $2;
	    }
	    
	    # if not first, then had a comma, which implies up and then down
	    if ($firsttoken) {
		$firsttoken = 0;
	    } else {
		$nDown++;
	    }
	    
	    my @pieces = split /[\)]/, $token, -1; # -1 means keep trailing empty fields
	    my $first = 1;
            # We've removed leading left-parens (from first piece), commas (we're within a token),
            # and these pieces are separated by right-parens
            # Possibilities are:
            # leading right-paren (implied up), which leads to recursion
            # nodename:length
            # bootstrap:length
            # :length
            # name       (no length)
            # 
	    while (@pieces > 0) {
		my $piece = shift @pieces;
		if ($piece ne "") {
		    my ($name, $length);
		    if ($piece =~ m/^([^:]*):([0-9e.-]+)$/) {
			$name = $1;
			$length = $2;
		    } elsif (@pieces == 1 && $pieces[0] eq "" && $piece =~ m/^([0-9.]+)$/) {
			$name = $1;
			$length = undef;
		    } elsif ($piece =~ m/^([^:]+)$/) {
			#die $piece . " " . join("\t",@pieces); # allow missing lengths now
			$name = $1;
			$length = undef;
		    }
		    if (defined $name) {
				# $first name in piece is true iff. this is a leaf
				if ($first) {
					push @listMembers,$name;
		    }}
		}
		$first = 0;
	    }
	}

	return @listMembers;
    }

    # Given a tree, returns all splits, either as a hash of join(",", oneside) => 1,
    # or a hash of join(",",oneside) => node if mode="hashnode"
    # or, a list of lists
    sub Splits {
	my ($tree,$mode) = @_;
	$mode = "hash" if !defined $mode;
	my $savenode = $mode eq "hashnode" ? 1 : 0;
	my %splits = ();
	my @splits = ();
	my @taxa = map {$_->id} grep {$_->is_Leaf} $tree->get_nodes;

	foreach my $node ($tree->get_nodes) {
	    next if !defined $node->ancestor || $node->is_Leaf;
	    my %split = map {$_->id => 1} grep {$_->is_Leaf} $node->get_all_Descendents;
	    my @with0 = sort grep {!exists $split{$_}} @taxa;
	    my @with1 = sort grep {exists $split{$_}} @taxa;

	    if (@with0>1 && @with1>1) {
		my $key0 = join(",",@with0);
		my $key1 = join(",",@with1);
		if (!exists $splits{$key0} && !exists $splits{$key1}) {
		    push @splits, \@with0;
		}
		$splits{$key0} = $savenode ? $node : 1;
		$splits{$key1} = $savenode ? $node : 1;
	    }
	}
	return $mode eq "hash" || $mode eq "hashnode" ? \%splits : \@splits;
    }

    # Takes a tree from the MO database as an argument (leaf names as locus_begin_end)
    sub rewriteMOLeafNames($$) {
	my ($tree,$lociInfo) = @_;
	foreach my $node (@{ $tree->depthfirst() }) {
	    next unless $tree->is_Leaf($node);
	    my $locusSpec = $tree->id($node);
	    my ($locusId,$beg,$end) = split /[._]/, $locusSpec;
	    if (exists $lociInfo->{$locusSpec}) {
		$locusId = $locusSpec;
		$beg = "";
		$end = "";
	    }
	    if (defined $end && exists $lociInfo->{$locusId}) {
		my $info = $lociInfo->{$locusId};
		my $name = $info->{sysName} . " " . $info->{genome};
		$name .= "_aa".$beg."_".$end if $beg ne "";
                # newick format doesn't like special characters or (usually) spaces
		$name =~ s/[^A-Za-z0-9.]/_/g;
		$tree->set_id($node,$name);
	    }
	}
    }

    sub rewriteLeafNames($$) {
	my ($tree,$lociInfo) = @_;
	foreach my $node ($tree->get_nodes) {
	    next unless $node->is_Leaf;
	    my $locusSpec = $node->id;
	    my ($locusId,$beg,$end) = split /[._]/, $locusSpec;
	    if (exists $lociInfo->{$locusSpec}) {
		$locusId = $locusSpec;
		$beg = "";
		$end = "";
	    }
	    if (defined $end && exists $lociInfo->{$locusId}) {
		my $info = $lociInfo->{$locusId};
		my $name = $info->{sysName} . " " . $info->{genome};
		$name .= "_aa".$beg."_".$end if $beg ne "";
                # newick format doesn't like special characters or (usually) spaces
		$name =~ s/[^A-Za-z0-9.]/_/g;
		$node->id($name);
	    }
	}
    }

    sub BoxToImageMap {
	my %param = @_;
	my $title = $param{title};
	my $coords = $param{coords};
	my $URL = $param{URL};
	my $onClick = $param{onClick};
	my $extra = $param{extra};
	my $rect = $param{shape} || "rect";
        die unless defined $coords;

	if (defined $title || defined $URL || defined $onClick || defined $extra) {
	    my $coordsString = join(",",@$coords);
	    my @pieces = (qq{<AREA SHAPE="$rect" COORDS="$coordsString"});
	    push @pieces, qq{ALT="$title" TITLE="$title"} if defined $title;
	    push @pieces, qq{HREF="$URL"} if defined $URL;
	    push @pieces, qq{onClick="$onClick"} if defined $onClick;
	    push @pieces, $extra if defined $extra;
	    push @pieces, ">";
	    return join(" ", @pieces);
	}
	return "";
    }
1;
} 
