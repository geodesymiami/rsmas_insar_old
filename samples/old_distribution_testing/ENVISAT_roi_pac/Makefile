SOURCEDIR=$(ROIPAC_TESTDATA)/ENVISAT_roi_pac
DESTDIR  =$(TESTBENCH)/ENVISAT_roi_pac

clean:
	mkdir -p $(DESTDIR)
	cd $(DESTDIR) ;  rm -rf 030103-030207def1_* SIM GEO log* list* 030103 030207 030103*.proc roi.proc
	rm -fr $(DESTDIR)

prepare:
	make clean
	mkdir -p $(DESTDIR)
	mkdir -p $(DESTDIR)/030103  ; cd $(DESTDIR)/030103 ; ln -s $(SOURCEDIR)/L0data/Env/356/030103/ASAR_IMAGERY . ; 
	mkdir -p $(DESTDIR)/030207  ; cd $(DESTDIR)/030207 ; ln -s $(SOURCEDIR)/L0data/Env/356/030207/ASAR_IMAGERY . ; 
	ln -s $(PWD)/030103-030207def1_HDR.proc $(PWD)/030103-030207def1_ODR.proc $(DESTDIR)

HDR:
	make clean
	make prepare
	cd $(DESTDIR)/030103 ; $(INT_SCR)/make_raw_envi.pl ASAR_IMAGERY HDR 030103
	cd $(DESTDIR)/030207 ; $(INT_SCR)/make_raw_envi.pl ASAR_IMAGERY HDR 030207
	cd $(DESTDIR) ; $(INT_SCR)/process_2pass.pl 030103-030207def1_HDR.proc
	cd $(DESTDIR)/030103-030207def1_HDR ;  display *unw.dem.thumb.jpg &

ODR:
	make clean
	make prepare
	cd $(DESTDIR)/030103 ; $(INT_SCR)/make_raw_envi.pl ASAR_IMAGERY ODR 030103
	cd $(DESTDIR)/030207 ; $(INT_SCR)/make_raw_envi.pl ASAR_IMAGERY ODR 030207
	cd $(DESTDIR) ; $(INT_SCR)/process_2pass.pl 030103-030207def1_ODR.proc
	cd $(DESTDIR)/030103-030207def1_ODR ;  display *unw.dem.thumb.jpg &

display: 
	cd $(DESTDIR)/030103-030207def1_HDR ;  display *unw.dem.thumb.jpg &
	cd $(DESTDIR)/030103-030207def1_ODR ;  display *unw.dem.thumb.jpg &

all:
	make clean
	make prepare
	make ODR
	make clean

allnoclean:
	make clean
	make prepare
	make ODR
	make clean
