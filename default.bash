# vim: set filetype=sh:
echo "sourcing $PWD/default.bash ..."
#####################################################
export PARENTDIR=$PWD
export TERM=xterm
export ARCHC=LIN
export VISUAL=/bin/vi

###### machine dependent variables   ##########
export JOBSCHEDULER=LSF 
export QUEUENAME=general
export SCRATCHDIR=/projects/scratch/insarlab/${USER}
export TESTDATADIR=visx.ccs.miami.edu:/famelung/famelung/testdata
export MATLABHOME=/share/opt/MATLAB/R2014b
export MATLABHOME=/share/opt/MATLAB/R2018a
export MATLAB_BIN=${MATLABHOME}/bin
export DISPLAY_COMPILE_FLAG=0

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH-""}

###### for JOB SUBMISSION ###################
export WORKDIR=~/insarlab
export NOTIFICATIONEMAIL=${USER}\@rsmas.miami.edu

###### for roi_pac ##########################
export ROIPACHOME=${PARENTDIR}/3rdparty/roipac/ROI_PAC_3_0_1/ROI_PAC
export INT_LIB=${PARENTDIR}/sources/roipac/LIB/${ARCHC}
export INT_BIN=${PARENTDIR}/sources/roipac/BIN/${ARCHC}
export INT_SCR=${PARENTDIR}/sources/roipac/INT_SCR

##### FOR FFTW SOFTWARE ###################
export FFTWHOME2=${PARENTDIR}/3rdparty/FFTW/fftw-2.1.5
export FFTWHOME=${PARENTDIR}/3rdparty/FFTW/fftw-3.3.4
export FFTW_LIB="$FFTWHOME/${ARCHC}_fftw_lib" 
export FFTW_LIB_DIR=${FFTW_LIB}/lib
export FFTW_INC_DIR=${FFTW_LIB}/include
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH":${FFTW_LIB}"				# uses locally compiled GAMMA

##### FOR IMAGEMAGICK  ###################
export IMAGEMAGICKHOME=${PARENTDIR}/3rdparty/ImageMagick/ImageMagick-6.9.0-4
export IMAGEMAGICK_BIN=${IMAGEMAGICKHOME}/bin
export PATH=${PATH}:${IMAGEMAGICK_BIN}
export PATH=/nethome/famelung/.local/bin:${PATH}

##### FOR GMT SOFTWARE ###################
export GMTHOME=${PARENTDIR}/3rdparty/GMT/gmt-4.5.12
export GMT_BIN=${GMTHOME}/bin
#export GMT_GRIDDIR=${AUXDATAHOME}/geophys_data/geoware/DATA/grids

##### FOR GEODMOD SOFTWARE ###################
export GEODMODHOME=${PARENTDIR}/sources/geodmod                             
export GEODMOD_TESTDATA=${PARENTDIR}/data/testdata/geodmod
export GEODMOD_TESTBENCH=${SCRATCHDIR}/GEODMOD_TESTBENCH

##########################################
export DEMDIR=${WORKDIR}/DEMDIR
export TEMPLATEDIR=${WORKDIR}/TEMPLATEDIR
export OPERATIONS=${WORKDIR}/OPERATIONS
export JOBDIR=${WORKDIR}/JOBS
export ROIPAC_TESTDATA=${PARENTDIR}/data/testdata/roi_pac
export SAR_ODR_DIR=${PARENTDIR}/data/orbits/ODR
export SAR_PRC_DIR=${PARENTDIR}/data/orbits/PRC
export SAR_PRL_DIR=${PARENTDIR}/data/orbits/PRL
export VOR_DIR=${PARENTDIR}/data/orbits/DOR
export POR_DIR=${PARENTDIR}/data/orbits/POR 
export INS_DIR=${PARENTDIR}/data/orbits/EnvisatIns

export SAMPLESDIR=${PARENTDIR}/samples
export TE=${TEMPLATEDIR}

export GETORBHOME=${PARENTDIR}/3rdparty/getorb/2.3.1/getorb
export MAKEDEMHOME=${PARENTDIR}/sources/roipac/makedem
export MAKEDEM_SCR=${MAKEDEMHOME}/SCRIPTS
export MAKEDEM_BIN=${INT_BIN}


