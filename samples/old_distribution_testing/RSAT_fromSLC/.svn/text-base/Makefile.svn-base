DESTDIR  =$(TESTBENCH)/RSAT_fromSLC
SOURCEDIR=$(ROIPAC_TESTDATA)/RSAT_fromSLC
PROJECT=HawaiiRsatD6

clean:
	mkdir -p $(DESTDIR)
	cd $(DESTDIR) ;  rm -rf PO* *template GEO SIM DEM MODELS
	rm -fr  $(DESTDIR)

prepare:
	make clean
	mkdir -p $(DESTDIR)
	mkdir -p $(DESTDIR)/PO_test
	ln -s $(PWD)/*template $(DESTDIR)
	ln -s $(SOURCEDIR)/PO*/* $(DESTDIR)/PO_test
	ln -s $(SOURCEDIR)/DEM $(DESTDIR)
	ln -s $(SOURCEDIR)/MODELS $(DESTDIR)

all: 
	make clean
	make prepare
	cd $(DESTDIR) ;  $(INT_SCR)/vex2roi_pac.pl --slcs --nolocalproc PO*
	cd $(DESTDIR)/PO_test ; display *unw.dem.thumb.jpg &
	make clean  

display: 
	cd $(DESTDIR)/PO_test ; display *unw.dem.thumb.jpg &
