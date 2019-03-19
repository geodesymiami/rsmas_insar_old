#! /usr/bin/env python3
"""This script downloads SAR data and deals with various errors produced by download clients
   Author: Falk Amelung
   Created:12/2018
"""
###############################################################################

import os
import sys
import argparse
import subprocess
import glob
from insar.utils import download_ssara_rsmas, download_asfserial_rsmas
from insar.objects import messageRsmas
import insar.utils.process_utilities as putils
from insar.objects.dataset_template import Template
import insar.create_batch as cb

###############################################################################
EXAMPLE = '''example:
  download_rsmas.py $SAMPLESDIR/GalapagosSenDT128.template
'''


def command_line_parse(iargs=None):
    """Command line parser."""
    parser = create_parser()
    inps = parser.parse_args(args=iargs)
    return inps

def create_parser():
    """ Creates command line argument parser object. """
    parser = argparse.ArgumentParser(description='Downloads SAR data using a variety of scripts',
                                     formatter_class=argparse.RawTextHelpFormatter, epilog=EXAMPLE)
    parser.add_argument('template_file', help='template file containing ssaraopt field')
    parser.add_argument( '--submit', dest='submit_flag', action='store_true', help='submits job')

    # parser.add_argument('template_file', help='template file containing ssaraopt field', nargs='?')
    return parser

def ssh_with_commands(hostname, command_list):
    """
    Uses subprocess to ssh into a specified host and run the given commands.
    :param hostname: Name of host to ssh to.
    :param command_list: List of commands to run after connecting via ssh.
    :return: Exit status from subprocess.
    """
    ssh_proc = subprocess.Popen(['ssh', hostname, 'bash -s -l'], stdin=subprocess.PIPE)
    for cmd in command_list:
        ssh_proc.stdin.write(cmd.encode('utf8'))
        ssh_proc.stdin.write('\n'.encode('utf8'))
    ssh_proc.communicate()
    return ssh_proc.returncode

def download(script_name, inps, outnum):
    """
    Runs download script with given script name.
    :param script_name: Name of download script to run (ssara, asfserial)
    :param template_file: Template file to download data from.
    :param slc_dir: SLC directory inside work directory.
    """
    if script_name not in {'ssara', 'asfserial'}:
        print('{} download not supported'.format(script_name))

    #out_file = os.path.join(os.getcwd(), 'out_download_{0}{1}'.format(script_name,outnum))
    #command = 'download_{0}_rsmas.py {1}'.format(script_name, template_file)
    #command = '({0} > {1}.o) >& {1}.e'.format(command, out_file)

    if os.getenv('DOWNLOADHOST') == 'local':
         ssh_command_list = ['s.bgood', 'cd {0}'.format(inps.slc_dir)]
         host = os.getenv('DOWNLOADHOST')
         status = ssh_with_commands(host, ssh_command_list)
         
         if script_name=='ssara':
            try:
                successful=download_ssara_rsmas.run_ssara(inps)
            except:
                raise Exception('Error running download_ssara_rsmas.py')
         elif script_name=='asfserial':
            try:
                successful=download_asfserial_rsmas.run_download_asf_serial()
            except:
                raise Exception('Error running download_asfserial_rsmas.py')
                  
        #print('Command: ' + command )
        #proc = subprocess.Popen(command,  stderr=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)
        #output, error = proc.communicate()
        #if proc.returncode is not 0:
        #    raise Exception('ERROR downloading using: download_{0}_rsmas.py'.format(script_name))
    #else:
        #ssh_command_list = ['s.bgood', 'cd {0}'.format(inps.slc_dir), command]
        #host = os.getenv('DOWNLOADHOST')
        #status = ssh_with_commands(host, ssh_command_list)

    print('Exit status from download_{0}_rsmas.py: {1}'.format(script_name, successful))

###############################################################################

def main(iargs=None):
    """Downloads data with ssara and asfserial scripts."""

    command = 'download_rsmas.py ' + iargs[0]
    messageRsmas.log(command)

    inps = command_line_parse(iargs)

    #########################################
    # Submit job
    #########################################
    if inps.submit_flag:
        job_file_name = 'download_rsmas'
        work_dir = os.getcwd()
        job_name = inps.template_file.split(os.sep)[-1].split('.')[0]
        wall_time = '24:00'

        cb.submit_script(job_name, job_file_name, sys.argv[:], work_dir, wall_time)

    inps.project_name = putils.get_project_name(custom_template_file=inps.template_file)
    inps.work_dir = putils.get_work_directory(None, inps.project_name)
    inps.slc_dir = os.path.join(inps.work_dir, 'SLC')
    if not os.path.isdir(inps.work_dir):
        os.makedirs(inps.work_dir)
    if not os.path.isdir(inps.slc_dir):
        os.makedirs(inps.slc_dir)

    os.chdir(inps.work_dir)

    # if satellite is not Sentinel (not tried yet)
    if 'SenDT' not in inps.project_name and 'SenAT' not in inps.project_name:

        dataset_template = Template(inps.template_file)

        ssaraopt = dataset_template.generate_ssaraopt_string()
        ssara_call = ['ssara_federated_query.py'] + ssaraopt + ['--print', '--download']
        ssara_process = subprocess.Popen(ssara_call, shell=True).wait()
        completion_status = ssara_process.poll()

        return

    download('ssara', inps, outnum = 1)
    #download('ssara', inps.template_file, slc_dir, outnum = 2)
    download('asfserial', inps, outnum = 1)
    #download('asfserial', inps.template_file, slc_dir, outnum = 1)

###########################################################################################


if __name__ == '__main__':
    main(sys.argv[1:])
