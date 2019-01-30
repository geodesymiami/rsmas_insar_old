LOCALDIR         = $(notdir $(PWD))
TEMPLATEBASENAME = $(basename $(shell ls *.template))

DESTDIR          = $(TESTBENCH)/$(LOCALDIR)
SOURCEDIR        = $(ROIPAC_TESTDATA)/$(LOCALDIR)
DEMDIR           = $(TESTBENCH)/$(LOCALDIR)/ROIPAC_DEMS

clean:
	rm -fr  $(DESTDIR)

prepare:
	mkdir -p $(DESTDIR)
	ln -s $(SOURCEDIR)/* $(DESTDIR)
	cp $(TEMPLATEBASENAME).template $(DESTDIR)

process:
	cd $(DESTDIR); $(INT_SCR)/process_rsmas.pl $(DESTDIR)/$(TEMPLATEBASENAME).template WorkDir=$(DESTDIR) --nogetsar

preparewithgetsar:
	mkdir -p $(DESTDIR)
	cp $(TEMPLATEBASENAME).template $(DESTDIR)

processwithgetsar:
	cd $(DESTDIR); $(INT_SCR)/process_rsmas.pl $(DESTDIR)/$(TEMPLATEBASENAME).template WorkDir=$(DESTDIR)

display: 
	summary.pl $(DESTDIR)/process/$(TEMPLATEBASENAME)/DONE/P*

test:
	if test -d "$(DESTDIR)/process/$(TEMPLATEBASENAME)/DONE"; then echo $(LOCALDIR) : TESTING SUCCESSFUL, WELL DONE !!; else echo $(LOCALDIR) : TESTING FAILED, KEEP CODING !!; fi;

all:
	make clean
	make prepare
	make process
	make -s test

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
