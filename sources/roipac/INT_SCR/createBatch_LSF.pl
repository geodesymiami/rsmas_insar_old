#!/usr/bin/perl
#
# PROGRAM:
# 
# This programs creates the files necessary to submit jobs to 
# a batch server.  
# 
# sbaker Aug 6, 2008
# Nathalie Perlin 5/2015
# F Amelung       5/2015
###########################################

use Env qw(INT_SCR INT_BIN USER HOSTNAME NOTIFICATIONEMAIL QUEUENAME );
use lib "$INT_SCR";  #### Location of Generic.pm
use Getopt::Long;
use Generic;
use POSIX;
#use POSIX ":sys_wait_h";
use File::Basename;
require "UtilLib_RSMAS.pl";
require "Glob.pl";

@args = @ARGV;

$submit=1;
$email=0;
$flag_log=1;

GetOptions('h' => \$help, 'submit!' => \$submit, 'email' => \$email, 'log!' => \$flag_log ) ; 

###Usage info/check
sub Usage{
print STDERR "usage:  createBatch.pl INFILE \n";
print STDERR "\n";
print STDERR "   options: \n" ;
print STDERR "        INFILE           :  File with the commands to run in the batch job (i.e. vex2roi_pac.pl --slcs --azfilt PO_IFGRAM_HawaiiRsatD1_SO_060726-080222_-0033 )\n";
print STDERR "        --email          :  send notification e-mail after completion\n";
print STDERR "        --nosubmit       :  creates sunBatch.sh but jobs are not submitted\n";
print STDERR "\n";
print STDERR "   example:  createBatch.pl  /RAID6/sbaker/SO/HawaiiRsatD1/run_aa \n";
print STDERR "\n";
print STDERR "   The files created are job001.sh, job002.sh,...jobXXX.sh and submitted to the server\n";
print STDERR "\n";
exit 1;
}
$help == 1  and Usage();
@args >= 1 or Usage();
$flag_log and Log("createBatch.pl",@args);

##########################################################################
   &CommandLineArgs2DirsFilesStrings(@ARGV);
   if (@CommandStrings) { &ReadCommandLineArgs(@CommandStrings) }
##########################################################################

