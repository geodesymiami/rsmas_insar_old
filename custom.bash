# vim: set filetype=sh:
echo "sourcing $PWD/custom.bash ..."

###### MACHINE AND JOBSUBMISSION ####################################
#export TESTDATADIR=visx.ccs.miami.edu:/famelung/famelung/testdata
#export NOTIFICATIONEMAIL=f.amelung@miami.edu           # If different from the typical famelung@rsmas.miami.edu (USER=famelung)

###################################################
if [[ ${USER} == famelung ]] || [[  ${USER} == sxh733 ]]
then
  export SCRATCHDIR_ORIG=/scratch/projects/vdm/${USER}
  #export SCRATCHDIR=$SCRATCHDIR_ORIG
fi
if [[ ${HOST} == eos ]]
then
  export SCRATCHDIR=/scratch/insarlab/${USER}
  export TESTDATA_ISCE=/home/famelung/insarlab/TESTDATA_ISCE
  export AUXDATA_ISCE=/home/famelung/insarlab
  export SENTINEL_ORBITS=${WORKDIR}/S1orbits
  export SENTINEL_AUX=${WORKDIR}/S1aux
  export JOBSCHEDULER=PBS
  export QUEUENAME=batch
fi
if [[ ${HOST} == centos7.bogon105.com ]]
then
  export SCRATCHDIR=/data/DATADIR/testdata
  export SENTINEL_ORBITS=/home/famelung/S1orbits
  export SENTINEL_AUX=/homeF/famelung/S1aux
  export JOBSCHEDULER=PBS
  export QUEUENAME=batch
fi

############# GMT SOFTWARE ##########################
#export GMTHOME=/your/custom/path

export COOKIE_DLR="# HTTP cookie file.\nsupersites.eoc.dlr.de\tFALSE\t/\tFALSE\t0\tPHPSESSID\tfflk63nu8j3e1rv45auujq2586"
