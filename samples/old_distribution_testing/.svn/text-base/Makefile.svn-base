.PHONY: default all clean NONE  ERS_roi_pac RSAT_vexint ENVISAT_roi_pac RSAT_fromSLC RSAT_fromSLC_models \
        ERS_roi_pac_time ERS_roi_pac_time1 ERS_roi_pac_time2 ERS_roi_pac_time4 ERS_roi_pac_time8 \
        RSAT_vexint_time RSAT_vexint_time1 RSAT_vexint_time2 RSAT_vexint_time4 RSAT_vexint_time8 \
        process_rsmas_Env process_rsmas_Ers-esa process_rsmas_Ers-winsar\
        
TESTDATASET=RSAT_vexint

ERS_roi_pac:
	cd $@ ; make HDR

RSAT_vexint:
	cd $@  ; make all

ENVISAT_roi_pac:
	cd $@  ; make all

RSAT_fromSLC:
	cd $@  ; make all

RSAT_fromSLC_models:
	cd $@  ; make all

process_rsmas_Env:
	cd $@  ; make all

process_rsmas_Ers-esa:
	cd $@  ; make all

process_rsmas_Ers-winsar:
	cd $@  ; make all

process_rsmas_multi_Env:
	cd $@  ; make -f ../Makefile_default

process_rsmas_Env_Gala:
	cd $@  ; make all

NONE:

default: 
	echo $(TESTDATASET)
	make $(TESTDATASET) 

clean:
	cd ERS_roi_pac ; make clean
	cd RSAT_vexint ; make clean
	cd ENVISAT_roi_pac ; make clean

all:
	make ERS_roi_pac &
	make RSAT_vexint  &
	make ENVISAT_roi_pac  &
	make RSAT_fromSLC  &
	make RSAT_fromSLC_models  &
	
#################################################################################
# The following is for benchmarking several roi_pac runs in parallel
# This could be improved so that no name are hardwired and we give the number of
# parallel runs  in the command line.
# Also a summary statement shoudl be displayed instead of multiple time statements
#####################
ERS_roi_pac_time1:
	@echo "Timing 1 ERS_roi_pac run ...." 
	cd ERS_roi_pac ; time make HDR DESTDIR=$(TESTBENCH)/ERS_roi_pac  >& /dev/null 
ERS_roi_pac_time2:
	@echo "Timing 2 ERS_roi_pac runs ...."

NONE:

default: 
	echo $(TESTDATASET)
	make $(TESTDATASET) 

clean:
	cd ERS_roi_pac ; make clean
	cd RSAT_vexint ; make clean
	cd ENVISAT_roi_pac ; make clean

all:
	make ERS_roi_pac &
	make RSAT_vexint  &
	make ENVISAT_roi_pac  &
	make RSAT_fromSLC  &
	make RSAT_fromSLC_models  &
	
#################################################################################
# The following is for benchmarking several roi_pac runs in parallel
# This could be improved so that no name are hardwired and we give the number of
# parallel runs  in the command line.
# Also a summary statement shoudl be displayed instead of multiple time statements
#####################
ERS_roi_pac_time1:
	@echo "Timing 1 ERS_roi_pac run ...." 
	cd ERS_roi_pac ; time make HDR DESTDIR=$(TESTBENCH)/ERS_roi_pac  >& /dev/null 
ERS_roi_pac_time2:
	@echo "Timing 2 ERS_roi_pac runs ...."
	cd ERS_roi_pac ; time make HDR DESTDIR=$(TESTBENCH)/ERS_roi_pac1 >& /dev/null &
	cd ERS_roi_pac ; time make HDR DESTDIR=$(TESTBENCH)/ERS_roi_pac2 >& /dev/null 
