#!/usr/bin/perl -w
use strict;
package MOTreeDraw;
use GD;
require Exporter;

our (@ISA,@EXPORT);
@ISA = qw(Exporter);
@EXPORT = qw( MOTreeDraw );

{
    # Required parameters:
    # img -- a GD image
    # tree -- a MOTree
    # leafY -- leaf => y position in pixels
    # left -- x position of root
    # right -- maximum x position of a leaf
    # defaultcolor -- default drawing color
    # Optional:
    # linecolor -- hash of node => color for branch to ancestor
    # useBranchLength (default 1)
    # rectangular (default 0)
    # nodeY
    # internaldepth -- hash of leaf => distance up to show as triangle
    # internalsize -- hash of leaf => size
    # text, textcolor, font, -- labels for nodes
    # supportrules -- highlight nodes with high support values with circle fill and/or outlines
    # dropfromroot, dfrfont -- show outgroup dropping down from root (list of [text,color])
    # scalebar -- show scale bar of given length, above topmost leaf, or choose default length
    # Returned hash (not reference) includes nodeX, nodeY, textbounds, bounds
    sub MOTreeDraw {
	my %param = @_;
	my $img = $param{img} || die "No img argument to DrawMOTree";
	my $tree = $param{tree} || die "No tree argument to DrawMOTree";
	my $leafY = $param{leafY} || die "No leafY argument to DrawMOTree";
	my $left = $param{left} || die "No left argument to DrawMOTree";
	my $right = $param{right} || die "No right argument to DrawMOTree";
	my $defaultcolor = $param{defaultcolor} || die "No defaultcolor argument to DrawTree";
	my $useBranchLength = defined $param{useBranchLength} ? $param{useBranchLength} : 1;
	my $rectangular = defined $param{rectangular} ? $param{rectangular} : 0;
	my $font = $param{font} || gdSmallFont;

	my $depthfirst = $tree->depthfirst();
	my $nodeY = {};
	if (exists $param{nodeY}) {
	    $nodeY = $param{nodeY};
	} else {
	    while (my ($leaf,$Y) = each %$leafY) {
		$nodeY->{$leaf} = $Y;
	    }
	    foreach my $node (reverse @$depthfirst) {
		next if $tree->is_Leaf($node);
		my @children = $tree->children($node);
		my $nY = 0;
		my $sumY = 0;
		foreach my $child (@children) {
		    die "Child has no Y-position" unless exists $nodeY->{$child};
		    # weighting the contribution of children to the position
		    # by branch-lengths avoids collisions between lines
		    my $weight = $useBranchLength ? $tree->branch_length($child) : 1;
		    $weight = 1 if !defined $weight;
		    $weight = 0.0001 if $weight < 0.0001;
		    $weight = sqrt($weight);
		    $nY+=$weight;
		    $sumY += $nodeY->{$child} * $weight;
		}
		$nodeY->{$node} = $sumY/$nY;
	    }
	}

	my $nodeX = {};
	if (exists $param{nodeX}) {
	    $nodeX = $param{nodeX};
	} else {
	    $nodeX = $tree->nodeDepth($tree, $useBranchLength);
	    my $maxX = &Vector::max(values %$nodeX);
	    $maxX = 1e-6 if $maxX<1e-6;
	    # scale to canvas
	    while (my ($internal_id,$Y) = each(%$nodeX)) {
		$nodeX->{$internal_id} = $left + $nodeX->{$internal_id}*($right-$left)/$maxX;
	    }
	}

	my $maxY = 0;
	my $minY = 1e8;
	foreach my $y (values %$nodeY) {
	    $maxY = $y if $y > $maxY;
	    $minY = $y if $y < $minY;
	}

	# draw the branches
	my $linecolorhash = $param{linecolor} || {};
	foreach my $node (@$depthfirst) {
	    my $ancestor = $tree->ancestor($node);
	    next unless defined $ancestor;
	    my $xUp = $nodeX->{$ancestor};
	    my $yUp = $nodeY->{$ancestor};
	    my $x = $nodeX->{$node};
	    my $y = $nodeY->{$node};
	    my $color = $linecolorhash->{$node} || $defaultcolor;
	    if ($rectangular) {
		$img->line($xUp,$yUp,$xUp,$y,$color);
		$img->line($xUp,$y,$x,$y,$color);
	    } else {
		$img->line($xUp,$yUp,$x,$y,$color);
	    }
	}
	if (defined $param{internaldepth}) {
	    my $isize = $param{internalsize} || {};
	    while (my ($leaf,$idepth) = each %{ $param{internaldepth} }) {
		my $ancestor = $tree->ancestor($leaf);
		next unless defined $ancestor;
		my $xUp = $nodeX->{$ancestor};
		my $yUp = $nodeY->{$ancestor};
		my $x = $nodeX->{$leaf};
		my $y = $nodeY->{$leaf};
		my $dUp = $tree->branch_length($leaf);
		my $fractionDown = $useBranchLength && defined($dUp) && $dUp > 0.001 ?
		    $idepth/$dUp : 0.5;
		$fractionDown = 1 if $fractionDown > 1;
		$fractionDown = 0 if $fractionDown < 0;
		my $internalX = $xUp + ($x-$xUp)*(1 - $fractionDown);
		my $internalY = $rectangular ? $y : $yUp + ($y-$yUp)*(1 - $fractionDown);

		my $isize = $isize->{$leaf} || 1;
		my $yOff = Vector::min(2+$isize,8);

		my $poly = new GD::Polygon;
		my $poly = new GD::Polygon;
		$poly->addPt($internalX,$internalY-1);
		$poly->addPt($internalX,$internalY+1);
		$poly->addPt($x,$y+$yOff);
		$poly->addPt($x,$y-$yOff);
		$poly->addPt($internalX,$internalY-1);
		my $color = $linecolorhash->{$leaf} || $defaultcolor;
		$img->setAntiAliased($color); # doesn't seem to help much
		$img->filledPolygon($poly,gdAntiAliased);
	    }
	}

	# draw labels
	my $textbounds = {};
	if (defined $param{text}) {
	    my $textcolor = $param{textcolor} || {};
	    my $width = $font->width;
	    my $height = $font->height;
 	    while (my ($node,$text) = each %{ $param{text} }) {
		my $x = int(.5 + $nodeX->{$node} + $width/2);
		my $y = int(.5 + $nodeY->{$node} - $height/2);
		$img->string($font, $x, $y, $text, $textcolor->{$node} || $defaultcolor);
		$textbounds->{$node} = [$x, $y, $x + length($text)*$width+1, $y+$height];
	    }
	}

	# $rules should be a ref to a list of [cutoff,size,fillcolor,outlinecolor], sorted inversely by cutoff
	# (or empty, if you just want to compute the boundaries)
	my $bounds = {};
	my $rules = $param{supportrules} || [];
	my $maxSize = @$rules > 0 ? $rules->[0][1] : 3;
	foreach my $node (@$depthfirst) {
	    my $x = int(0.5 + $nodeX->{$node});
	    my $y = int(0.5 + $nodeY->{$node});
	    if (! $tree->is_Leaf($node)) {
		my $support = $tree->id($node);
		foreach my $rule (@$rules) {
		    my ($cutoff,$size,$fill,$outline) = @$rule;
		    if (defined $support && $support ne "" && $support >= $cutoff) {
			$img->filledEllipse($x,$y,$size,$size,$fill) if defined $fill;
			$img->ellipse($x,$y,$size,$size,$outline) if defined $outline;
			last;
		    }
		}
	    }
	    $bounds->{$node} = [ $x - $maxSize, $y - $maxSize, $x + $maxSize, $y + $maxSize ];
	}

	my $dfrlabels = $param{dropfromroot};
	if (defined $dfrlabels) {
	    my $root = $tree->get_root_node();
	    my $xroot = $nodeX->{$root};
	    my $yroot = $nodeY->{$root};
	    my $xAt = $left-5;
	    $img->line($xroot, $yroot, $xAt, $yroot, $defaultcolor);
	    my $yAt = $maxY + $font->height;
	    $img->setStyle($defaultcolor,$defaultcolor,gdTransparent,gdTransparent);
	    $img->line($xAt, $yroot, $xAt, $yAt, gdStyled);
	    $img->setStyle($defaultcolor);
	    foreach my $row (@$dfrlabels) {
		my ($string,$color) = @$row;
		$img->string($font, $xAt, $yAt, $string, $color);
		$yAt += $font->height;
	    }
	}

	if (defined $param{scalebar}) {
	    my $barXOff = 0.25; # arbitary
	    my $barXLeft = $left + ($right-$left) * $barXOff;
	    my $barYPos = $minY -  3 * $font->height;
	    my $nodeDepth = $tree->nodeElevation();
	    my $maxDepth = $nodeDepth->{$tree->get_root_node()};
	    if ($useBranchLength && $maxDepth >= 0.01) {
		my $scale = $param{scalebar};
		if ($scale eq "default") {
		    my @scales = (0.01,0.05,0.1,0.5);
		    $scale = 0.01;
		    foreach my $value (reverse @scales) {
			if (1.5 * $value < $maxDepth) {
			    $scale = $value;
			    last;
			}
		    }
		}
		my $barXRight = $barXLeft + ($right-$left) * $scale/$maxDepth;
		my $barsideheight = 2;
		$img->line($barXLeft,$barYPos,$barXRight,$barYPos,$defaultcolor);
		$img->line($barXLeft,$barYPos-$barsideheight,$barXLeft,$barYPos+$barsideheight,$defaultcolor);
		$img->line($barXRight,$barYPos-$barsideheight,$barXRight,$barYPos+$barsideheight,$defaultcolor);
		$img->string($font,$barXLeft,$barYPos+$barsideheight,"$scale/site",$defaultcolor);
	    } else {
		$img->string($font,$barXLeft,$barYPos,"Tree not to scale",$defaultcolor);
	    }
	}
	return( nodeX => $nodeX, nodeY => $nodeY, textbounds => $textbounds, bounds => $bounds );
    }
}

1;
