#!/usr/bin/env perl

use Data::Validate::IP;
use Net::Netmask;

my $validator=Data::Validate::IP->new;
my $template = "/pacBuilder/templates/custom_template.pac";
@templateLines = `cat $template`;

sub match_ip
{
	my $ip = $_[0];
	# if($ip =~ /(\d{1-3}\.\d{1-3}\.\d{1-3}\.\d{1-3}\:\d{1-5})/)
	# if($ip =~ /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\)/) {
	#$ip =~ /[0-9]{1,3}\./
	if( ($ip =~ /\d{1,3}\./) && ($ip !~ /[A-Za-z]/) ) {
		#	if (validator.
		if($validator->is_ipv4($ip)) {
			return (1);
		} else {
			return (2);
		}
	} else {
		return (0);
	}
}

if ($#ARGV == -1) {
	printf ("Usage:\n\n");
	printf ("\t$0 <Input file>\n\n");
	exit(-1);
}

@FL = ();
if ( open (IF, "<$ARGV[0]")) {
	@FL=<IF>;
	close (IF);
} else {
	printf ("Could not open input file for reading...\n");
	exit(-1);
}

foreach $L (@FL) {
	$L =~ s/ //g;
	@Lines = split(/\;/, $L);
	foreach $E (@Lines) {
		# printf ("XX ---> [%s]\n", $E);
		chomp($E);
		my $whatAmI = match_ip($E);
		if ($whatAmI == 1) {
			push (@IP, $E);
		} elsif ($whatAmI == 2) {
			my @tok = split (/,/,$E);
			foreach $t (@tok) {
				$t =~ s/ //g;
				$t =~ s/\?//g;
				push (@SubNets, $t);
			}
			# 	push (@SubNets, $E);
		} else {
			push (@Entries, $E);
		}
	}
}

if ($DEBUG) {
	printf ("IP Entries...\n");
	@IP = sort @IP;
	foreach $e (@IP) {
		printf ("%s\n", $e);
	}

	printf ("Subnet Entries...\n");
	@SubNets = sort @SubNets;
	foreach $e (@SubNets) {
		printf ("%s\n", $e);
	}

	printf ("\n\nDomain Entries...\n");
	@Entries = sort @Entries;
	foreach $e (@Entries) {
		printf ("%s\n", $e);
	}
}

foreach $tl (@templateLines) {
	chomp($tl);

	if ($tl =~ /XXX_INDIVIDUAL_IP_EXCLUSIONS_XXX/) {
		if ($#IP > 0) {
			@IP = sort @IP;
			my $idx = 0;
			for ($idx=0; $idx<$#IP-1; $idx++) {
				if ($idx == 0) {
					printf ("\tif ( isInNet(resolved_ip, \"%s\", \"255.255.255.255\") ||\n", $IP[$idx]);
				} else {
					printf ("\t\tisInNet(resolved_ip, \"%s\", \"255.255.255.255\") ||\n", $IP[$idx]);
				}
			}
			printf ("\t\tisInNet(resolved_ip, \"%s\", \"255.255.255.255\") )\n", $IP[$idx]);
			printf ("\t\treturn \"DIRECT\";\n\n");
			next;
		}
	}
	# XXX_IP_RANGE_EXCLUSIONS_XXX
	if ($tl =~ /XXX_IP_RANGE_EXCLUSIONS_XXX/) {
		if ($#SubNets > 0) {
			@SubNets = sort @SubNets;
			my $idx = 0;
			for ($idx=0; $idx<$#SubNets-1; $idx++) {
				$s = $SubNets[$idx];
				$s =~ s/\.\*//g;
				$s =~ s/\*//g;
				my $block = Net::Netmask->safe_new($s, shortnet => 1);
				if (!$block) {
					printf ("XXXXXXXXXX : [%s]\n", $s);
				}

				if ($idx == 0) {
					printf ("\tif ( isInNet(resolved_ip, \"%s\", \"%s\") ||\n", $block->base, $block->mask);
				} else {
					printf ("\t\tisInNet(resolved_ip, \"%s\", \"%s\") ||\n", $block->base, $block->mask);
				}
			}
			$s = $SubNets[$idx];
			$s =~ s/\.\*//g;
			$s =~ s/\*//g;
			my $block = Net::Netmask->safe_new($s, shortnet => 1);
			printf ("\t\tisInNet(resolved_ip, \"%s\", \"%s\") )\n", $block->base, $block->mask);
			printf ("\t\treturn \"DIRECT\";\n\n");
			next;
		}
	}

	if ($tl =~ /XXX_DOMAIN_HOST_EXCLUSIONS_XXX/) {
		if ($#Entries > 0) {
			@Entries = sort @Entries;
			my $idx = 0;
			for ($idx=0; $idx<$#Entries-1; $idx++) {
				if ($idx == 0) {
					printf ("\tif ( isPlainHostName(host) || \n");
					printf ("\t\tshExpMatch(host, \"%s\") ||\n", $Entries[$idx]);
				} else {
					printf ("\t\tshExpMatch(host, \"%s\") ||\n", $Entries[$idx]);
				}
			}
			printf ("\t\tshExpMatch(host, \"%s\") )\n", $Entries[$idx]);
			printf ("\t\treturn \"DIRECT\";\n\n");
			next;
		}
	}

	if ($tl =~ /XXX_PAC_BUILDER_XXX/) {
		my $TIMESTAMP = localtime();
        $tl =~ s/XXX_PAC_BUILDER_XXX/This PAC file was generated from $ARGV[0] on $TIMESTAMP./g;
		# $tl =~ s/XXX_PAC_BUILDER_XXX/This PAC file was generated from $ARGV[0]./g;
	}

	printf ("%s\n", $tl);
}

