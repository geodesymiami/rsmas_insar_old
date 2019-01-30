#!/bin/csh 
################################################
######## Account Information ###################
################################################
mkdir -p 3rdparty/accounts
######a### for pyaps ##############
mkdir -p 3rdparty/accounts/pyaps
cd 3rdparty/accounts/pyaps; cat >! model.cfg<<EOF
#The key to the new server for ECMWF
##Get it from https://software.ecmwf.int/wiki/display/WEBAPI/Accessing+ECMWF+data+servers+in+batch 
[ECMWF]
email = yzhang@rsmas.miami.edu
key = a5c4ee9113a4d191f176f1fedd26c0de 

#####Passwd and key for download from ecmwf.int. Old version.
[ECMWF_old]
email = yzhang@rsmas.miami.edu
key = a5c4ee9113a4d191f176f1fedd26c0de 

#####Passwd and key for download from ucar
[ERA]
email = yzhang@rsmas.miami.edu
key = geodesyrocks

[NARR]


[MERRA]

EOF
cd -

######### for SSARA ##############
mkdir -p 3rdparty/accounts/SSARA
cd 3rdparty/accounts/SSARA; cat >! password_config.py<<EOF
unavuser="amelung"
unavpass="MonMar16"

asfuser="famelung"
asfpass="Falk@1234:"

eossouser="famelung"
eossopass="Falk@1234:"

insaruser="insaradmin"
insarpass="Insar123"
EOF
cd -

######### copy to right place ##############

set characterCount=`wc -m 3rdparty/SSARA/password_config.py`

if (  $characterCount[1] == 75) then
      echo "Use default password_config.py for SSARA (because existing file lacks passwords)"
      cp 3rdparty/accounts/SSARA/password_config.py 3rdparty/SSARA
   else
      echo File password_config.py not empty - kept unchanged
endif

if (! -f 3rdparty/PyAPS/pyaps/model.cfg) then
      echo Use default model.cfg for ECMWF download with PyAPS
      cp 3rdparty/accounts/pyaps/model.cfg 3rdparty/PyAPS/pyaps
   else
      echo File model.cfg exists already - kept unchanged
endif

######### generate .netrc for dem.py if it does not exist ##############
if (! -f ~/.netrc) then
echo "Creating .netrc file for DEM data download"
cat >! ~/.netrc<<EOF
machine urs.earthdata.nasa.gov
	login emrehavazli
	password 4302749%Eh
EOF
endif
