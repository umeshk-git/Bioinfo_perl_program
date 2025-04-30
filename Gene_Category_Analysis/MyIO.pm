package MyIO;

use warnings;
use strict;
use Exporter 'import';

our @EXPORT_OK = qw(getFh);
sub getFh {
    my ($action , $fileName) = @_;
	my $file;
    if ($action eq "<" || ">") {
    open($file, $action , $fileName) or die "Can not open the $file file $!\n";
    return $file;
    }
}
1;