########## FOR MDX SOFTWARE ##########
export MDXHOME=${PARENTDIR}/3rdparty/mdx/mdx_179_75_03

########## FOR GAMMA SOFTWARE ########
export GAMMA_HOME1=${PARENTDIR}/3rdparty/gamma/GAMMA_SOFTWARE-20150702               # 12/15 FA
export GAMMA_BIN=${GAMMA_HOME1}/BIN
export GAMMA_LITEND_BIN=${GAMMA_HOME1}_LITEND/BIN

export GAMMA_HOME2=${PARENTDIR}/3rdparty/gamma/GAMMA_SOFTWARE-20160625_LITEND        # 9/16 works for RSAT2
export GAMMA_HOME2=${PARENTDIR}/3rdparty/gamma/GAMMA_SOFTWARE-20160625_BIGEND        # 9/16 works for Env, Alos2, Tsx
export GAMMA_HOME=${GAMMA_HOME2}                                                    # 2/17 FA
export GAMMA_BIN=${GAMMA_HOME2}/BIN
export GAMMA_LITEND_BIN=${PARENTDIR}/3rdparty/gamma/GAMMA_SOFTWARE-20160625_LITEND/BIN

export MSP_HOME=${GAMMA_HOME2}/MSP
export ISP_HOME=${GAMMA_HOME2}/ISP
export DISP_HOME=${GAMMA_HOME2}/DISP
export DIFF_HOME=${GAMMA_HOME2}/DIFF
export LAT_HOME=${GAMMA_HOME2}/LAT
MSP_path="${MSP_HOME}/bin ${MSP_HOME}/scripts"
ISP_path="${ISP_HOME}/bin ${ISP_HOME}/scripts"
DIFF_path="${DIFF_HOME}/bin ${DIFF_HOME}/scripts"
LAT_path="${LAT_HOME}/bin ${LAT_HOME}/scripts"
DISP_path="${DISP_HOME}/bin"


########### FOR GEOTIFF SOFTWARE #######
export GEOTIFFHOME=${PARENTDIR}/3rdparty/geotiff/libgeotiff-1.3.0

########### FOR TIFF SOFTWARE ##########
export TIFFHOME=${PARENTDIR}/3rdparty/tiff/tiff-3.9.4

############ FOR SSARA SOFTWARE #########
export SSARAHOME=${PARENTDIR}/3rdparty/SSARA
export PATH=${PATH}:${SSARAHOME}
# 8/2018: temporarily add ssara_ASF until ASF features are included into Unavco's ssara
export SSARA_ASF=${PARENTDIR}/sources/ssara_ASF
export PATH=${PATH}:${SSARA_ASF}

############ FOR HDF5 LIBRARY ###########
export HDF5HOME=${PARENTDIR}/3rdparty/hdf5/hdf5-1.8.16
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${HDF5HOME}/hdf5/lib

###############  Python  ################
export PYTHONPATH=${PYTHONPATH-""}
export PYTHON2DIR=${PARENTDIR}/3rdparty/python/anaconda2
export PYTHON3DIR=${PARENTDIR}/3rdparty/python/anaconda36
#export PATH=${PATH}:${PYTHON2DIR}/bin
export PATH=${PYTHON3DIR}/bin:${PYTHON2DIR}/bin:${PATH}

############ FOR GDAL SOFTWARE #########
export GDALSOURCE=${PARENTDIR}/3rdparty/gdal/gdal-2.1.0
export GDALHOME=${PARENTDIR}/3rdparty/gdal/gdal-210_work
export LD_LIBRARY_PATH=${GDALHOME}/lib:${LD_LIBRARY_PATH}
export PATH=$GDALHOME/bin:${PATH}

############ FOR TIPPECANOE  #########
export PATH=${PATH}:${PARENTDIR}/3rdparty/tippecanoe/bin