ERS_roi_pac_time4:
	@echo "Timing 4 ERS_roi_pac runs ...."
	cd ERS_roi_pac ; time make HDR DESTDIR=$(TESTBENCH)/ERS_roi_pac1 >& /dev/null &
	cd ERS_roi_pac ; time make HDR DESTDIR=$(TESTBENCH)/ERS_roi_pac2 >& /dev/null &
	cd ERS_roi_pac ; time make HDR DESTDIR=$(TESTBENCH)/ERS_roi_pac3 >& /dev/null &
	cd ERS_roi_pac ; time make HDR DESTDIR=$(TESTBENCH)/ERS_roi_pac4 >& /dev/null 
ERS_roi_pac_time5:
	@echo "Timing 5 ERS_roi_pac runs ...."
	cd ERS_roi_pac ; time make HDR DESTDIR=$(TESTBENCH)/ERS_roi_pac1 >& /dev/null &
	cd ERS_roi_pac ; time make HDR DESTDIR=$(TESTBENCH)/ERS_roi_pac2 >& /dev/null &
	cd ERS_roi_pac ; time make HDR DESTDIR=$(TESTBENCH)/ERS_roi_pac3 >& /dev/null &
	cd ERS_roi_pac ; time make HDR DESTDIR=$(TESTBENCH)/ERS_roi_pac4 >& /dev/null &
	cd ERS_roi_pac ; time make HDR DESTDIR=$(TESTBENCH)/ERS_roi_pac5 >& /dev/null 
ERS_roi_pac_time6:
	@echo "Timing 6 ERS_roi_pac runs ...."
	cd ERS_roi_pac ; time make HDR DESTDIR=$(TESTBENCH)/ERS_roi_pac1 >& /dev/null &
	cd ERS_roi_pac ; time make HDR DESTDIR=$(TESTBENCH)/ERS_roi_pac2 >& /dev/null &
	cd ERS_roi_pac ; time make HDR DESTDIR=$(TESTBENCH)/ERS_roi_pac3 >& /dev/null &
	cd ERS_roi_pac ; time make HDR DESTDIR=$(TESTBENCH)/ERS_roi_pac4 >& /dev/null &
	cd ERS_roi_pac ; time make HDR DESTDIR=$(TESTBENCH)/ERS_roi_pac5 >& /dev/null &
	cd ERS_roi_pac ; time make HDR DESTDIR=$(TESTBENCH)/ERS_roi_pac6 >& /dev/null 
ERS_roi_pac_time7:
	@echo "Timing 7 ERS_roi_pac runs ...."
	cd ERS_roi_pac ; time make HDR DESTDIR=$(TESTBENCH)/ERS_roi_pac1 >& /dev/null &
	cd ERS_roi_pac ; time make HDR DESTDIR=$(TESTBENCH)/ERS_roi_pac2 >& /dev/null &
	cd ERS_roi_pac ; time make HDR DESTDIR=$(TESTBENCH)/ERS_roi_pac3 >& /dev/null &
	cd ERS_roi_pac ; time make HDR DESTDIR=$(TESTBENCH)/ERS_roi_pac4 >& /dev/null &
	cd ERS_roi_pac ; time make HDR DESTDIR=$(TESTBENCH)/ERS_roi_pac5 >& /dev/null &
	cd ERS_roi_pac ; time make HDR DESTDIR=$(TESTBENCH)/ERS_roi_pac6 >& /dev/null &
	cd ERS_roi_pac ; time make HDR DESTDIR=$(TESTBENCH)/ERS_roi_pac7 >& /dev/null 
ERS_roi_pac_time8:
	@echo "Timing 8 ERS_roi_pac runs ...."
	cd ERS_roi_pac ; time make HDR DESTDIR=$(TESTBENCH)/ERS_roi_pac1 >& /dev/null &
	cd ERS_roi_pac ; time make HDR DESTDIR=$(TESTBENCH)/ERS_roi_pac2 >& /dev/null &
	cd ERS_roi_pac ; time make HDR DESTDIR=$(TESTBENCH)/ERS_roi_pac3 >& /dev/null &
	cd ERS_roi_pac ; time make HDR DESTDIR=$(TESTBENCH)/ERS_roi_pac4 >& /dev/null &
	cd ERS_roi_pac ; time make HDR DESTDIR=$(TESTBENCH)/ERS_roi_pac5 >& /dev/null &
	cd ERS_roi_pac ; time make HDR DESTDIR=$(TESTBENCH)/ERS_roi_pac6 >& /dev/null &
	cd ERS_roi_pac ; time make HDR DESTDIR=$(TESTBENCH)/ERS_roi_pac7 >& /dev/null &
	cd ERS_roi_pac ; time make HDR DESTDIR=$(TESTBENCH)/ERS_roi_pac8 >& /dev/null 
