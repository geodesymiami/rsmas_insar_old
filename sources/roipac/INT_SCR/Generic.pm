#!/usr/bin/perl
#---#!/usr/bin/perl

package   Generic;
require   Exporter;
@ISA    = qw(Exporter);
@EXPORT = qw(ByteRead TrimWhite Log Log0 IOcheck Median Norm Message MessageStderr Prog_name Read_infile Status Status2 Link_here Use_rsc Min);
use Env qw(INT_SCR INT_BIN);

### Usage: ByteRead (infile, bytes_from_start, #bytes_to_read, [1])
### returns #bytes read from a point in the infile
### returns the first string, entering 1 returns all

sub Min {
  $val1 = shift;
  $val2 = shift;
  if($val1 <= $val2) 
	{ return ($val1); }
  else 
	{ return ($val2); }
}

sub ByteRead {
  $infile = shift;
  $start  = shift;
  $bytes  = shift;
  $num    = shift;
  open IN, "$infile" or die "Can't read $infile\n";
  read IN, $junk, $start;
  read IN, $val,  $bytes;
  close IN;
  unless ($num == 1){
    $val =~ s/\s*(\S+).*/$1/;
  }
  return ($val);
}


### Usage: trimWhite (var1, var2, var3 ...)
sub TrimWhite { foreach (@_) { s/^\s*(.*?)\s*$/$1/ if $_; } @_; }

### Usage: Prog_name $0
sub Prog_name {
  $name = $0;
  $name =~ s!.*\/!!g;
  return ($name);
}

### Usage: Message "message"
### prints message to standard error and file log1
sub Message {
  $name = Prog_name $0;
  open LOG1, ">>log1";
  print LOG1 "$name @_\n";
  print STDOUT "+$name @_\n";
  close(LOG1);
}

### Usage: MessageStderr "message"
### prints message to standard error and file log1
sub MessageStderr {
  $name = Prog_name $0;
  open LOG1, ">>log1";
  print LOG1 "$name @_\n";
  print STDERR "+$name @_\n";
  close(LOG1);
}


### Usage: Status "command";
### dies if errors $? are true
sub Status {
  $name = Prog_name $0;
  $command = shift;
  if ($?){ Message "$command failed in $name"; exit 1;}
}

sub Status2 {
  $name = Prog_name $0;
  $command = shift;
  $rc = 0xffff & $? ;
  if (($rc & 0x7f) == 0 ) {
     $rc = 0xff &($rc/256); # byteswap return status
     #$rc = $rc >> 8 ;
  }   
  if ($rc){ Message "$command failed in $name: error status $rc"; exit 1;}
}

### Usage: IOcheck(\@Infiles, \@Outfiles)
### @Infiles and @Outfiles are arrays of file names
### Checks readability of infiles
### Checks age of outfiles against age of youngest infile
### Continues program if even one outfile is old or doesn't exist
sub IOcheck {
  $in  = shift @_;
  $out = shift @_;
  @in  = @$in          or warn "No infiles specified\n";
  @out = @$out         or warn "No outfiles specified\n";
  $age = -M $in[0];
  $youngest_infile=$in[0] ;
  foreach (@in) {
    unless(-r $_){
      if ($_ =~/\.(slc|int|cor|unw|amp|hgt|msk|dem|byt)$/){
	print "checking $_\n";
	if ($_ =~/(.*)_(\d+)rlks(.*)/){
	  @filelist=split /\s+/, `ls ${1}*${3}`;
	  $foundfile='';
	  $origlooks=1;
	  $newlooks=$2;
	  foreach $file (@filelist){
	    #if ($file eq "${1}${3}")	# swk
	    if ($file eq "${1}${3}" and $origlooks == 1){ # swk: 2005/4/21
	      $foundfile=$file;
	    }
	    elsif ($file =~/(.*)_(\d+)rlks(.*)/){
	      if ($2>$origlooks and $newlooks%$2 == 0){
                  $origlooks=$2;
                  $foundfile=$file;
	      }
	    }
	  }
	}
      }
      if ($foundfile){
	$looks=$newlooks/$origlooks;
	print "trying: $INT_SCR/look.pl $foundfile $looks\n";
	`$INT_SCR/look.pl $foundfile $looks`;
	Status "look.pl";
      }
      else {die "$_ does not exist or is not readable\n";}   
    }
    -z $_ and die "$_ has zero size\n";
#    -M $_ < $age and $age = -M $_;  ### Get age of youngest infile
    -M $_ < $age and $age = -M $_ and $youngest_infile=$_ ;  ### Get age of youngest infile
  }
  foreach (@out){
#    if (-e $_){  ### if outfile exists
    if (-e $_ and -s $_){  ### if outfile exists and not zero size # swk, 07/06/2007
      -w $_ or warn "$_ is not writable\n";
      $age2 = -M $_;
#      print STDERR  "age: $age $age2\n"; 
      if ($age2 > $age){  ###checks relative ages
        $name=Prog_name $0 ;
	print STDOUT "$name:  Infile $youngest_infile newer than Outfile $_\n"; # falk's change
	$newfiles++;
      }
    }
    else{
      `touch $_`;
      -w $_ or die "Cannot write to this directory\n";
      print STDOUT "Creating $_\n";
      $newfiles++;
    }
  }
  unless ($newfiles) {
    $name = Prog_name $0;
    print STDOUT "$name already done:  @out exist\n";
    exit 0;
  }
}

