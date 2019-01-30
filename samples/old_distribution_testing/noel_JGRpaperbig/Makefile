LOCALDIR         = $(notdir $(PWD))
TEMPLATEBASENAME = $(basename $(shell ls *.template))

DESTDIR          = $(TESTBENCH)/$(LOCALDIR)
SOURCEDIR        = $(ROIPAC_TESTDATA)/$(LOCALDIR)
DEMDIR           = $(TESTBENCH)/$(LOCALDIR)/ROIPAC_DEMS

clean:
	rm -fr  $(DESTDIR)

prepare:
	mkdir -p $(DESTDIR)
	cp $(TEMPLATEBASENAME).template $(DESTDIR)
	ln -s $(SOURCEDIR)/ROIPAC_DEMS $(DESTDIR)
	ln -s $(SOURCEDIR)/L0data $(DESTDIR)

process:
	cd $(DESTDIR); $(INT_SCR)/process_rsmas.pl $(DESTDIR)/$(TEMPLATEBASENAME).template WorkDir=$(DESTDIR) --nogetsar

preparewithgetsar:
	mkdir -p $(DESTDIR)
	cp $(TEMPLATEBASENAME).template $(DESTDIR)

processwithgetsar:
	cd $(DESTDIR); $(INT_SCR)/process_rsmas.pl $(DESTDIR)/$(TEMPLATEBASENAME).template WorkDir=$(DESTDIR)

display: 
	summary.pl $(DESTDIR)/process/$(TEMPLATEBASENAME)/DONE/P*

test_slc2igram:
	if test -d "$(DESTDIR)/process/$(TEMPLATEBASENAME)/DONE";    then echo $@ $(LOCALDIR) : TESTING SUCCESSFUL, WELL DONE !!; else echo $@ $(LOCALDIR) : TESTING FAILED, KEEP CODING !!; fi;

test_raw2slc:
	if test -e "$(DESTDIR)/SLC/$(TEMPLATEBASENAME)/bl_list.txt"; then echo $@ $(LOCALDIR) : TESTING SUCCESSFUL, WELL DONE !!; else echo $@ $(LOCALDIR) : TESTING FAILED, KEEP CODING !!; fi;

all:
	make clean
	make prepare
	make process
	make -s test_slc2igram

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
