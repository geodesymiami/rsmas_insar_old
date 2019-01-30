DESTDIR  =$(TESTBENCH)/RSAT_vexint
SOURCEDIR=$(ROIPAC_TESTDATA)/RSAT_vexint
PROJECT=HawaiiRsatD1_vShortTerm

clean:
	mkdir -p $(DESTDIR)
	cd $(DESTDIR) ;  rm -rf PO* *template GEO SIM DEM
	rm -fr  $(DESTDIR)

prepare:
	make clean
	mkdir -p $(DESTDIR)
	mkdir -p $(DESTDIR)/PO_test
	ln -s $(PWD)/*template $(DESTDIR)
	ln -s $(SOURCEDIR)/PO*/$(PROJECT)* $(SOURCEDIR)/PO*/.byteswap_flag.rsc $(DESTDIR)/PO_test
	ln -s $(SOURCEDIR)/DEM $(DESTDIR)

all: 
	make clean
	make prepare
	cd $(DESTDIR) ;  $(INT_SCR)/vex2roi_pac.pl --getpara_SLC --nolocalproc PO*
	cd $(DESTDIR)/PO_test ; display *unw.dem.thumb.jpg &

display: 
	cd $(DESTDIR)/PO_test ; display *unw.dem.thumb.jpg &