### Usage: Log("commandname", @ARGV) 
### @ARGV contains commandline arguments, so Log must be called before
### removing variables from @ARGV

sub Log {
  open (LOG,">>log");
  $date = `date +%Y%m%d:%H%M%S`; ### Example date: 19980121:120505
  chomp $date;                   ### Remove carriage return at end of date
  print LOG "$date * @_\n";      ### Print date * command arguments
  close(LOG);
}
### Usage: Log0("commandname", @ARGV) 
### @ARGV contains commandline arguments, so Log must be called before
### removing variables from @ARGV

sub Log0 {
  open (LOG,">>log0");
  $date = `date +%Y%m%d:%H%M%S`; ### Example date: 19980121:120505
  chomp $date;                   ### Remove carriage return at end of date
  print LOG "$date * @_\n";      ### Print date * command arguments
  close(LOG);
}
### Usage: Log1 "message"
### prints message to file log1
sub Log1 {
  $name = Prog_name $0;
  open LOG1, ">>log1";
  print LOG1 "$name @_\n";
  close(LOG1);
}


### Usage: Norm($var1, $var2...)
sub Norm {
# must initialize $sum EJF 98/11/4
  my $sum=0;
  foreach $var (@_){
    $sum += $var**2;
  }
  $sum = sqrt($sum);
  return $sum;
}

### Usage: Median(\@{sorted array})
sub Median {
  $array = shift @_;
  @array = @$array;
  $j=0;
  foreach (@array){ $j++; }
  $k = int($j/2);
  return($array[$k]);
}

### Usage Link_here "files"
### Links files to current directory
sub Link_here {
  foreach $file1 (@_) {
    if ($file1 =~ /\*/){
      @files = split /\s+/, `ls $file1`;
      foreach $file (@files){
	$name = $file;
	$name =~ s!.*\/!!g; #Remove pathname
	if (-l $name) { printf STDERR "$name already exists, assuming ok\n";}
	else{`ln -fs $file $name`;}
      }
    }
    else{  
      $name = $file1;
      $name =~ s!.*\/!!g; #Remove pathname
      if ( -l $name) { printf STDERR "$name already exists, assuming ok\n";}
      else{`ln -fs $file1 $name`;}
    }
  }
}



#Usage: Use_rsc rsc_prefix read   keyword1 [keyword2] ...
#       Use_rsc rsc_prefix delete keyword1 [keyword2] ...
#       Use_rsc rsc_prefix write  keyword1 value1 [keyword2 value2] ...
#       Use_rsc rsc_prefix merge  rsc_prefix2
#
#Note: task=write will also replace an existing value.
#      task=delete will remove the entire line.
#      task=merge will form the union and dump into file1

