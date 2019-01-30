# vim: set filetype=sh:
echo "sourcing ${PWD}/default_isce22.bash ..."
#####################################################
export PARENTDIR=${PWD}
export TERM=xterm
export VISUAL=/bin/vi

###### machine dependent variables   ##########
export JOBSCHEDULER=LSF 
export QUEUENAME=general
export SCRATCHDIR=/projects/scratch/insarlab/${USER}
export TESTDATADIR=visx.ccs.miami.edu:/famelung/famelung/testdata
export MATLABHOME=/share/opt/MATLAB/R2014b
export MATLABHOME=/share/opt/MATLAB/R2018a
export MATLAB_BIN=${MATLABHOME}/bin

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH-""}

###### for JOB SUBMISSION ###################
export WORKDIR=~/insarlab
export NOTIFICATIONEMAIL=${USER}\@rsmas.miami.edu

export INT_SCR=${PARENTDIR}/sources/roipac/INT_SCR

############ Standard directories ###########
export DEMDIR=${WORKDIR}/DEMDIR
export TEMPLATEDIR=${WORKDIR}/TEMPLATEDIR
export JOBDIR=${WORKDIR}/JOBS

export SAMPLESDIR=${PARENTDIR}/samples
export TE=${TEMPLATEDIR}
export OPERATIONS=${HOME}/insarlab/OPERATIONS

##############  PYTHON  ##############
export PYTHON3DIR=${PARENTDIR}/miniconda3
export CONDA_ENVS_PATH=${PARENTDIR}/miniconda3/envs
export CONDA_PREFIX=${PARENTDIR}/miniconda3
export PROJ_LIB=${CONDA_PREFIX}/share/proj
export GDAL_DATA=${PYTHON3DIR}/share/gdal

############## FOR ISCE ##################
export ISCEHOME=${PARENTDIR}/3rdparty/isce/ISCE
export SENTINEL_STACK=${PARENTDIR}/3rdparty/sentinelstack/sentinelstack
export SENTINEL_STACK_MODIFIED=${PARENTDIR}/sources/sentinelstack_modified
#export SENTINEL_STACK=${PARENTDIR}/3rdparty/sentinelstack/stripmapStack
export ISCEDOWNLOADFILE=${PARENTDIR}/3rdparty/isce/isce-2.2.0.tar.bz2
export SCONS_CONFIG_DIR=${PARENTDIR}/3rdparty/isce/isce-2.2.0

############# SqueeSAR #####################
export SQUEESAR=${PARENTDIR}/sources/pysqsar

############ FOR RSMAS ISCE  #########
export RSMAS_ISCE=${PARENTDIR}/sources/rsmas_isce

############ FOR SSARA SOFTWARE #########
export SSARAHOME=${PARENTDIR}/3rdparty/SSARA
export SSARA_ASF=${PARENTDIR}/sources/ssara_ASF

############ FOR PySAR SOFTWARE  ########
export PYSAR_HOME=${PARENTDIR}/sources/PySAR
export PATH=${PATH}:${PYSAR_HOME}/pysar:${PYSAR_HOME}/sh

####### For RSMAS coregistration software ######
export PYTHONPATH=${PYTHONPATH-""}
export PYTHONPATH=${PYTHONPATH}:${PYSAR_HOME}
export PYTHONPATH=${PYTHONPATH}:${INT_SCR}
export PYTHONPATH=${PYTHONPATH}:${ISCEHOME}:${PYTHON3DIR}/lib/python3.6/site-packages
export PYTHONPATH_RSMAS=${PYTHONPATH}

export PROJ_LIB=${PARENTDIR}/miniconda3/share/proj

############ FOR TIPPECANOE  #########
export PATH=${PATH}:${PARENTDIR}/3rdparty/tippecanoe/bin
export PATH=${PATH}:${SSARAHOME}
export PATH=${PATH}:${SSARA_ASF}
export PATH=${PATH}:${RSMAS_ISCE}:${INT_SCR}:${MATLABHOME}/bin:${SQUEESAR}:${SQUEESAR}/gamma
export PATH=${ISCEHOME}/isce/applications:${ISCEHOME}/isce/bin:${SENTINEL_STACK_MODIFIED}:${SENTINEL_STACK}:${PATH}
export PATH=${PYTHON3DIR}/bin:${PATH}
export PATH=${PATH}:${PROJ_LIB} 


export LD_LIBRARY_PATH=${PYTHON3DIR}/lib
export LD_RUN_PATH=${PYTHON3DIR}/lib

 
if [ -n "${prompt}" ] 
then 
    echo "PARENTDIR:      " ${PARENTDIR}
    echo "PYTHON3DIR:     " ${PYTHON3DIR}
    echo "SSARAHOME:      " ${SSARAHOME}
fi
