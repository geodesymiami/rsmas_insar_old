#!/usr/bin/env python3
########################
#Author: Sara Mirzaee
#######################

import os, glob , sys
import subprocess as subp
import  datetime, glob
import copy
import shutil


noMCF = 'False'
defoMax = '2'
maxNodes = 72

###################################

class config(object):
    """
       A class representing the config file
    """
    def __init__(self, outname):
        self.f= open(outname,'w')
        self.f.write('[Common]'+'\n')
        self.f.write('')
        self.f.write('##########################'+'\n')

    def configure(self,inps):
        for k in inps.__dict__.keys():
            setattr(self, k, inps.__dict__[k])
        self.plot = 'False'
        self.misreg_az = None
        self.misreg_rng = None
        self.multilook_tool = None
        self.no_data_value = None
        self.cleanup = None ###SSS 7/2018: clean-up fine*int, if specified.


    def crop_sentinel(self, function):
        self.f.write('###################################' + '\n')
        self.f.write(function + '\n')
        self.f.write('crop_sentinel : ' + '\n')
        self.f.write('input : ' + self.input + '\n')
        self.f.write('output : ' + self.output + '\n')
        self.f.write('bbox : ' + self.bbox + '\n')
        self.f.write('multilook : ' + self.multi_look + '\n')
        self.f.write('range_looks : ' + self.rangeLooks + '\n')
        self.f.write('azimuth_looks : ' + self.azimuthLooks + '\n')
        self.f.write('multilook_tool : ' + self.multilook_tool + '\n')

    def create_patch(self, function):
        self.f.write('###################################' + '\n')
        self.f.write(function + '\n')
        self.f.write('create_patch : ' + '\n')
        self.f.write('slc_dir : ' + self.slcDir + '\n')
        self.f.write('squeesar_dir : ' + self.sqDir + '\n')
        self.f.write('patch_size : ' + self.patchSize + '\n')
        self.f.write('range_window : ' + self.rangeWindow + '\n')
        self.f.write('azimuth_window : ' + self.azimuthWindow + '\n')


    def phase_link(self, function):
        self.f.write('###################################' + '\n')
        self.f.write(function + '\n')
        self.f.write('PSQ_sentinel : ' + '\n')
        self.f.write('patch_dir : ' + self.patchDir + '\n')
        self.f.write('range_window : ' + self.rangeWindow + '\n')
        self.f.write('azimuth_window : ' + self.azimuthWindow + '\n')
        self.f.write('plmethod : ' + self.plmethod + '\n')


    def generate_igram(self, function):
        self.f.write('###################################' + '\n')
        self.f.write(function + '\n')
        self.f.write('generate_ifgram_sq : ' + '\n')
        self.f.write('squeesar_dir : ' + self.sqDir + '\n')
        self.f.write('ifg_dir : ' + self.ifgDir + '\n')
        self.f.write('ifg_index : ' + self.ifgIndex + '\n')
        self.f.write('range_window : ' + self.rangeWindow + '\n')
        self.f.write('azimuth_window : ' + self.azimuthWindow + '\n')
        self.f.write('acquisition_number : ' + self.acq_num + '\n')
        self.f.write('range_looks : ' + self.rangeLooks + '\n')
        self.f.write('azimuth_looks : ' + self.azimuthLooks + '\n')
        if 'geom_master' in self.ifgDir:
            self.f.write('plmethod : ' + self.plmethod + '\n')

    def unwrap(self, function):
        self.f.write('###################################'+'\n')
        self.f.write(function + '\n')
        self.f.write('unwrap : ' + '\n')
        self.f.write('ifg : ' + self.ifgName + '\n')
        self.f.write('unw : ' + self.unwName + '\n')
        self.f.write('coh : ' + self.cohName + '\n')
        self.f.write('nomcf : ' + self.noMCF + '\n')
        self.f.write('master : ' + self.master + '\n')
        #self.f.write('defomax : ' + self.defoMax + '\n')
        self.f.write('alks : ' + self.rangeLooks + '\n')
        self.f.write('rlks : ' + self.azimuthLooks + '\n')
        self.f.write('method : ' + self.unwMethod + '\n')

    def unwrapSnaphu(self, function):
        self.f.write('###################################'+'\n')
        self.f.write(function + '\n')
        self.f.write('unwrapSnaphu : ' + '\n')
        self.f.write('ifg : ' + self.ifgName + '\n')
        self.f.write('unw : ' + self.unwName + '\n')
        self.f.write('coh : ' + self.cohName + '\n')
        self.f.write('nomcf : ' + self.noMCF + '\n')
        self.f.write('master : ' + self.master + '\n')
        #self.f.write('defomax : ' + self.defoMax + '\n')
        self.f.write('alks : ' + self.rangeLooks + '\n')
        self.f.write('rlks : ' + self.azimuthLooks + '\n')

    def timeseries(self, function):
        self.f.write('###################################' + '\n')
        self.f.write(function + '\n')
        self.f.write('plApp : ' + '\n')
        self.f.write('template : ' + self.template + '\n')
        
        
    def finalize(self):
        self.f.close()
        
   