$infile              =  $FILES[0];
($infilename, $workDir) = fileparse($infile);
chdir $workDir;
@toks = split(/\//, $workDir);
$projectDir=@toks[$#toks-1];

open(INF,$infile) ;  @i=<INF> ;  close(INF) ;  $number=@i."" ;

$batchScript = "runBatch.sh" ;
@jobs        = () ;
$walltime or $walltime = "7:00";
$projectID or $projectID = "insarlab";
$job_slot_limit or $job_slot_limit = 0;
$pwd = `pwd`; chomp ($pwd);
$NAME = "MyJob";

@toks = split(/_/, $infilename);
if (@toks[0]=='run' and isdigit(@toks[1])){
   $flag_senStack=True;
}

if ($job_slot_limit == 0 ) { 
   $jobArray_flag = 0;
}else{
   $jobArray_flag = 1;
}

#################################################
####### Submit as job array #####################
#################################################
# FA 3/2018: I think this worked, but was never used. Not sure whether it still works after 3/2018 changes
if ($jobArray_flag) {
$num = 0;
@jobs = @i;
foreach $line (@i) {
    $num++;
    open(INPUTPROG,">z_input.$num") ;
      printf INPUTPROG "$line";
   close(INPUTPROG);
}
`chmod +x z_input*`;
print STDERR "Number of job one liners created: $num \n";
print  "bsub -J \"${NAME}[1-$num]%$job_slot_limit\" -o \"z_output.%J.%I.o\" -e \"z_output.%J.%I.e\" -P $projectID -n 2 -q general -W $walltime ./z_input.\\\$LSB_JOBINDEX \n";  # FA 9/2016: need to incorporate memory and other options
system("bsub -J \"${NAME}[1-$num]%$job_slot_limit\" -o \"z_output.%J.%I.o\" -e \"z_output.%J.%I.e\" -P $projectID -n 2 -q general -W $walltime ./z_input.\\\$LSB_JOBINDEX ");
print STDERR "Job array submitted (job_slot_limit=$job_slot_limit): waiting until $#jobs jobs are done of $infilename\n";
}else{                     
#################################################
####### Submit as serial array ##################
#################################################
##### LOOP TO CREATE SCRIPTS FOR EACH JOB #####
#$base=
if ($flag_senStack){
    $namePrefix=$infilename;
    $outPrefix =$infilename;
}else{
    $namePrefix='';
    $outPrefix ='z_output';
}

$count       = 001 ;  $count = sprintf("%03d", $count);
foreach $line (@i) {
    @toks = split(/ /, $line);
    if (@toks[1] =~ "^/"){ 
        $jobfile   = "job$count.sh";
        $NAME      = basename(@toks[1]);      # FA 9/2009: put nothing in z_output string if first field is a long directory path 
      }elsif ($flag_senStack){
        $jobfile   = sprintf("%s_%s.job",$infilename,int($count));
        $NAME      = sprintf("%d", int($count));
      }else{
        $jobfile = "job$count.sh";
        $NAME    = @toks[1];
      }
        print "Writing batch script $jobfile $ID\n";
        for ($NAME) {
                     s/^\s+//;
                     s/\s+$//;
                     }
open(JOBFILE,">$jobfile") ;
                     printf JOBFILE "#! /bin/tcsh\n" ;
                     printf JOBFILE "#BSUB -J ${namePrefix}_$NAME\n" ;
    if ($projectID){ printf JOBFILE "#BSUB -P $projectID\n" ; }
                     printf JOBFILE "#BSUB -n 1\n" ;
                     printf JOBFILE "#BSUB -R span[hosts=1]\n";
                     printf JOBFILE "#BSUB -o ${outPrefix}_${NAME}_%J.o\n" ;
                     printf JOBFILE "#BSUB -e ${outPrefix}_${NAME}_%J.e\n" ;
                     printf JOBFILE "#BSUB -q $QUEUENAME\n" ;
    if ($walltime){  printf JOBFILE "#BSUB -W $walltime\n" ; }
    if ($memory)  {  printf JOBFILE "#BSUB -R rusage[mem=$memory]\n" ; }
                     printf JOBFILE "free\n";
                     printf JOBFILE "cd $workDir\n" ;
                     printf JOBFILE "$line\n";
        close(JOBFILE) ;
        push(@jobs,$jobfile);
        $count++; $count = sprintf("%03d", $count);
        $jobfile = "job$count.sh";
} # End of Loop    
##### DONE PRINTING JOBFILES #####
$submit or die "exiting without submitting jobs....\n";
##### Remove *o and *e files so that they will not be counted in waiting loop #####
`rm ${outPrefix}_*.o` ;
`rm ${outPrefix}_*.e` ;
##### START JOB SUBMISSION #######
$jobnum=scalar(@jobs);
print STDERR "starting job submission, number of jobs = $jobnum\n";
$i=0;

foreach $job (@jobs)  {
  print STDERR "\n";
  $i = $i+1;
  print STDERR "submitting job $i: <$job>\n";
  system("bsub< $job");
  if ( $? == -1 )
  {
    print "Job submission of $job failed, exit value %d\n", $? >> 8;
  }
}
print STDERR "Serial jobs submitted: waiting until $#jobs jobs are done of $infilename\n";
}   # end no jobArray_flag false portion
print STDERR "\n";
##### LOOP WAITING THAT ALL JOBS ARE DONE TO EXIT SCRIPT #######
     $im = 0;
     while ( $#outlist < $#jobs ) {
           @outlist=glob "${outPrefix}_*.o*";      # FA 8/18: instead of counting output files it may be better to capture the jobIDs and look for explicit files
           sleep 1;
           $seconds = $im*1;
           $minutes = $seconds / 60;
           $modsec  = $seconds % 6;   # FA 9/16: was 60
           $modsec  = $seconds % 60;   # FA 9/16: was 60
          ($modsec==0) and  print STDERR "Current # of ${outPrefix}_*.o* files  <$pwd>: <$#outlist> out of <$#jobs> after <$minutes> minutes\n";
           $im++;
              }
      $numjobs = $#jobs + 1;
      print STDERR "ALL $numjobs JOBS ARE DONE OF $infilename\n";

##### check for failures  #######

$infile='run_11_merge_master_slave_slc';
$outPrefix='run_11_merge_master_slave_slc';
@nospaceFailures      = `grep "No space left on device" *.e` ;
@failures             = `grep \"Exited with exit code\" ${outPrefix}_*.o` ;
@exitcode1Failures  = `grep \"Exited with exit code 1.\" ${outPrefix}_*.o` ;
@exitcode2Failures  = `grep \"Exited with exit code 2.\" ${outPrefix}_*.o` ;
@exitcode137Failures  = `grep \"Exited with exit code 137\" ${outPrefix}_*.o` ;
@errno17FileExistsFailures = `grep \"FileExistsError: \\[Errno 17\\] File exists\" ${outPrefix}_*.e` ;
$str=system('grep \"FileExistsError:\" ${outPrefix}_*.e');

$ijobs     = $#outfiles+1;
$ierrno17FileExistsFailures = $#errno17FileExistsFailures + 1;
$inospaceFailures     = $#nospaceFailures+1;
$iexitcode1Failures = $#exitcode1Failures+1 - $ierrno17FileExistsFailures;
$iexitcode2Failures = $#exitcode2Failures+1;
$iexitcode137Failures = $#exitcode137Failures+1;
$iotherFailures = $#failures+1 - $iexitcode1Failures - $iexitcode2Failures - $iexitcode137Failures - $ierrno17FileExistsFailures;

print("ierrno17FileExistsFailures: <$ierrno17FileExistsFailures>\n");
print("iexitcode1Failures: <$iexitcode1Failures>\n");
print("iotherFailures: <$iotherFailures>\n");
##### check for failures  #######
if ($ierrno17FileExistsFailures >= 1)
{ 
 # Fork child process
 my  $pid = fork();
  
 # Check if parent/child process
 if ($pid)
 { # Parent
   print "Started child process id: $pid\n";
 }
 elsif ($pid == 0)
 { # Child
   system('rerun_job_if_FileExistsError.py');
   exit 0;  # It is STRONGLY recommended to exit your child process instead of continuing to run the parent script.
 }
 else
 { # Unable to fork
   die "ERROR: Could not fork new process: $!\n\n";
 }
 print "Waiting for the child process to complete...\n";
 waitpid ($pid, 0);
 print "The child process has finished executing.\n\n";
}
 
 ###############################
 

if ($inospaceFailures > 0 ) {
  $str= "No space left failures: $inospaceFailures $infilename";
  print STDERR "$str\n";
  $call_str = "ssh pegasus.ccs.miami.edu \"echo \"$str\"  | mail -s \"No space failures: $workDir\" $NOTIFICATIONEMAIL \"";
  `$call_str`; Status "mail";
  exit 1;
}
if ($iexitcode137Failures > 0 ) {
  while ( $#exitcode137Failures>=0 )
     {  $failureStr=shift @exitcode137Failures;
        @toks=split(/:/,$failureStr);
        $failureFile=@toks[0];
        $memoryStr = `grep \"Max Swap \" $failureFile` ;
        push @memoryTxt, $memoryStr;
     }
  $str= "Exited jobs from createBatch.pl $projectDir $infilename (exit code 137). Try more memory: \n @memoryTxt";
  open FID, ">.tmp"; print FID $str; close FID;`mv .tmp ~`;

  print STDERR "$str\n";
  $call_str = "ssh pegasus.ccs.miami.edu \"echo \"$str\"  | mail -s \"Exited:_$projectDir\" $NOTIFICATIONEMAIL \"";  #FA 8/2018: needed to write into file as mail command does not work with newlines in $str
  $call_str = "ssh pegasus.ccs.miami.edu \"cat ~/.tmp  | mail -s \"Exited:_$projectDir\" $NOTIFICATIONEMAIL \"";
  print STDERR "$call_str\n";
  `$call_str`; Status "mail";
  exit 1;
}
# FA 8/18: make a loop to capture all exit code in one email
if ($iexitcode2Failures > 0 ) {
  $str= "Exited jobs from createBatch.pl $workDir $infilename: $iexitcode2Failures";
  print STDERR "$str\n";
  $baseInfile=basename($infile);
  $subjectStr=$projectDir.':_'.$baseInfile.':_exit_code_2:_'.$iexitcode2Failures.'jobs__BAD!__';
  $call_str = "ssh pegasus.ccs.miami.edu \"echo \"$str\"  | mail -s \"Exited:_$subjectStr\" $NOTIFICATIONEMAIL \"";
  `$call_str`; Status "mail";
  exit 1;
}
if ($iexitcode1Failures > 0 ) {
  $str= "Exited jobs from createBatch.pl $workDir $infilename: $iexitcode1Failures";
  print STDERR "$str\n";
  $baseInfile=basename($infile);
  $subjectStr=$projectDir.':_'.$baseInfile.':_exit_code_1:_'.$iexitcode1Failures.'jobs';
  $call_str = "ssh pegasus.ccs.miami.edu \"echo \"$str\"  | mail -s \"Exited:_$subjectStr\" $NOTIFICATIONEMAIL \"";
  `$call_str`; Status "mail";
  exit 1;
}
if ($ierrno17FileExistsFailures > 0 ) {
  $str= "Exited jobs from createBatch.pl $workDir $infilename: $ierrno17FileExistsFailures";
  print STDERR "$str\n";
  $baseInfile=basename($infile);
  $subjectStr=$projectDir.':_'.$baseInfile.':_exit_code_1_FileExists_RERUN:_'.$ierrno17FileExistsFailures.'jobs';
  $call_str = "ssh pegasus.ccs.miami.edu \"echo \"$str\"  | mail -s \"Exited:_$subjectStr\" $NOTIFICATIONEMAIL \"";
  `$call_str`; Status "mail";
  exit 1;
}
if ($iotherFailures > 0 ) {
  $str= "Exited jobs from createBatch.pl $workDir $infilename: $iotherFailures";
  print STDERR "$str\n";
  $baseInfile=basename($infile);
  $subjectStr=$projectDir.':_'.$baseInfile.':_exit_code_other:_'.$iotherFailures.'jobs';
  $call_str = "ssh pegasus.ccs.miami.edu \"echo \"$str\"  | mail -s \"Exited:_$subjectStr\" $NOTIFICATIONEMAIL \"";
  `$call_str`; Status "mail";
  exit 1;
}

##### move z_output file in dedicated directory  #######
if (not $flag_senStack) {
$joboutputDir = "${infilename}_joboutput";
MessageStderr "Moving z_output* files into  $pwd/$joboutputDir";
$call_str = "rm -rf $joboutputDir; mkdir $joboutputDir"; `$call_str`;
$call_str = "mv -f z_output* z_input*  job*sh $joboutputDir";        `$call_str >&  /dev/null`;
}
exit 0;
