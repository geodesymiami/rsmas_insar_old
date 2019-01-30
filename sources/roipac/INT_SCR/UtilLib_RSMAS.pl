#!/usr/bin/perl  
### UtilLib_RSMAS.pl
use Env qw(INT_SCR INT_BIN USER INSARLABHOME DEMDIR QUEUENAME);
use Env qw(L0DIR_ALOS L0DIR_ENV L0DIR_ERS L0DIR_JERS L0DIR_RSAT L0DIR_TSX L0DIR_RSAT2 GAMMA_BIN);
use lib "$INT_SCR";  #### Location of Generic.pm
use Getopt::Long;
use Generic;
use File::Find;
use File::Basename;
use List::Util qw/ min max /;
use Cwd;
use Switch 'perl6' ;
sub Use_gamma;

#######################################################
#######################################################
#    ReadProcfile      ---  subroutine to read roi_pac parameter files
#    usage:    &ReadProcfile($procfile);
#
#    FA 3/2009: Added understanding of comments (denoted by "#" and "%").
#               Values given by  [ 070801 080115 ]  or  070801:080115
#               are tranfered into an arrary. The example below will return
#               <$masterPeriod>=<070801 080115>  and
#               <@masterPeriod>=<070801 080115> 
#               Environment variabl can be first field of value.
#    
# temporalBaseMax    = 10.0                            # maximum temporal baseline
# masterPeriod       = [ 070801 080115 ]               # period of master image
# excludeList        = [ 040114:060215 ]   % Snow
# DEM                = $INSARLABHOME/testdata/DEM/hawaii_filled_0.00056.dem
#
#######################################################
sub ReadProcfile{
$templatefile = shift ;
open IN, "$templatefile" or die "Can't read $templatefile\n";
  while (chomp($line = <IN>)){
    $line =~ /=/ or next;
    #$line =~ s/\s//g;                                                  # the would not allow for --KeepSBASgeo --remove on the right side
    $line =~ s/^\s+|\s+$//go ;                                          # remove leading and trailing white spaces   #Jan 2005
    #($keyname, $value) = split /=/, $line;                             # FA 7/2015: aloow for second or more = in string (ssaraopt)
    ($keyname, $value) = split( /=/, $line, 2);
    #$line =~ /ssaraopt/ and die "QQ:<$line>\n keyname,value:<$keyname><$value>\n";

               $keyname      =~ s/^\s+|\s+$//go ;                       # remove leading and trailing white spaces   #Sep 2007
               $keyname      =~ /^#|^%/  and next;                      # FA 3/2009 Skip lines (keywords) starting with "#" or "%"
               ($value,$junk)=  split /#|%/, $value;                    # FA 3/2009  Removes comments (text following "#" or "%")   
               $value        =~ s/^\s+|\s+$//go ;                       # remove leading and trailing white spaces   #Sep 2007
               $value        =~ s/^\[//go ;  $value=~ s/$\]//go; $value=~ s/^\s+|\s+$//go;  # FA 3/2009  removes leading and trailing square brackets ("[" and "]") and then the white spaces
               $value        =~ /:/    and  @value=split /:/, $value; ; # FA 3/2009  splits according to ":" and assign to array
               $value        =~ / /    and  @value=split / /, $value; ; # FA 3/2009  splits according to " " and assign to array
               $value        =~ /,/    and  @value=split /,/, $value; ; # FA 5/2009  splits according to "," and assign to array (Scott's boundingBox convention)

                           if ($value  =~ /^\$/) { @toks = split /\//, $value;                  # FA 3/2009: This codes interpretes an environment
                                                   $str1 = substr(@toks[0],1,length(@toks[0])); # variable at the beginning of value
                                                   $str2 = $ENV{"$str1"};                       # e.g. DEM=$INSARLABHOME/testdata/roi_pac/RSAT_vexint/DEM/hawaii_filled_0.00056.dem
                                                   shift @toks;
                                                   #die "Error: incorrect usage -- exiting: $value \nenvironment variables are no longer supported in template file\n";
                                                   $value = join('/',$str2,@toks);}
               $$keyname = $value;
               if (@value) {@$keyname = @value;} 
               #printf STDERR "keyname,value: <$keyname><$value><@value><$#value>\n";
               undef @value;
  }
close(IN);

#print "<$source><@source>\n";
#die   "<$excludeList><@excludeList>\n";
}
#######################################################
#######################################################
#    ReadCommandLineArgs      ---  subroutine to read roi_pac parameter from command line arguments
#    usage:    &ReadCommandLineArgs(@args);
#######################################################
sub ReadCommandLineArgs{
  while ($#args>-1){
    $argument = shift @args;
    $argument =~ /=/ or next;
    $argument =~ s/^\s+|\s+$//go ;               # remove leading and trailing white spaces   #Jan 2005
    ($keyname, $value) = split /=/, $argument;
                    # printf STDERR "keyname,value: <$keyname><$value>\n";
               $keyname =~ s/^\s+|\s+$//go ; # remove leading and trailing white spaces   #Sep 2007
               $value =~ s/^\s+|\s+$//go ;   # remove leading and trailing white spaces   #Sep 2007
                    # printf STDERR "keyname,value: <$keyname><$value>\n";
    $$keyname = $value;
  }
}
#######################################################
#######################################################
#    ReadParfile      ---  subroutine to read vexcel parameter files
#    usage:    &ReadParfile($Raw_parfile , 'Raw_');
#    with Raw the prefix
#######################################################
sub ReadParfile{
$par_file=shift ;
$prefix  =shift ;
open IN, "$par_file" or die "Can't read $par_file\n";
$ilev=-1 ;
  while (chomp($line = <IN>)){
    $line =~ /:/ or $line =~ /{/ or $line =~ /}/ or next;
          #$line =~ s/\s\s//g; ###Remove all whitespace
          $line =~ s/^\s+|\s+$//go ;   # remove leading and trailing white spaces
    $line =~ s/\s+/ /g ;   #            # remove multiple white spaces

    $line =~ /{/  and push @lev,  split /{/, $line;                            # }
    $line =~ /}/  and pop  @lev ;
    $line  =~ /:/ and    ($keyname,$values) = split /:/, $line;
                     $values =~ s/^\s+|\s+$//go  ; @value=split / /,$values ;   #remove leading and trailing white spaces and split into words
    $varname="$prefix @lev $keyname";
             $varname =~ s/\s//g; ###Remove all whitespace
    @$varname=@value ;
    #$line =~ /:/ and print STDERR "$varname  @$varname \n" ;
                             }
close IN ;
}
##########################################################################
##########################################################################
#    CommandLineArgs2FilesDirsStrings   - process command line args. Returns
#    Returns @Files, @DIRS, @STRINGS, @CommandSTRINGS, $templatefile, $procfile 
#    usage:    &CommandLineArgs2DirsFilesStrings(@args);
#######################################################
sub CommandLineArgs2DirsFilesStrings {
   foreach $_ (@_) { if (/\.template$/) {$templatefile = $_       }else{ push @tmp,$_ } } ; @_=@tmp; undef @tmp;
   foreach $_ (@_) { if (/\.proc$/)     {$procfile     = $_       }else{ push @tmp,$_ } } ; @_=@tmp; undef @tmp;
   foreach $_ (@_) { if (/=/)           {push @CommandStrings, $_ }else{ push @tmp,$_ } } ; @_=@tmp; undef @tmp;
   foreach $_ (@_) { if (-d $_) {push @DIRS,$_} elsif (-f $_) {push @FILES,$_} else {push @STRINGS,$_} }
  if ($templatefile) {(-f $templatefile ) or die "$templatefile: $!\n" };
  if ($templatefile) { ($templatebasename,$templatepath,$ext) = fileparse($templatefile,qr{\.template})};
  #die "TEMPLATE:<$templatefile> PROC:<$procfile> COMMANDS: <@CommandStrings> DIRS:<@DIRS> FILES:<@FILES> STRINGS:<@STRINGS>\n";
}
##########################################################################
##########################################################################
#    DefaultOptions   - process keywords to make sure that conventions are followed and set default keywords
#    usage:    &DefaultOptions;
#######################################################
sub DefaultOptions {

  ( $package, $filename, $line ) = caller;
  $calling_function = basename($filename);
  #print STDERR "QQQQQQ<$package><$filename><$line><$calling_function>\n";
  #Message "calling_function:<$calling_function> sarDataGroup: <$sarDataGroup> OrbitType:<$OrbitType>\n";

  if ( $sarDataGroup     )    { $templatebasename = $templatebasename . $sarDataGroup }
  if ( $templatebasename )    { ($tmp_projectName,$tmp_regionName,$tmp_satellite,$tmp_beam,$tmp_track,$tmp_startFrame,$tmp_endFrame)=extractProjectName("$templatebasename") }
  #die "<$templatebasename><$startFrame><$tmp_startFrame><$sarDataGroup>\n";
  #die "<$templatebasename><$tmp_satellite>\n";

  $cwd                                      = getcwd();    
################### HANDLE BOTH UPPERCASE AND LOWERCASE INPUT ARGUMENTS #######################
  $satellite = lc($satellite) ; $satellite = ucfirst($satellite) ; # Make only first letter of satellite uppercase 
  $source = uc($source) ;
  if ($satellite eq "Alos")               { $source    = "ASF" ;  } # Make the source ASF if the satellite is Alos
  if ($source eq "ASF" )                  { $satellite = "Alos";  } # Make the satellite Alos if the source is ASF
  #if ($source eq "ASF_J" )                  { $satellite = "Jers";  } # Make the satellite Alos if the source is ASF      9/15 Sang-Hoon
  if ($satellite eq "Envisat")            { $satellite = "Env" ;  } # Make satellite Env if Envisat
 #if ($satellite eq "Ers" && !$source)    { $source    = "WINSAR";} # Make WINSAR default for Ers
  if ($source eq "WINSAR" && !$satellite) { $satellite = "Env";   } # Make Env default for WINSAR
  if ($source eq "ESA"    && !$satellite) { $satellite = "Env";   } # Make Env default for ESA
  if ($satellite eq "Alos2")               { $source    = "JAXA" ;  } # Make the source JAXA if the satellite is Alos2   # 9/15 Sang-Hoon
  if ($source eq "JAXA" )                  { $satellite = "Alos2";  } # Make the satellite Alos2 if the source is JAXA   # 9/15 Sang-Hoon
  if ($url)                               { $source = "URL";      }

#if ($list) { $source = "ASF" ; $satellite = "Alos" ; }

  if ( !$processor )  { $processor = "ROI_PAC"}

  ################### CREATE DIRECTORIES FOR DOWNLOADING, L0DATA, SLC AND PROCESSING ######### 
  $DownloadDir                               = "$L0DOWNLOADDIR/$source";   
  if (defined $WorkDir)       { $DownloadDir = "$WorkDir/download/$source"    }
  if (defined $local)         { $DownloadDir = "$cwd/download/$source"        }

  if ($satellite eq "Alos")   { $L0Dir       =  ${"L0DIR_ALOS"}               }            
  if ($satellite eq "Env")    { $L0Dir       =  ${"L0DIR_ENV"}                }
  if ($satellite eq "Ers")    { $L0Dir       =  ${"L0DIR_ERS"}                }
  if ($satellite eq "Tsx")    { $L0Dir       =  ${"L0DIR_TSX"}                }
  if ($satellite eq "Csk")    { $L0Dir       =  ${"L0DIR_CSK"}                }  
  if ($satellite eq "Rsat")   { $L0Dir       =  ${"L0DIR_RSAT"}               }  
  if ($satellite eq "Rsat2")  { $L0Dir       =  ${"L0DIR_RSAT2"}              }  
  if (defined $WorkDir)       { $L0Dir       = "$WorkDir/L0data/$satellite"   }
  if (defined $local)         { $L0Dir       = "$cwd/L0data/$satellite"       }

  if (defined $WorkDir)       { $moveL0opt   = "WorkDir=$WorkDir"             }
  if (defined $local)         { $moveL0opt   = "WorkDir=$cwd"                 }

  if ( !$SLCDir       )       { $SLCDir      = "$SLCDIR"                      }
  if (defined $WorkDir)       { $SLCDir      = "$WorkDir/SLC"                 }
  if (defined $local  )       { $SLCDir      = "$cwd/SLC"                     }
  if ( !$ProcessDir   )       { $ProcessDir  = "$PROCESSDIR"                  }
  if (defined $WorkDir)       { $ProcessDir  = "$WorkDir/process"             }
  if (defined $local  )       { $ProcessDir  = "$cwd/process"                 }

  if (defined $WorkDir && !$DEM ) { $DEMDIR  = "$WorkDir/ROIPAC_DEMS"                 }
  if ( $local && !$DEM          ) { $cwd     = getcwd();   $DEMDIR ="$cwd/ROIPAC_DEMS"} 

  if ( !$projectName )        { $projectName            = $tmp_projectName}
  if ( !$satellite )          { $satellite              = $tmp_satellite  }
  if ( !$beam )               { $beam                   = $tmp_beam       }
  if ( !$regionName )         { $regionName             = $tmp_regionName }
  if ( !$track )              { $track                  = $tmp_track      }
  if ( !$startFrame )         { $startFrame             = $tmp_startFrame }
  if ( !$endFrame )           { $endFrame               = $tmp_endFrame   }

  if ($satellite eq "Tsx")    { }
  elsif ($satellite eq "Csk") { } 
  elsif ($satellite eq "Rsat") { } 
  elsif ($satellite eq "Rsat2") { } 
  else {
    if (  $track)               { $track                  =  sprintf("%03d",$track*1)   }                     # FA 5/2009: maskes sure there is a leading zero (don't know why different before) # converts string to number (e.g. track=079 -> track=79)
  }

  if ( !$demPosting )         { $demPosting             = 30              }
  if ( !$demType )            { $demType                = srtm3           }

  if (  @masterPeriod)        { $startDate              = @masterPeriod[0]    }
  if (  @slavePeriod)         { $endDate                = @slavePeriod[1]     }
  if ( !$startDate)           { $startDate              = "920101"            }
  if ( !$endDate)             { $endDate                = "200101"            }
  if ( ! defined $cleanopt)   { $cleanopt               = 2                   }

  if (  $interferogramList)   { undef @acquisitionList; undef @tmpacquisitionList;
                                if (@interferogramList ==0)    {push @interferogramList, $interferogramList }  # put into array if only one interferogram is given
                                foreach $_ ( @interferogramList )     { @toks=split(/-/,$_) ; push @acquisitionList, @toks; }
                                foreach $_ ( @acquisitionList   )     { if ($_ > 900000 )  {push @tmpacquisitionList, $_ + 19000000} else {push @tmpacquisitionList, $_ + 20000000} }
                                             @acquisitionList = sort @tmpacquisitionList; 
                                             $startDate = @acquisitionList[0]; 
                                             $endDate   = @acquisitionList[$#acquisitionList] ;
                                             $startDate = substr($startDate,2,6) ; $endDate = substr($endDate,2,6) ;  # converts YYYYMMDD to YYMMDD
					             print "acquisitionList: <@acquisitionList>, startDate: <$startDate> endDate:<$endDate>\n";
                              }

  if ( $raw2slc_OrbitType && !$OrbitType ) { $OrbitType = "HDR" }                          # FA 5/2009 Maybe we want to force $OrbitType=HDR
#  if ( $masterSLCdate )                    { $clean = "--KeepSBASradar" }                  # FA 9/2009 Maybe we want to force $OrbitType=HDR
  if ( $satellite  =~ /Env|Alos|Alos2|Tsx|Csk|Rsat2/ )     { $azfiltstr = undef; $azfilt=undef; }         # switches off azimuth filtering for Envisat and Alos (default is --azfilt)

#  if ( ! $walltimePrepare)                 { $walltimePrepare     = "0:15" }
  if ( ! $walltimePrepare)                 { $walltimePrepare     = "1:00" }   # to consider big file such as Sentinel or Alos-2. should test more.
#  if ( ! $walltimePrepare)                 { $walltimePrepare     = "0:45" }
  if ( ! $walltimeSlc)                     { $walltimeSlc         = "2:00" }
  if ( ! $walltimeProcessFilt)             { $walltimeProcessFilt = "2:00"}
#  if ( ! $walltimeCoregist)                { $walltimeCoregist    = "0:10" }
  if ( ! $walltimeCoregist)                { $walltimeCoregist    = "1:00" }
  if ( ! $walltimeProcessDone)             { $walltimeProcessDone = "3:00"}
  if ( ! $walltimePysar)                   { $walltimePysar     = "18:00"}
  if ( ! $walltimeInsarmaps)               { $walltimeInsarmaps = "18:00"}

  if ( ! $job_slot_limitPrepare)          { $job_slot_limitPrepare= 6 }

  if ( $QUEUENAME eq "debug" )             { $walltimeProcessFilt = "0:30"}
  if ( $QUEUENAME eq "debug" )             { $walltimeProcessDone = "0:30"}

  if ( ! $memoryProcessFilt)               { $memoryProcessFilt   = 1600 }
  if ( ! $memoryCoregistSLC)               { $memoryCoregistSLC   = 3700 }
  if ( ! $memoryCoregist   )               { $memoryCoregist      = 1600 }
  if ( ! $memoryProcessDone)               { $memoryProcessDone   = 1600 }

  $tmp_projectName = $tmp_satellite = $tmp_beam = $tmp_regionName = $tmp_track = $tmp_startFrame = $tmp_endFrame = undef;
  #MessageStderr "$calling_function  DefaultOptions: DownloadDir:<$DownloadDir> L0Dir: <$L0Dir> SLCDir:<$SLCDir> track:<$track> ProcessDir: <$ProcessDir>";
  if ($calling_function eq "getSAR.pl" ) { return ; }

}
##########################################################################
##########################################################################
#    extractProjectName   - function to extract project name, area name, satellite beam  from a string
#    usage:    ($projectName,$regionName,$satellite,$beam,$track,$startFrame,$endFrame)=extractProjectName("$str");
#    test with wrapper  extractProjectName.pl
#
#    e.g. extractProjectName.pl LaquilaT079F859ErsD
#         extractProjectName.pl LaquilaT079F837-855ErsD 
#         extractProjectName.pl /RAID6/sbaker/SO/FernandinaEnvD2/Interferograms 
#         extractProjectName.pl PO_IFGRAM_BasinRangeT412F2156-4000ErsD_Stacks_010101_051010_00020
#         extractProjectName.pl PO_IFGRAM_BasinRangeT412F2156-4000ErsD
#         extractProjectName.pl /RAID6/amelung/HawaiiRsatA3
#         extractProjectName.pl /RAID6/amelung/Stacks/PO_IFGRAM_HawaiiRsatA3_010101_051231_00012
#         Naming convention: the project name is giving by the string containing Rsat,Ers,Env,Alos, etc separated by "_"
#         Compare with extract_ProjectName.m 
#
#######################################################
sub extractProjectName {
  $name= shift ;

  @toks=split(/\//,$name) ;                 # splitting for "/" 
  while ($#toks >= 0)
    {  $token = shift @toks ;
       $token =~ /Env|Rsat|Ers|Alos|Alos2|Jers|Tsx|Csk|Rsat2|Tdm/    and $name=$token ;
    }
  @toks=split(/_/,$name) ;                  # splitting for "_" 
  while ($#toks >= 0)
    {  $token = shift @toks ;
       $token =~ /Env|Rsat|Ers|Alos|Alos2|Jers|Tsx|Csk|Rsat2|Tdm/    and $name=$token ;
    }
  $projectName = $name;
 
# extract Area and Beam from the AreaAndBeam name

  $projectName=~ /Rsat/  and   ($regionTrackFrame,$beam)=split(/Rsat/,$projectName) and $satellite="Rsat" ;
  $projectName=~ /Ers/   and   ($regionTrackFrame,$beam)=split(/Ers/ ,$projectName) and $satellite="Ers"  ; 
  $projectName=~ /Env/   and   ($regionTrackFrame,$beam)=split(/Env/ ,$projectName) and $satellite="Env"  ;
  $projectName=~ /Alos/  and   ($regionTrackFrame,$beam)=split(/Alos/,$projectName) and $satellite="Alos" ;
  $projectName=~ /Alos2/ and   ($regionTrackFrame,$beam)=split(/Alos2/,$projectName) and $satellite="Alos2" ;
#  $projectName=~ /Alos2WD/ and   ($regionTrackFrame,$beam)=split(/Alos2WD/,$projectName) and $satellite="Alos2WD" ;
  $projectName=~ /Jers/  and   ($regionTrackFrame,$beam)=split(/Jers/,$projectName) and $satellite="Jers" ;
  $projectName=~ /Tsx/   and   ($regionTrackFrame,$beam)=split(/Tsx/ ,$projectName) and $satellite="Tsx" ;
  $projectName=~ /Csk/   and   ($regionTrackFrame,$beam)=split(/Csk/ ,$projectName) and $satellite="Csk" ;
  $projectName=~ /Csk/   and   ($regionTrackFrame,$beam)=split(/CskSlc/ ,$projectName) and $satellite="Csk" ;
  $projectName=~ /Rsat2/ and   ($regionTrackFrame,$beam)=split(/Rsat2/ ,$projectName) and $satellite="Rsat2" ;
  $projectName=~ /Sen/   and   ($regionTrackFrame,$beam)=split(/Sen/ ,$projectName) and $satellite="Sen" ;
  $projectName=~ /Kmps5/   and   ($regionTrackFrame,$beam)=split(/Kmps5/ ,$projectName) and $satellite="Kmps5" ;
  $projectName=~ /Tdm/   and   ($regionTrackFrame,$beam)=split(/Tdm/ ,$projectName) and $satellite="Tdm" ;
 
# extract track and startFrame  FA 5/2009

  my $track       = NULL;
  my $startFrame  = NULL;
  my $endFrame    = NULL;

  if ($regionTrackFrame  =~ /F[0-9]/ ) {$ind=rindex($projectName,"F"); $regionTrack=substr($regionTrackFrame,0,$ind);  $startFrame=substr($regionTrackFrame,$ind+1);}else{ $regionTrack=$regionTrackFrame;}
  if ($regionTrack       =~ /T[0-9]/ ) {$ind=rindex($regionTrack,"T"); $regionName =substr($regionTrack,0,$ind);       $track=substr($regionTrack,$ind+1);}     else{ $regionName=$regionTrack;}

  if ( $startFrame =~ /-/ )   { ($startFrame,$endFrame) = split("-", $startFrame)  }else{ $endFrame = NULL; }
 
  !($projectName =~ /Env|Rsat|Ers|Alos|Alos2|Jers|Tsx|Csk|Rsat2|Tdm|Sen|Kmps5/) and Message "extractProjectName: no satellite name found in string <$name>" and die; 

  $beam=~ /HH/ and ($beamSwath) = split(/HH/,$beam) and $pol="HH";
  $beam=~ /HV/ and ($beamSwath) = split(/HV/,$beam) and $pol="HV";
  $beam=~ /VV/ and ($beamSwath) = split(/VV/,$beam) and $pol="VV";

  $beam = substr($beam,0,2);

  if ($print_flag) {print "<$projectName><$regionName><$satellite><$beam><$track><$startFrame><$endFrame>\n"; exit 0}
  
  return $projectName,$regionName,$satellite,$beam,$track,$startFrame,$endFrame,$pol,$swath ;

  exit 0 ;
}

##########################################################################
##########################################################################
sub getStarttime{
    $rawfile = shift;
    $strSatellite = shift;
    $strPrefix = shift;

#	$rawfile = $rrpwd . "/" . $raw;
    $Value = '';
    if ( $strPrefix eq 'RAW' ) {
        given (uc($strSatellite)) {
            when "RSAT" {
                open IN, $rawfile or die "Can't read $rawfile\n";
                seek(IN, 788, SEEK_SET);
                read IN, $Value, 18;
                last;
            }
			
            when "ENV" {
                open IN, $rawfile or die "Can't read $rawfile\n";
                while ( chomp($strTemp = <IN>)) {
                    @var = split(/=/,$strTemp);
                    $ID = $var[0];
                    if ( $ID eq 'SENSING_START' ) {
                        @var = split(/=/,$strTemp);
                        $ID = $var[0];
                        $Value = $var[1];                                
                        last;
                    }
                }
            }
            when "JERS" {
                open IN, $rawfile or die "Can't read $rawfile\n";
                seek(IN, 788, SEEK_SET);
                read IN, $Value, 18;
                last;
            }
        }
    }
	
    if ( $strPrefix eq 'LED' ) {
        given (uc($strSatellite)) {
            when "RSAT" {
                open IN, $rawfile or die "Can't read $rawfile\n";
                seek(IN, 788, SEEK_SET);
                read IN, $Value, 18;
                last;
            }					
            when "ERS" {
                open IN, $rawfile or die "Can't read $rawfile\n";
                seek(IN, 788, SEEK_SET);
                read IN, $Value, 18;
                last;
            }			
            when "ALOS" {
                open IN, $rawfile or die "Can't read $rawfile\n";
                seek(IN, 788, SEEK_SET);
                read IN, $Value, 18;
                last;
            }			
            when "JERS" {
                open IN, $rawfile or die "Can't read $rawfile\n";
                seek(IN, 788, SEEK_SET);
                read IN, $Value, 18;
                last;
            }
        }
    }
	
    return $Value;
}

##########################################################################
sub orbit2track {
    $strOrbit     = shift ;
    $strSatellite = shift ;
    $date         = shift ;
     
    $track = '';
    given (uc($strSatellite)) {
        when "ALOS" {
            $track = (46*$strOrbit+84)%671 + 1 ; $track = sprintf ("%03d",$track ) ;
        }
        when "JERS" {
            $track = (44*$strOrbit+81)%659; $track = sprintf ("%03d",$track ) ;
        }
        when "ERS2" {
            $track = ($orbit-355)%501 ;
        }
        when "ERS1" {
            if ($date >= 910725  &&  $date <= 911210) { 
                $track = ($orbit -   143) %   43 ;  $phase = 'A' ;
            } elsif ($date >= 911228  &&  $date <= 920330) {
            #elsif ($orbit >=  2354 && $orbit <=  3713)
                $track = ($orbit -  2376) %   43 ;  $phase = 'B' ;
            } elsif ($date >= 920414  &&  $date <= 931220) { 
			#elsif ($orbit >=  3901 && $orbit <= 12749) 
                $track = ($orbit -  4153) %  501 ;  $phase = 'C';
            } elsif ($date >= 931223  &&  $date <= 940410) { 
			#elsif ($orbit >= 12754 && $orbit <= 14300) 
                $track = ($orbit - 12770) %   43 ;  $phase = 'D';
            } elsif ($date >= 940411  &&  $date <= 940926) { 
                $track = ($orbit - 14921) % 2411 ;  $phase = 'E';
            } elsif ($date >= 940928  &&  $date <= 950321) {       
                $track = ($orbit - 16801) % 2411 ;  $phase = 'F';
            } elsif ($date >= 950321                     ) {      
                #elsif ($orbit >= 19248                   ) 
                $track = ($orbit - 19527) %  501 ;  $phase = 'G';
            }  
        }
#        when "ERS2" {
#            track = ($orbit-355)%501 ;  $phase = 'A' ;
#        }
        when "Sen" {
            $track = ($strOrbit-72)%175 ;          
        }
    }
    $track = sprintf ("%03d",$track) ;
    return $track ;
}

##########################################################################
sub getOrbitnumber {
    $rawfile = shift;
    $strPrefix = shift;
    if ( $strPrefix eq 'LED' ) {
        $answer=`$INT_BIN/CEOS	$rawfile | grep "Orbit number" `; chomp($answer) ;
        @toks=split(/:/, $answer) ;  $orbit = @toks[1] ;  $orbit =~ s/^\s+|\s+$//go ;
    }
    $orbit = sprintf ("%05d",$orbit) ;
    return $orbit ;
}

##########################################################################
sub getSatellite {
    $rawfile = shift;
    $strPrefix = shift;
    if ( $strPrefix eq 'LED' ){
        $answer=`$INT_BIN/CEOS  $rawfile | grep "Sensor platform mission identifier"`; chomp($answer) ;   
        @toks=split(/:/, $answer) ;  $satellite = @toks[1] ;  $satellite =~ s/^\s+|\s+$//go ;
    }
    return $satellite ;
}	                                                                        		

##########################################################################
sub getFramenumber {
    $rawfile = shift;
    $strPrefix = shift;
    if ( $strPrefix eq 'VDF' ){
        $answer=`$INT_BIN/CEOS $rawfile | grep "FRAME" | awk '{print $6}'`; chomp($answer1) ;
        @ff = split (' ',$answer); $frame = @ff[5] ;
        $frame=~ s/^\s+|\s+$//go ;		
    }        
    elsif ( $strPrefix eq 'LED' ){
        $answer=`$INT_BIN/CEOS $rawfile | grep "FRAME" | awk '{print $6}'` ;
        @ff = split (' ',$answer); $frame = @ff[5] ;
        $frame=~ s/^\s+|\s+$//go ;
        @toks=split(/=/, $frame) ;              
        $frame = @toks[2] ;
        
    }
    $frame = sprintf("%04d",$frame) ;
    return $frame ;
}	

##########################################################################
sub getMon2num {
    $strMonth = shift;
    given ($strMonth) {
        when "JAN" { return 1; }
        when "FEB" { return 2; }
        when "MAR" { return 3; }
        when "APR" { return 4; }
        when "MAY" { return 5; }
        when "JUN" { return 6; }
        when "JUL" { return 7; }
        when "AUG" { return 8; }
        when "SEP" { return 9; }
        when "OCT" { return 10; }
        when "NOV" { return 11; }
        when "DEC" { return 12; }
        else {
            print "something wrong"; 
            exit;
        }
    }
}

##########################################################################
sub getSubdir {
    my $inputDir = shift;
	
    ($dirname, $path) = fileparse($inputDir);
    $path = $path . $dirname;

    opendir(DIR, $path) or die "$!\n";
    my @items = readdir(DIR);  
    closedir DIR;

    my @folder;
    foreach (@items) {         
        next if $_ =~ /^\.\.?$/;
        next if (-f $_);
        push @folder, $inputDir . "/" . $_;
    }
   #foreach $_( @folder ) { print "getSubdir  folder::<$_>\n";}
   return @folder;
}

##########################################################################
sub getSubdirectory {
    my $inputDir = shift;
    ($dirname, $path) = fileparse($inputDir);
    $path = $path . $dirname;
    opendir(DIR, $path) or die "$!\n";
    my @items = readdir(DIR);  
    closedir DIR;

    $rrpwd=`pwd` ;  chomp($rrpwd) ; 
    $strFolder = $rrpwd . "/" . $inputDir; 
    chdir "$strFolder";

    foreach (@items) {         
        next if $_ =~ /^\.\.?$/;
        next if (-f $_);
        push @folder, $inputDir . "/" . $_;
    }

    chdir "$rrpwd";
    return @folder;
}

sub getPRF{
    $rawfile = shift;
    $strSatellite = shift;
    $strPrefix = shift;
    $Value = '';

    if ($strPrefix eq 'LED' ) {
        given (uc($strSatellite)) {
	    when ALOS {
                open IN, $rawfile or die "Can't read $rawfile\n";
                seek(IN, 1654, SEEK_SET);
                read IN, $Value, 16;
                last;
            }
	}
    
    }

    return $Value;
}

sub getDoppler{
# getDoppler($ledfile, $imgfile, $Sat);
    $ledfile = shift;
    $imgfile = shift;
    $strSatellite = shift;
    $Value = '';
    $Blank = "$INT_SCR/blank.txt";  

    `cp $MSP_HOME/sensors/RSAT*.gain .`;

    $call_str = "$GAMMA_BIN/RSAT_raw $ledfile System.par pslc.par $imgfile data.fix < $Blank";
    Message "$call_str"; `$call_str`;

    $call_str = "$GAMMA_BIN/dop_ambig System.par pslc.par data.fix 2 > log_dop";
    Message "$call_str"; `$call_str`;

    $Value = Use_gamma "log_dop read estimated centroid";

    `rm RSAT*.gain RSAT_attitude.dat pslc.par data.fix lod_dop`;

    return $Value;
}


##########################################################################
sub getFile {
    my $inputDir = shift;
    my $suffix = shift;
    my $bLink = shift or $bLink = 0;
    my @files;
    ($dirname, $path) = fileparse($inputDir);
    $path = $path . $dirname;
    if ($suffix eq "*.template") {
        @files = `find $path -maxdepth 1 -type f -iname "$suffix"`;
    } elsif ($suffix eq "*.slc") {
        @files = `find $path -type f -name "$suffix" 2>/dev/null`;    # FA 11/15: silenced
    } elsif ($suffix eq "*.slc.par") {
        @files = `find $path -type f -name "$suffix"`;
#    } elsif (substr($suffix,rindex($suffix,)) eq "fix") {
#        @files = `find $path -type f -name "$suffix"`;
    } elsif ($suffix eq "ASA_INS*") {
        @files = `find $path -maxdepth 1 -type f -name "$suffix"`;
    } elsif ($suffix eq "ASA_XCA*") {
        @files = `find $path -maxdepth 1 -type f -name "$suffix"`;
    } else {
        @files = `find $path -type f -iname "$suffix"`;
    }
    
    if ($bLink == 1) {
        @files = `find $path -type l -iname "$suffix"`;
    }

    chomp(@files);
    return @files;
}

##########################################################################
sub getSensor{
    $rawfile = shift;
    $strSatellite = shift;
    $strPrefix = shift;
    $Value = '';

    if ( $strPrefix eq 'LED' ) {
        given (uc($strSatellite)) {
            when "ERS" {
                open IN, $rawfile or die "Can't read $rawfile\n";
                seek(IN, 48, SEEK_SET);
                read IN, $Value, 4;
                last;
            }			
        }
    }
	
    return $Value;
}

##########################################################################
sub getSensorName{
    $L0dir = shift;
    @var = split(/\//,$L0dir);
    $Value = substr($L0dir, 7, length(@var[0])-7);
#	print stderr $Value . "\n";
	
    return $Value;
}

##########################################################################
sub unpackL0data {
    $Sat = shift;
    $L0Dir = shift;
    $SLCDir = shift;
    $startDate = shift;
    $endDate = shift;
 
    unless(-d $SLCDir) {`mkdir -p $SLCDir`;}

    @rawfolder = getSubdir($L0Dir);
    $joblist = "$SLCDir/run_unpackL0data";
    unlink($joblist);
    open(joblist,">>$joblist");
  
    foreach $_ ( @rawfolder ) {
        $_ =~ s+/$++g;
        given (uc($Sat)) {
            when "ERS" {
                ($Orbit, $Frame, $yymmdd, $hhmmss) = getSensorInfo($Sat, $_);
            }
        }

        if ($yymmdd <= 500000) {
             $YYYYMMDD = $yymmdd + 20000000;
        } elsif ($yymmdd > 500000) {
             $YYYYMMDD = $yymmdd + 19000000;
        }
     
        if ( ($YYYYMMDD >= $startDate) && ($YYYYMMDD <= $endDate) ) {
            if (@acquisitionList && ( grep { $_ eq $YYYYMMDD } @acquisitionList )) {
                ($tgzFile) = getFile($_, "*tar.gz");
                if ($tgzFile eq '') {
                    ($tgzFile) = getFile($_, "*tgz");
                }    
	
	            $call_str =  "tar xvfz $tgzFile --directory $_";
                Message "$call_str"; 
                print joblist $call_str;
                print joblist "\n";
            } else {
                ($tgzFile) = getFile($_, "*tar.gz");
                if ($tgzFile eq '') {
                    ($tgzFile) = getFile($_, "*tgz");
                } 

                $call_str =  "tar xvfz $tgzFile --directory $_";
                Message "$call_str";
                print joblist $call_str;
                print joblist "\n";
            }
        } 
    }
    close joblist;
    $rrpwd=`pwd` ;  chomp($rrpwd) ;
    chdir($SLCDir);
    
    $call_str =  "$INT_SCR/createBatch.pl --workdir $SLCDir --infile $SLCDir/run_unpackL0data walltime=$walltime_unpack";
    Message "$call_str"; `$call_str`;
    Status "createBatch.pl";
    chdir($rrpwd);
    @rawfolder = ();
}

##########################################################################
sub getSensorInfo {
    $Sat = shift;	
    $strDir = shift;
    given (uc($Sat)) {
        when "ENV" {
            $strDirtemp = substr($strDir, length($strDir)-23, 23);
            ($Beammode, $Orbit, $yymmdd, $hhmmss) = split(/_/,$strDirtemp);
            return $Beammode, $Orbit, $yymmdd, $hhmmss;
        }
        when "ALOS" {
            $strDirtemp = substr($strDir, length($strDir)-18, 18);
            ($Frame, $yymmdd, $hhmmss) = split(/_/,$strDirtemp);
            return $Frame, $yymmdd, $hhmmss;
        }
        when "ERS" {
            $strDirtemp = substr($strDir, length($strDir)-25, 25);
            ($dummy, $Orbit, $Frame, $yymmdd, $hhmmss) = split(/_/,$strDirtemp);
            return $Orbit, $Frame, $yymmdd, $hhmmss;
        }
        when "JERS" {
            #$strDirtemp = substr($strDir, length($strDir)-20, 20);
            $strDirtemp = basename($strDir);                         # FA 11/2015: basename seems much smarter
            #($Sat,$Orbit, $Frame, $yymmdd) = split(/_/,$strDirtemp); # FA 11/2015
            ($Sat,$Orbit, $Frame, $yymmdd,$hhmmss) = split(/_/,$strDirtemp); # FA 4/2016
            return $Orbit, $Frame, $yymmdd,$hhmmss;
        }  
        when "RSAT" {
            $strDirtemp = basename($strDir);                                 # FA 1/2017
            ($Sat,$Orbit, $Frame, $yymmdd,$hhmmss) = split(/_/,$strDirtemp); # FA 1/2017
            return $Orbit, $Frame, $yymmdd;
        }   
        when "CSK" {
            #$strDirtemp = substr($strDir, length($strDir)-20, 20);      # FA 9/2016: worked for CSK_HI_08_26553_20120504162108 but not for CSK_HI_08_8734_20120617162047
            #($Orbit, $yymmdd) = split(/_/,$strDirtemp);
            #$yymmdd = substr($yymmdd, 2, 6); 
            $strDirtemp = basename($strDir);                             # FA 9/2016: same as for JERS: using basename seems much smarter
            ($Sat,$mode,$beam,$Orbit,$strDate) = split(/_/,$strDirtemp); # FA 9/2016: I believe HI and 08 stands for mode and beam but not sure
            $yymmdd = substr($strDate, 2, 6); 
            return $Orbit, $yymmdd;
        }
    }
}
##########################################################################
sub generateFramelist {
    $satellite  = shift;
    $startframe = shift;
    $endframe   = shift;

    $satellite =~ /Alos/     and $framestep=10;
    $satellite =~ /Ers|Env/  and $framestep=18;

    if ($endframe == "NULL" ) { $endframe = $startframe ; }
    $total     = $endframe - $startframe ;      # print "TOTAL = $total\n";
    $startframe = sprintf ("%04d", $startframe) ;
    @framelist = $startframe ;
    if ( $total == 0 ) {
        #print "ONLY ONE FRAME TO GET: <@framelist>\n";
    } else {
        $frame_total    = ($endframe - $startframe)/$framestep + 1 ;
        $previous_frame = $startframe ;
        for ($count = 1 ; $count < $frame_total ; $count++) {
            $current_frame  = $previous_frame + $framestep ; #print "Current frame: $current_frame \n";
            $current_frame  = sprintf ("%04d", $current_frame) ;
            push (@framelist, $current_frame) ;
            $previous_frame = $current_frame ;
            #print "MULTIPLE FRAMES TO GET: <@framelist>\n";
        }
    }
   return @framelist;
}



###################################################################################
sub IREAdatelist2MIAMIdatelist{
    $datefile = shift ;
    open IN, "$datefile" or die "Can't read $datefile\n";
    chomp($line = <IN>) ;              # Skips number of interferograms
    while (chomp($line = <IN>)){  
        $date1_yr = substr($line,6,2 ) ;
        $date1_mo = substr($line,2,2 ) ;
        $date1_da = substr($line,0,2 ) ;
        $date2_yr = substr($line,18,2 ) ;
        $date2_mo = substr($line,14,2 ) ;
        $date2_da = substr($line,12,2 ) ;
    
        push @masters,"${date1_yr}${date1_mo}${date1_da}" ;
        push @slaves, "${date2_yr}${date2_mo}${date2_da}" ;
    }

    return (\@masters , \@slaves) ;
}

###################################################################################
sub uniq {
    my %h ;
    return grep { !$h{$_}++ } @_;
}

###################################################################################
sub cleanL0data {
    $L0Dir = shift;
    @rawsubfolder = getSubdir($L0Dir);

    foreach $_ (@rawsubfolder) {
        my $datFiles, @psFile;
        
        ($tgzFile) = getFile($_, "*tar.gz");
	    if ($tgzFile eq '') {
	        ($tgzFile) = getFile($_, "*tgz");
	    }
        if ($tgzFile ne '') {
            Message "Cleaning $_ directory";
            @datFile = getFile($_, "*.001");
            foreach $File (@datFile) {
                $datFiles .= $File . " ";  
            }
            @psFile = getFile($_, "*.ps");
            
            $call_str = "rm -f $datFiles @psFile[0]";
            Message "$call_str"; `$call_str`;
        }
    }
}

###################################################################################
sub getCoord {

  $inFile = shift;
  
  open IN, $inFile or die "Can't read $infile\n";
  while (chomp($strTemp = <IN>)) {
    $strTemp =~ /corner/ and ($dummy0, $dummy1, $strLatTemp, $strLonTemp, $dummy2)=split(' ',$strTemp) and push @strLat, $strLatTemp and push @strLon, $strLonTemp;
  }
  @strCoord[0] = max(@strLat);
  @strCoord[1] = min(@strLat);
  @strCoord[2] = max(@strLon);
  @strCoord[3] = min(@strLon);
 
  return @strCoord;
}

sub Use_gamma {
  @args = split /\s+/, shift @_;
  $ersfile1 = shift @args;
  $task     = shift @args;
  $keyword  = shift @args;
  
  if ($task eq "read") {  
    open ERS1, "$ersfile1" or die "Can't read $ersfile1\n";
    $found = 0;
    foreach $line (<ERS1>) {
      if ($line =~ /$keyword\s+(\S+)/) {  
      	$line =~ /\:\s+(\S+)/; 
      	$value  = "$1";
				$found  = 1;
        last; #match only first occurence
      }
    } 
    defined $value or warn "Keyword $keyword doesn't exist in $ersfile1, returning 0\n";
    return($value);
    close(ERS1) or warn "$0: error in closing file $!\n";
  }				
}
1;
