#! /usr/bin/env python3
###############################################################################
#
# Project: process_rsmas.py
# Author: Sara Mirzaee
# Created: 10/2018
#
###############################################################################
# Backwards compatibility for Python 2
from __future__ import print_function

import os
import sys
import time
import messageRsmas
from _process_utilities import send_logger, get_project_name, get_work_directory, _remove_directories
import _processSteps as prs
import create_batch as cb
from rsmas_logging import loglevel
import create_runfiles

logger_process_rsmas  = send_logger()


###############################################################################

if __name__ == "__main__":

    #########################################
    # Initiation
    #########################################

    start_time = time.time()
    inps = prs.command_line_parse()

    inps.project_name = get_project_name(inps.customTemplateFile)
    inps.work_dir = get_work_directory(None, inps.project_name)
    inps.slc_dir = os.path.join(inps.work_dir,'SLC')

    if inps.remove_project_dir:
        _remove_directories(directories_to_delete=[inps.work_dir])

    if not os.path.isdir(inps.work_dir):
        os.makedirs(inps.work_dir)
    os.chdir(inps.work_dir)

    #  Read and update template file:
    inps = prs.create_or_update_template(inps)
    print(inps)
    if not inps.processingMethod or inps.workflow=='interferogram':
        inps.processingMethod='sbas'

    if not os.path.isdir(inps.slc_dir):
        os.makedirs(inps.slc_dir)

    command_line = os.path.basename(sys.argv[0]) + ' ' + ' '.join(sys.argv[1:])
    logger_process_rsmas.log(loglevel.INFO, '##### NEW RUN #####')
    logger_process_rsmas.log(loglevel.INFO, 'process_rsmas.py ' + command_line)
    messageRsmas.log('##### NEW RUN #####')
    messageRsmas.log(command_line)
    
    #########################################
    # Submit job
    #########################################
    if inps.submit_flag:
        job_file_name = 'process_rsmas'
        wall_time = '48:00'
        cb.submit_script(inps.project_name, job_file_name, sys.argv[:], inps.work_dir, wall_time)

    #########################################
    # create and process pre_run_files
    #########################################
    # Download data


    #########################################
    # create run_files and post_run_file
    #########################################
    prs.create_runfiles()

    #########################################
    # processing run_files and post_run_files
    #########################################

    prs.process_runfiles(inps)



    logger_process_rsmas.log(loglevel.INFO, 'End of process_rsmas')