############ FOR PySAR SOFTWARE  ########
export PYSAR_HOME=${PARENTDIR}/sources/PySAR
export PYTHONPATH=${PYTHONPATH}:${PYSAR_HOME}
export PATH=${PATH}:${PYSAR_HOME}/pysar:${PYSAR_HOME}/sh

############ FOR RSMAS coregistration SOFTWARE  ########
export PYTHONPATH=${PYTHONPATH}:${INT_SCR}

############ FOR PYAPS SOFTWARE #########
export GRIBAPI_DIR=${PARENTDIR}/3rdparty/grib_api/grib_api-1.9.18
export JASPER_DIR=${PARENTDIR}/3rdparty/jasper/jasper-1.900.1 
export PYGRIB_DIR=${PARENTDIR}/3rdparty/pygrib/pygrib-2.0.1 
export JPEG_DIR=${PARENTDIR}/3rdparty/jpeg/jpeg-9b 
export PNG_DIR=~/insarlab
export PATH=${PATH}:${GRIBAPI_DIR}/bin
export PYAPS_DIR=${PARENTDIR}/sources/PyAPS-1.1
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${GRIBAPI_DIR}/lib:${JPEG_DIR}/lib 
export PYTHONPATH=${PYTHONPATH}:${PYAPS_DIR}
export PYTHONPATH_RSMAS=${PYTHONPATH}

export OPERATIONS=${HOME}/insarlab/OPERATIONS
########################################

############ FOR NEW RSMAS SOFTWARE USING ISCE  ########
export RSMAS_ISCE
export RSMAS_ISCE=${PARENTDIR}/sources/rsmas_isce
############# SqueeSAR #####################
export SQUEESAR=${PARENTDIR}/sources/squeesar


#export PATH=${PATH}:${INT_BIN}:${INT_SCR}:${GAMMA_BIN}:${MSP_path}:${ISP_path}:${DIFF_path}:${LAT_path}:${DISP_path}:${MATLABHOME}/bin:${PARENTDIR}/sources/pitstk:${MAKEDEM_SCR}
export PATH=${PATH}:${INT_BIN}:${RSMAS_ISCE}:${INT_SCR}:${GAMMA_BIN}:${MSP_path}:${ISP_path}:${DIFF_path}:${LAT_path}:${DISP_path}:${MATLABHOME}/bin:${PARENTDIR}/sources/pitstk:${MAKEDEM_SCR}:${SQUEESAR}:${SQUEESAR}/gamma
 
### add path for gcc and gs ############
export PATH=${PARENTDIR}/3rdparty/bin:${PATH}

export PATH=${PARENTDIR}/3rdparty/gcc/4.8.3/bin:${PATH}
export LD_LIBRARY_PATH=${PARENTDIR}/3rdparty/gcc/4.8.3/lib64:${LD_LIBRARY_PATH}
if [ -n "${MANPATH}" ] 
then 
    export MANPATH=${PARENTDIR}/3rdparty/gcc/4.8.3/share/man:${MANPATH}
fi

if [ -n "${prompt}" ]
then
    echo "PARENTDIR:      " ${PARENTDIR}
    echo "ROIPACHOME:     " ${ROIPACHOME}
    echo "GAMMA_BIN:      " ${GAMMA_BIN}
    echo "GDALHOME:       " ${GDALHOME}
    echo "TIFFHOME:       " ${TIFFHOME}
    echo "GEOTIFFHOME:    " ${GEOTIFFHOME}
    echo "MDXHOME:        " ${MDXHOME}
    echo "GMTHOME:        " ${GMTHOME}
    echo "GETORBHOME:     " ${GETORBHOME}
    echo "IMAGEMAGICKHOME:" ${IMAGEMAGICKHOME}
    echo "PYTHON2DIR:     " ${PYTHON2DIR}
    echo "SSARAHOME:      " ${SSARAHOME}
    echo "HDF5HOME:       " ${HDF5HOME}
    echo "JASPER_DIR:     " ${JASPER_DIR}
    echo "GRIBAPI_DIR:    " ${GRIBAPI_DIR}
    echo "PYGRIB_DIR:     " ${PYGRIB_DIR}
fi
