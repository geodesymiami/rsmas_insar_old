TEMPLATEBASENAME = $(basename $(shell ls *.template))
LOCALDIR         = $(notdir $(PWD))

DESTDIR          = $(TESTBENCH)/$(LOCALDIR)
SOURCEDIR        = $(ROIPAC_TESTDATA)/$(LOCALDIR)
DEMDIR           = $(TESTBENCH)/$(LOCALDIR)/ROIPAC_DEMS

clean:
	rm -fr  $(DESTDIR)

prepare:
	mkdir -p $(DESTDIR)
	cp $(TEMPLATEBASENAME).template $(DESTDIR)
	ln -sf $(SOURCEDIR)/ROIPAC_DEMS $(DESTDIR)
	ln -sf $(SOURCEDIR)/L0data $(DESTDIR)

process:    
	cd $(DESTDIR); 
	$(INT_SCR)/process_RSAT_TEST.py $(DESTDIR)/$(TEMPLATEBASENAME).template 

preparewithgetsar:
	mkdir -p $(DESTDIR)
	cp $(TEMPLATEBASENAME).template $(DESTDIR)

processwithgetsar:
	cd $(DESTDIR); $(INT_SCR)/process_RSAT_TEST.py $(DESTDIR)/$(TEMPLATEBASENAME).template

display: 
	summary.pl $(DESTDIR)/process/$(TEMPLATEBASENAME)/DONE/P*

all:
	make clean
	make prepare
	make process

raw2slc:
	make clean
	make prepare
	cd $(DESTDIR); $(INT_SCR)/raw2slc.pl            $(DESTDIR)/$(TEMPLATEBASENAME).template WorkDir=$(DESTDIR)
	cd $(DESTDIR); $(INT_SCR)/createBaselineList.pl $(DESTDIR)/$(TEMPLATEBASENAME).template WorkDir=$(DESTDIR)
	make -s test_raw2slc

slc2igram:
	make clean
	make prepare
	ln -s $(SOURCEDIR)/SLC $(DESTDIR)
	cd $(DESTDIR); $(INT_SCR)/SelectPairs.pl $(DESTDIR)/$(TEMPLATEBASENAME).template WorkDir=$(DESTDIR)
	make -s test_slc2igram

allcont:
	make process
	make -s test

alldisplay:
	make clean
	make prepare
	make process
	make display

allwithgetsar:
	make clean
	make preparewithgetsar
	make processwithgetsar
	make -s test
