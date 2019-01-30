.PHONY: WellsquakeT399EnvD2.template ChamanT256F585EnvA6.template SinabungT495F50AlosA.template CotopaxiT119TsxA.template PopoT263Rsat2HHD.template CotopaxiT58CskD.template KilaueaSM3T89F380Alos2A.template KirishimaT79F247Jers.template gammaWellsquakeT399EnvD2.template gammaSinabungT495F50AlosA.template

WellsquakeT399EnvD2.template ChamanT256F585EnvA6.template gammaWellsquakeT399EnvD2.template:
	TEMPLATEBASENAME=$(basename $@)
	rm -rf   $(SCRATCHDIR)/$(basename $@)
	mkdir -p $(SCRATCHDIR)/$(basename $@)
	cp -r $(PARENTDIR)/data/testdata/roi_pac/$(basename $@)/DEMDIR $(SCRATCHDIR)/$(basename $@)
	cp -r $(PARENTDIR)/data/testdata/roi_pac/$(basename $@)/L0DIR  $(SCRATCHDIR)/$(basename $@)/RAW
	process_rsmas.pl $(SAMPLESDIR)/$@  --startslc  &

SinabungT495F50AlosA.template gammaSinabungT495F50AlosA.template:
	TEMPLATEBASENAME=$(basename $@)
	rm -rf   $(SCRATCHDIR)/$(basename $@)
	mkdir -p $(SCRATCHDIR)/$(basename $@)
	mkdir -p $(SCRATCHDIR)/$(basename $@)/DOWNLOADDIR
	cp -r $(PARENTDIR)/data/testdata/roi_pac/$(basename $@)/DEMDIR $(SCRATCHDIR)/$(basename $@)
	cp -r $(PARENTDIR)/data/testdata/roi_pac/$(basename $@)/DOWNLOADDIR/*  $(SCRATCHDIR)/$(basename $@)/DOWNLOADDIR
	rm $(SCRATCHDIR)/$(basename $@)/DOWNLOADDIR/ALPSRP{1,2}*
	process_rsmas.pl $(SAMPLESDIR)/$@  --startprepare &

CotopaxiT119TsxA.template CotopaxiT58CskD.template PopoT263Rsat2HHD.template KilaueaSM3T89F380Alos2A.template KirishimaT79F247Jers.template:
	TEMPLATEBASENAME=$(basename $@)
	rm -rf   $(SCRATCHDIR)/$(basename $@)
	mkdir -p $(SCRATCHDIR)/$(basename $@)
	mkdir -p $(SCRATCHDIR)/$(basename $@)/DOWNLOADDIR
	#ln -sf $(PARENTDIR)/data/testdata/roi_pac/$(basename $@)/DEMDIR $(SCRATCHDIR)/$(basename $@)
	#ln -sf $(PARENTDIR)/data/testdata/roi_pac/$(basename $@)/DOWNLOADDIR/*  $(SCRATCHDIR)/$(basename $@)/DOWNLOADDIR
	cp -r $(PARENTDIR)/data/testdata/roi_pac/$(basename $@)/DEMDIR $(SCRATCHDIR)/$(basename $@)
	cp -r $(PARENTDIR)/data/testdata/roi_pac/$(basename $@)/DOWNLOADDIR/*  $(SCRATCHDIR)/$(basename $@)/DOWNLOADDIR
	process_rsmas.pl $(SAMPLESDIR)/$@  --startprepare &