ERS_roi_pac_time:
	@echo "Timing 1,2,4 and 8 ERS_roi_pac runs ...."
	make ERS_roi_pac_time1
	make ERS_roi_pac_time4
	make ERS_roi_pac_time5
	make ERS_roi_pac_time6
	make ERS_roi_pac_time7
	make ERS_roi_pac_time8
######################
RSAT_vexint_time1:
	@echo "Timing 1 RSAT_vexint run ...."
	cd RSAT_vexint ; time make HDR DESTDIR=$(TESTBENCH)/RSAT_vexint  >& /dev/null 
RSAT_vexint_time2:
	@echo "Timing 2 RSAT_vexint runs ...."
	cd RSAT_vexint ; time make HDR DESTDIR=$(TESTBENCH)/RSAT_vexint1 >& /dev/null &
	cd RSAT_vexint ; time make HDR DESTDIR=$(TESTBENCH)/RSAT_vexint2 >& /dev/null 
RSAT_vexint_time4:
	@echo "Timing 4 RSAT_vexint runs ...."
	cd RSAT_vexint ; time make HDR DESTDIR=$(TESTBENCH)/RSAT_vexint1 >& /dev/null &
	cd RSAT_vexint ; time make HDR DESTDIR=$(TESTBENCH)/RSAT_vexint2 >& /dev/null &
	cd RSAT_vexint ; time make HDR DESTDIR=$(TESTBENCH)/RSAT_vexint3 >& /dev/null & 
	cd RSAT_vexint ; time make HDR DESTDIR=$(TESTBENCH)/RSAT_vexint4 >& /dev/null 
RSAT_vexint_time8:
	@echo "Timing 8 RSAT_vexint runs ...."
	cd RSAT_vexint ; time make HDR DESTDIR=$(TESTBENCH)/RSAT_vexint1 >& /dev/null &
	cd RSAT_vexint ; time make HDR DESTDIR=$(TESTBENCH)/RSAT_vexint2 >& /dev/null &
	cd RSAT_vexint ; time make HDR DESTDIR=$(TESTBENCH)/RSAT_vexint3 >& /dev/null &
	cd RSAT_vexint ; time make HDR DESTDIR=$(TESTBENCH)/RSAT_vexint4 >& /dev/null &
	cd RSAT_vexint ; time make HDR DESTDIR=$(TESTBENCH)/RSAT_vexint5 >& /dev/null &
	cd RSAT_vexint ; time make HDR DESTDIR=$(TESTBENCH)/RSAT_vexint6 >& /dev/null &
	cd RSAT_vexint ; time make HDR DESTDIR=$(TESTBENCH)/RSAT_vexint7 >& /dev/null &
	cd RSAT_vexint ; time make HDR DESTDIR=$(TESTBENCH)/RSAT_vexint8 >& /dev/null 
######################
RSAT_vexint_time:
	@echo "Timing 1,2,4 and 8 ERS_roi_pac runs ...."
	make RSAT_vexint_time1
	make RSAT_vexint_time2
	make RSAT_vexint_time4
	make RSAT_vexint_time8
######################
process_rsmas_Env_time1:
	@echo "Timing 1 process_rsmas_Env run ...."
	cd process_rsmas_ENV ; time make all DESTDIR=$(TESTBENCH)/process_rsmas_Env  >& /dev/null 
