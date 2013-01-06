#!perl

use strict;
use warnings;

my $header_file = shift;
my $table_file  = shift;
my $outfile     = 'IO-Mapped-Memory-Address-Table.md';

open my $fh, "< $header_file" or die "$!:$header_file";
my $out = join '', <$fh>;
close $fh;
$out .=
    qq{<table border="1">\n}
  . qq{<tr><th colspan="4">MAGUKARA - IO Mapped memory address table</th></tr>\n}
  . qq{<tr><th>Address</th><th>Permission</th><th>Port</th><th></th></tr>\n}
;

open my $fh2, "< $table_file" or die "$!:$table_file";
foreach my $line (<$fh2>) {
  chomp $line;
  $out .= '<tr><td>';
  $line =~ s/,/<\/td><td>/g;
  $out .= $line;
  $out .= qq{</td></tr>\n};
}
$out .= qq{</table>\n\n};
close $fh2;

open my $fh3, "> $outfile" or die "$!:$outfile";
print $fh3 $out;
close $fh3;

exit 0;

