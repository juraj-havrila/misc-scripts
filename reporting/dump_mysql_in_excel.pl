#!/usr/bin/perl
#Simple script for dumping MySQL DB tables to MS-Excel Document
#All tables (or views) from the Database which contain the word "REPORT" in their name are written in separate Workbooks of an Excel file
# TO-DO: Column width adjustment (at the moment is fixed)
# Free to use or change by anyone at the same conditions like Perl itself
#Juraj Havrila, 8/2017

use strict;
use warnings;
use DBI;
use DBD::mysql;
use Excel::Writer::XLSX;
use Encode;
#use utf8;

use Data::Dumper;
use File::Path;
use File::Copy;
use Cwd 'abs_path';

my $target_path='/wwws/WT/data/reports';
my $database='wtdb';

&generate_report;

sub generate_report{

my $dsn = "DBI:mysql:" .
          ";mysql_read_default_group=wtdb_ro" .
          ";mysql_read_default_file=/wwws/WT/conf/mysql_group.cfg";
my $dbh = DBI->connect($dsn, undef, undef, {
    PrintError => 0,
    RaiseError => 1
});
$dbh->{'mysql_enable_utf8'} = 1;


my $sth = $dbh->prepare("SHOW tables from $database");
$sth->execute();
my @all_tables=@{$sth->fetchall_arrayref()};
$sth->finish();

my $today=`date +%Y-%m-%d`;
chomp($today);

my $workbook = Excel::Writer::XLSX->new( "$target_path/REPORT_$database\_$today.xlsx" );

foreach my $pom (@all_tables){
    my $db_table = "@$pom";
    if (index($db_table, 'REPORT') != -1) {
        my $worksheet = $workbook->add_worksheet("$db_table");
        $sth = $dbh->prepare("SELECT * from `$db_table`");
        $sth->execute();
        my $fields = $sth->{NAME};
        my @my_table=@{$sth->fetchall_arrayref()};

        $worksheet->write_row( 0, 0, $fields );
        $worksheet->write_col( 1, 0, \@my_table );
        $sth->finish();
        $worksheet->freeze_panes( 1, 0 );
        #$worksheet->autofilter(0,0);
    }
}
$dbh->disconnect();
unlink("$target_path/NEW_REPORT_wtdb.xlsx");
symlink ("$target_path/REPORT_$database\_$today.xlsx","$target_path/NEW_REPORT_wtdb.xlsx");
}

