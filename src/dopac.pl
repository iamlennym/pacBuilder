#!/usr/bin/env perl

@files = `ls *.txt`;
foreach $f (@files) {
	chomp($f);
	$t = $f;
	$t =~ s/txt/pac/g;
	system ("./pacbuilder.pl '$f' > 'pacfiles/$t'");
}