################################################

class run(object):
    """
       A class representing a run which may contain several functions
    """
    #def __init__(self):

    def configure(self, inps, runName):
        for k in inps.__dict__.keys():
            setattr(self, k, inps.__dict__[k])
        self.runDir = os.path.join(self.work_dir, 'run_files_SQ')
        if not os.path.exists(self.runDir):
            os.makedirs(self.runDir)

        self.run_outname = os.path.join(self.runDir, runName)
        print ('writing ', self.run_outname)

        self.config_path = os.path.join(self.work_dir,'configs_SQ')
        if not os.path.exists(self.config_path):
            os.makedirs(self.config_path)

        self.runf= open(self.run_outname,'w')



    def cropMergedSlc(self, acquisitions, inps):
        for slc in acquisitions:
            cropDir = os.path.join(self.work_dir, 'merged/SLC/' + slc)
            configName = os.path.join(self.config_path, 'config_crop_' + slc)
            configObj = config(configName)
            configObj.configure(self)
            configObj.input = os.path.join(cropDir, slc +'.slc.full')
            configObj.output = os.path.join(cropDir, slc + '.slc')
            configObj.bbox = inps.bbox_rdr
            configObj.multi_look = 'False'
            configObj.rangeLooks = inps.rangeLooks
            configObj.azimuthLooks = inps.azimuthLooks
            configObj.multilook_tool = 'gdal'
            configObj.crop_sentinel('[Function-1]')
            configObj.finalize()
            self.runf.write(self.text_cmd + 'SQWrapper.py -c ' + configName + '\n')

        list_geo = ['lat', 'lon', 'los', 'hgt', 'shadowMask', 'incLocal']
        multiookToolDict = {'lat*rdr': 'gdal', 'lon*rdr': 'gdal', 'los*rdr': 'gdal', 'hgt*rdr': "gdal",
                            'shadowMask*rdr': "isce", 'incLocal*rdr': "gdal"}
        for item in list_geo:
            pattern = item+'*rdr'
            geoDir = os.path.join(self.work_dir, 'merged/geom_master/')
            configName = os.path.join(self.config_path, 'config_crop_' + item)
            configObj = config(configName)
            configObj.configure(self)
            configObj.input = os.path.join(geoDir, item + '.rdr.full')
            configObj.output = os.path.join(geoDir, item + '.rdr')
            configObj.bbox = inps.bbox_rdr
            configObj.multi_look = 'False'
            configObj.rangeLooks = inps.rangeLooks
            configObj.azimuthLooks = inps.azimuthLooks
            configObj.multilook_tool = multiookToolDict[pattern]
            configObj.crop_sentinel('[Function-1]')
            configObj.finalize()
            self.runf.write(self.text_cmd + 'SQWrapper.py -c ' + configName + '\n')


    def createPatch(self, inps):
        configName = os.path.join(self.config_path, 'config_create_patch')
        configObj = config(configName)
        configObj.configure(self)
        configObj.slcDir = inps.slc_dirname
        configObj.sqDir = inps.squeesar_dir
        configObj.patchSize = inps.patch_size
        configObj.rangeWindow = inps.range_window
        configObj.azimuthWindow = inps.azimuth_window
        configObj.create_patch('[Function-1]')
        configObj.finalize()
        self.runf.write(self.text_cmd + 'SQWrapper.py -c ' + configName + '\n')


    def phaseLinking(self, inps):

        for patch in inps.patch_list:
            configName = os.path.join(self.config_path, 'config_phase_link_PATCH'+patch)
            configObj = config(configName)
            configObj.configure(self)
            configObj.patchDir = os.path.join(inps.squeesar_dir,'PATCH'+patch)
            configObj.rangeWindow = inps.range_window
            configObj.azimuthWindow = inps.azimuth_window
            configObj.plmethod = inps.plmethod
            configObj.phase_link('[Function-1]')
            configObj.finalize()
            self.runf.write(self.text_cmd + 'SQWrapper.py -c ' + configName + '\n')


    def generateIfg(self, inps, acquisitions):
        ifgram_dir = os.path.dirname(inps.slc_dirname) + '/interferograms'
        if not os.path.isdir(ifgram_dir):
            os.mkdir(ifgram_dir)
        index = 0
        for ifg in acquisitions[1::]:
            index += 1
            configName = os.path.join(self.config_path, 'config_generate_ifgram_{}_{}'.format(acquisitions[0],ifg))
            configObj = config(configName)
            configObj.configure(self)
            configObj.sqDir = inps.squeesar_dir
            configObj.ifgDir = os.path.join(ifgram_dir, '{}_{}'.format(acquisitions[0],ifg))
            configObj.ifgIndex = str(index)
            configObj.rangeWindow = inps.range_window
            configObj.azimuthWindow = inps.azimuth_window
            configObj.acq_num = str(len(acquisitions))
            configObj.rangeLooks = inps.rangeLooks
            configObj.azimuthLooks = inps.azimuthLooks
            configObj.generate_igram('[Function-1]')
            configObj.finalize()
            self.runf.write(self.text_cmd + 'SQWrapper.py -c ' + configName + '\n')
        configName = os.path.join(self.config_path, 'config_generate_quality_map')
        configObj = config(configName)
        configObj.configure(self)
        configObj.sqDir = inps.squeesar_dir
        configObj.ifgDir = inps.geo_master_dir
        configObj.ifgIndex = str(0)
        configObj.rangeWindow = inps.range_window
        configObj.azimuthWindow = inps.azimuth_window
        configObj.acq_num = str(len(acquisitions))
        configObj.rangeLooks = inps.rangeLooks
        configObj.azimuthLooks = inps.azimuthLooks
        configObj.plmethod = inps.plmethod
        configObj.generate_igram('[Function-1]')
        configObj.finalize()
        self.runf.write(self.text_cmd + 'SQWrapper.py -c ' + configName + '\n')

    def unwrap(self, inps, pairs):
        for pair in pairs:
            master = pair[0]
            slave = pair[1]
            mergedDir = os.path.join(self.work_dir, 'merged/interferograms/' + master + '_' + slave)
            configName = os.path.join(self.config_path ,'config_igram_unw_' + master + '_' + slave)
            configObj = config(configName)
            configObj.configure(self)
            configObj.ifgName = os.path.join(mergedDir,'filt_fine.int')
            configObj.cohName = os.path.join(mergedDir,'filt_fine.cor')
            configObj.unwName = os.path.join(mergedDir,'filt_fine.unw')
            configObj.noMCF = noMCF
            configObj.master = os.path.join(self.work_dir,'master')
            configObj.defoMax = defoMax
            configObj.unwMethod = inps.unwMethod
            configObj.unwrap('[Function-1]')
            configObj.finalize()
            self.runf.write(self.text_cmd + 'SQWrapper.py -c ' + configName + '\n')


    def plAPP(self,inps):
        configName = os.path.join(self.config_path, 'config_corrections_and_velocity')
        configObj = config(configName)
        configObj.configure(self)
        configObj.template = inps.customTemplateFile
        configObj.timeseries('[Function-1]')
        configObj.finalize()
        self.runf.write(self.text_cmd + 'SQWrapper.py -c ' + configName + '\n')

