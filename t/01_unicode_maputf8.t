#!/usr/bin/perl -w

use strict;
use lib ('./blib','../blib','../lib','./lib');
use Unicode::MapUTF8 qw(utf8_supported_charset to_utf8 from_utf8);

# General info for writing test modules: 
#
# When running as 'make test' the default
# working directory is the one _above_ the 
# 't/' directory. 

my @do_tests=(1..4);

my $test_subs = { 
       1 => { -code => \&test1, -desc => ' eight-bit                 ' },
       2 => { -code => \&test2, -desc => ' unicode                   ' },
       3 => { -code => \&test3, -desc => ' multi-byte                ' },
       4 => { -code => \&test4, -desc => ' jcode                     ' },
};
print $do_tests[0],'..',$do_tests[$#do_tests],"\n";
print STDERR "\n";
my $n_failures = 0;
foreach my $test (@do_tests) {
	my $sub  = $test_subs->{$test}->{-code};
	my $desc = $test_subs->{$test}->{-desc};
	my $failure = '';
	eval { $failure = &$sub; };
	if ($@) {
		$failure = $@;
	}
	if ($failure ne '') {
		chomp $failure;
		print "not ok $test\n";
		print STDERR "    $desc - $failure\n";
		$n_failures++;
	} else {
		print "ok $test\n";
		print STDERR "    $desc - ok\n";

	}
}
print "END\n";
exit;

########################################
# Eight bit conversions                #
########################################
sub test1 {
    my $charset       = 'ISO-8859-1';
    my $source_string = 'Hello World';
    my $utf8_string   = 'Hello World';
    my $result = test_general({ -charset => $charset,
                                 -source => $source_string,
                                   -utf8 => $utf8_string,
                             });
    return $result if ($result ne '');

    $source_string = '';
    $utf8_string    = '';
    $result = test_general({ -charset => $charset,
                              -source => $source_string,
                                -utf8 => $utf8_string,
                             });
    return $result if ($result ne '');
}

########################################
# Unicode conversions                  #
########################################

sub test2 {
    my $charset       = 'UCS2';
    my $source_string = "\x00H\x00e\x00l\x00l\x00o\x00 \x00W\x00o\x00r\x00l\x00d";
    my $utf8_string   = 'Hello World';
    my $result = test_general({ -charset => $charset,
                                 -source => $source_string,
                                   -utf8 => $utf8_string,
                             });
    return $result if ($result ne '');

    $source_string = '';
    $utf8_string    = '';
    $result = test_general({ -charset => $charset,
                              -source => $source_string,
                                -utf8 => $utf8_string,
            });
    return $result if ($result ne '');
}

########################################
# Multibyte conversions                #
########################################
sub test3 {
    return '';
}

########################################
# Japanese (Jcode) conversions         #
########################################
sub test4 {
    return '';
}

########################################
# Generalized test framework           #
########################################

sub test_general {
    my ($parms) = shift;
    my $source_charset = $parms->{-charset};
    my $source_string  = $parms->{-source};
    my $utf8_string    = $parms->{-utf8};

	eval { 
        my $result_string = to_utf8({ -string => $source_string, 
                                     -charset => $source_charset });
        if ($utf8_string ne $result_string) {
           die ('(line ' . __LINE__ . ") conversion from '$source_charset' to UTF8 resulted in unexpected output. Expected '" . hexout($utf8_string) . "' but got '" . hexout($result_string) . "'\n");
        }
    };
	if ($@) { return "Failed to convert UTF8 text to $source_charset: $@" }
	eval { 
        my $result_string = from_utf8({ '-string' => $utf8_string, 
                                       '-charset' => $source_charset,
                                       }); 
        if ($source_string ne $result_string) {
           die ("conversion from UTF8 to '$source_charset' resulted in unexpected output. Expected '" . hexout($source_string) . "' but got '" . hexout($result_string) . "'\n");
        }
    };
	if ($@) { return "Failed to convert '$source_charset' text to UTF8: $@" }


	eval { 
           my $result_string = from_utf8({ -string => $source_string, 
                                          -charset => $source_charset,
                                          }); 
           if ($source_string ne to_utf8({ -string => $result_string, 
                                          -charset => $source_charset })) {
                die ("input and output strings differed");
           }     
    };
	if ($@) { return "Round trip conversion of '$source_charset' to UTF8 failed: $@" }

    return '';
}

sub hexout {
    my ($string) = @_;
    $string =~ s/([\x00-\xff])/unpack("H",$1).unpack("h",$1)/egos;
    return $string;
}