sub Use_rsc{
  @args = split /\s+/, shift @_;
  $rscfile1 = shift @args;
  $task     = shift @args;

### Check tasks
  if ($task eq "merge"){
    $rscfile2 = shift @args;
  }
  elsif ($task =~ /^(read|delete|write)$/) {
    $keyword  = shift @args;
    $value    = shift @args;
    $rscfile2 = '';
  }
  else {die "Woops, unknown task <$task> in Use_rsc\n";}
  
  
##### check rscfile format #####
  $rscfile1 =~ /\.rsc$/ or $rscfile1 = "$rscfile1.rsc";
  $rscfile2 =~ /\.rsc$/ or $rscfile2 = "$rscfile2.rsc";
  
##### read keyword value #####
  
  if ($task eq "read") {
    open RSC1, "$rscfile1" or die "Can't read $rscfile1\n";
    $found = 0;
    foreach $line (<RSC1>) {
      if ($line =~ /^$keyword\s+(\S+)/) {  
	$value  = "$1";
	$found  = 1;
	last; #match only first occurence
      }
    } 
    defined $value or print "Keyword $keyword doesn't exist in $rscfile1, returning 0\n";
      return($value);
    close(RSC1) or warn "$0: error in closing file $!\n";
  } 
  
##### delete keyword and value #####
  
  if ($task eq "delete") {
    open RSC1, "$rscfile1"  or die "Can't read $rscfile1\n";    
    open RSC2 , ">temp.rsc" or die "Can't write to temp.rsc\n"; 
    foreach $line (<RSC1>) {
      unless ($line=~/^$keyword(\s+)/) {
	print RSC2 "$line";   
      }
    }
    close(RSC1) or warn "$0: error in closing file $!\n";
    close(RSC2) or warn "$0: error in closing file $!\n";
    rename("temp.rsc",$rscfile1);    
    return(0);
  } 
  
##### write/replace keyword value #####

  if ($task eq "write") {
    $value or $value = 0;
    `touch $rscfile1`;
    open RSC1, "$rscfile1" or die "Can't read $rscfile1\n";   
    open RSC2, ">temp.rsc" or die "Can't write to temp.rsc\n"; 
    $found = 0;
    foreach $line (<RSC1>) {
      $caught = 0;
      $line =~ /^$keyword(\s+)(\S*)/ and $caught = 1; 
      if ($caught){
	printf RSC2 "%-40s %-30s\n",$keyword,$value;   
	$found = 1;
      }
      else{
	print RSC2 $line;
      }
    }
    unless ($found) {
      printf RSC2 "%-40s %-30s\n",$keyword,$value;   
    }
    rename("temp.rsc",$rscfile1);
    close(RSC1) or warn "$0: error in closing file $!\n";
    close(RSC2) or warn "$0: error in closing file $!\n";  
    return(0);
  }
  
##### merge rsc files, first file has precedence #####

  if ($task eq "merge") {
    open RSC1, "$rscfile1" or die "Can't read $rscfile1\n"; 
    open RSC2, "$rscfile2" or die "Can't read $rscfile2\n";
    @rsc1 = <RSC1>;
    @rsc2 = <RSC2>;
    close(RSC1) or warn "$0: error in closing file $!\n";
    open RSC1, ">>$rscfile1" or die "Can't write to $rscfile1\n";
    $found = 0;
    
    foreach $line2 (@rsc2) {
      ($keyword2,$value) = split(" ",$line2,2);
      $found = 0;
      
      foreach $line (@rsc1) {
	($keyword,$value) = split(" ",$line,2);
	if ($keyword eq $keyword2) { 
	  $found = 1;
	  last;
	}       
      } 
      unless ($found) {
	print RSC1 "$line2";   
      }
    }
    close(RSC1) or warn "$0: error in closing file $!\n";
    close(RSC2) or warn "$0: error in closing file $!\n";
    return(0);
  }
}

sub IsBigEndianComputer{

	#This routine detects if it is running on a Big_Endian computer.
	#This information should be saved in the resource file of any binary output products.

	my $a = 23;
	return( 1 ) if unpack( "n", pack( "S", $a )) == $a;
	return( 0 );
}
