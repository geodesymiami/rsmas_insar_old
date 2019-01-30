# vim: set filetype=sh:
echo "sourcing $PWD/custom.bash ..."

###### MACHINE AND JOBSUBMISSION ####################################
#export JOBSCHEDULER=LSF           # PBS for demeter
#export QUEUENAME=debug            # 
#export TESTDATADIR=visx.ccs.miami.edu:/famelung/famelung/testdata
#export HOSTNAME=demeter
#export NOTIFICATIONEMAIL=f.amelung@miami.edu           # If different from the typical famelung@rsmas.miami.edu (USER=famelung)

###################################################
if [[ ${USER} == famelung ]] || [[  ${USER} == sxh733 ]]
then
  export SCRATCHDIR_ORIG=/scratch/projects/vdm/${USER}
  #export SCRATCHDIR=$SCRATCHDIR_ORIG
fi
if [[ ${HOST} == demeter ]]
then
  export SCRATCHDIR=/nethome/insarlab/famelung
fi

############# GMT SOFTWARE ##########################
#export GMTHOME=/your/custom/path

export COOKIE_DLR="# HTTP cookie file.\nsupersites.eoc.dlr.de\tFALSE\t/\tFALSE\t0\tPHPSESSID\ta8akeqmceqir8ustr02qndqq9es8ami5p6e6u6repf417if0mfm0"
export COOKIE_DLR="# HTTP cookie file.\nsupersites.eoc.dlr.de\tFALSE\t/\tFALSE\t0\tPHPSESSID\tqq0u7b022r4u2423718nk6llpq2q3pc7nrdab21r8m8uk6prhb81"
export COOKIE_DLR="# HTTP cookie file.\nsupersites.eoc.dlr.de\tFALSE\t/\tFALSE\t0\tPHPSESSID\tfbobeer3fbkbjtn09jgopunn34"
export COOKIE_DLR="# HTTP cookie file.\nsupersites.eoc.dlr.de\tFALSE\t/\tFALSE\t0\tPHPSESSID\tfflk63nu8j3e1rv45auujq2586"