################################################

    def create_wbdmask(self, pairs): ###SSS 7/2018: Generate water mask.
        configName = os.path.join(self.config_path ,'config_make_watermsk')
        configObj = config(configName)
        configObj.configure(self)
        if self.layovermsk:  ###SSS 7/2018: layover mask, if specified.
            configObj.layovermsk = 'True'
        if self.watermsk:  ###SSS 7/2018: water mask, if specified.
            configObj.watermsk = 'True'
        configObj.createWbdMask('[Function-1]')
        configObj.finalize()
        self.runf.write(self.text_cmd + 'SQWrapper.py -c ' + configName + '\n')

    def mask_layover(self, pairs): ###SSS 7/2018: Add layover/water masking option.
        for pair in pairs:
            master = pair[0]
            slave = pair[1]
            configName = os.path.join(self.config_path ,'config_igram_mask_' + master + '_' + slave)
            configObj = config(configName)
            configObj.configure(self)
            configObj.intname = os.path.join(self.work_dir,'merged/interferograms/'+master+'_'+slave,'filt_fine.int')
            if self.layovermsk:  ###SSS 7/2018: layover mask, if specified.
                configObj.layovermsk = 'True'
            if self.watermsk:  ###SSS 7/2018: water mask, if specified.
                configObj.watermsk = 'True'
            configObj.maskLayover('[Function-1]')
            configObj.finalize()
            self.runf.write(self.text_cmd + 'SQWrapper.py -c ' + configName + '\n')

    def finalize(self):
        self.runf.close()
        
        
#######################################################






