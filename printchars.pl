#!/usr/bin/perl

while(<>) {
	@vals = split("",$_);
	foreach(@vals) {
		print ord($_) . " ";
	}
}
