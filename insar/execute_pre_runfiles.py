#!/usr/bin/env python3
########################
# Author: Sara Mirzaee
#######################

import os
import sys
import argparse
import subprocess
import insar.utils
from insar.utils.process_utilities import get_project_name, remove_zero_size_or_length_files
from pysar.utils import readfile



##############################################################################
EXAMPLE = """example:
  execute_pre_run_files.py LombokSenAT156VV.template 
"""


def create_parser():
    """ Creates command line argument parser object. """

    parser = argparse.ArgumentParser(formatter_class=argparse.RawTextHelpFormatter, epilog=EXAMPLE)
    parser.add_argument('-v', '--version', action='version', version='%(prog)s 0.1')
    parser.add_argument('custom_template_file', nargs='?',
                        help='custom template with option settings.\n')

    return parser


def command_line_parse(iargs=None):
    """ Parses command line agurments into inps variable. """

    parser = create_parser()
    inps = parser.parse_args(args=iargs)

    return inps


def get_run_files(inps):
    """ Reads squeesar runfiles to a list. """

    runfiles = os.path.join(inps.work_dir, 'pre_run_files_list')
    run_file_list = []
    with open(runfiles, 'r') as f:
        new_f = f.readlines()
        for line in new_f:
            run_file_list.append('pre_run_files/' + line.split('/')[-1][:-1])

    return run_file_list


def set_memory_defaults():
    """ Sets an optimized memory value for each job. """

    memoryuse = {'download_data': '3700',
                 'download_dem': '3700'}

    return memoryuse


def submit_run_jobs(run_file_list, cwd, memoryuse):
    """ Submits stackSentinel runfile jobs. """

    for item in run_file_list:
        item_memory = '_'
        item_memory = item_memory.join(item.split('_')[3::])
        try:
            memorymax = str(memoryuse[item_memory])
        except:
            memorymax = '3700'

        if os.getenv('QUEUENAME') == 'debug':
            walltimelimit = '0:30'
        else:
            walltimelimit = '4:00'

        queuename = os.getenv('QUEUENAME')

        cmd = 'create_batch.py ' + cwd + '/' + item + ' --memory=' + memorymax + ' --walltime=' + walltimelimit + \
               ' --queuename ' + queuename + ' --outdir "pre_run_files"'


        print('command:', cmd)
        status = subprocess.Popen(cmd, shell=True).wait()
        if status is not 0:
            raise Exception('ERROR submitting {} using create_batch.py'.format(item))

        job_folder = cwd + '/' + item + '_out_jobs'
        print('jobfolder:', job_folder)

        remove_zero_size_or_length_files(directory='pre_run_files')

        if not os.path.isdir(job_folder):
            os.makedirs(job_folder)
        mvlist = ['*.e ', '*.o ', '*.job ']
        for mvitem in mvlist:
            cmd = 'mv ' + cwd + '/pre_run_files/' + mvitem + job_folder
            print('move command:', cmd)
            os.system(cmd)

    return 


##############################################################################

def main(iargs=None):

    inps = command_line_parse(iargs)
    
    inps.project_name = get_project_name(inps.custom_template_file)
    inps.work_dir = os.getenv('SCRATCHDIR') + '/' + inps.project_name
    
    run_file_list = get_run_files(inps)

    try:
        inps.start
    except:
        inps.start = 1
    try:
        inps.stop
    except:
        inps.stop = len(run_file_list)

    memoryuse = set_memory_defaults()

    submit_run_jobs(run_file_list[inps.start - 1:inps.stop], inps.work_dir, memoryuse)
    return None

###########################################################################################

if __name__ == "__main__":
    main()
