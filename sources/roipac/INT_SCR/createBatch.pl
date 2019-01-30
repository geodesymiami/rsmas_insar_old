#!/usr/bin/perl
#
# Wrapper to call createBatch_LSF.pl or createBatch_PBS.pl
# 
# FA 1/2016
###########################################
use Env qw(JOBSCHEDULER);

$call_str="createBatch_$JOBSCHEDULER.pl @ARGV"; 
`$call_str`;
print $call_str;
#print STDERR "command: <$call_str>\n";
exit 0;
