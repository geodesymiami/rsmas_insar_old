DESTDIR  =$(TESTBENCH)/ERS_roi_pac
SOURCEDIR=$(ROIPAC_TESTDATA)/ERS_roi_pac

clean:
	mkdir -p $(DESTDIR)
	cd $(DESTDIR) ;  rm -rf 970812-971125def3_ODR 970812-971125def3_HDR SIM GEO log* list* 970812 971125 970812*.proc roi.proc
	rm -fr  $(DESTDIR)

prepare:
	make clean
	mkdir -p $(DESTDIR)
	mkdir -p $(DESTDIR)/970812  ; cd $(DESTDIR)/970812 ; ln -s $(SOURCEDIR)/L0data/Ers/213/970812/e2_12091_2853.raw IMAGERY ; \
							ln -s $(SOURCEDIR)/L0data/Ers/213/970812/e2_12091_2853.ldr SARLEADER
	mkdir -p $(DESTDIR)/971125  ; cd $(DESTDIR)/971125 ; ln -s $(SOURCEDIR)/971125/e2_13594_2853.raw IMAGERY ; \
                                                        ln -s $(SOURCEDIR)/L0data/Ers/213/L0data/Ers/213/971125/e2_13594_2853.ldr SARLEADER
	ln -s $(PWD)/970812-971125def3_ODR.proc $(PWD)/970812-971125def3_HDR.proc $(PWD)/roi.proc $(DESTDIR)

raw:
	make clean
	make prepare
	cd $(DESTDIR)/970812 ; $(INT_SCR)/make_raw.pl HDR SARLEADER 970812
	cd $(DESTDIR)/971125 ; $(INT_SCR)/make_raw.pl HDR SARLEADER 971125

HDR:
	make raw
	cd $(DESTDIR) ; $(INT_SCR)/process_2pass.pl 970812-971125def3_HDR.proc 
	cd $(DESTDIR)/970812-971125def3_HDR ;  display *unw.dem.thumb.jpg &

ODR:
	make raw
	cd $(DESTDIR) ; $(INT_SCR)/process_2pass.pl 970812-971125def3_ODR.proc 
	cd $(DESTDIR)/970812-971125def3_ODR ;  display *unw.dem.thumb.jpg &

display: 
	cd $(DESTDIR)/970812-971125def3_HDR ;  display *unw.dem.thumb.jpg &
	cd $(DESTDIR)/970812-971125def3_ODR ;  display *unw.dem.thumb.jpg &

all:
	make clean
	make prepare
	make HDR

allnoclean:
	make clean
	make prepare
	make HDR
	make ODR
	make display
