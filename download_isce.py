#! /usr/bin/env python3
"""This module downloads the isce software from UNAVCO
   and sentinelStack from earthdef
   Author: Falk Amelung
   Created: 1/2019
"""

import os
import sys
import subprocess

sys.path.insert(0, os.getenv('PARENTDIR') + '/accounts')
import password_config as password

def main():
    """gets ISCE code with wget"""

    isce_version = 'isce-2.2.0.tar.bz2'
    isce_dir = os.getenv('PARENTDIR') + '/3rdparty/isce'

    if not os.path.isdir(isce_dir):
        os.makedirs(isce_dir)
    os.chdir(isce_dir)

    command = ['wget', '--user=' + password.unavuser, '--password=' + password.unavpass, 'https://imaging.unavco.org/software/ISCE/' + isce_version]
    print('downloading isce ...')
    print('\n' + ' '.join(command) + '\n')
    status = subprocess.Popen(' '.join(command), shell=True).wait()
    if status is not 0:
        raise Exception('ERROR downloading isce')

    sentinelstack_dir = os.getenv('PARENTDIR') + '/3rdparty/sentinelstack'

    if not os.path.isdir(sentinelstack_dir):
        os.makedirs(sentinelstack_dir)
    os.chdir(sentinelstack_dir)

    command = ['svn co', '--username ' + password.earthdefuser, '--password ' + password.earthdefpass, 'http://earthdef.caltech.edu/svn/sentinelstack', '--non-interactive']
    print("downloading sentinelStack (via svn checkout) ...")
    print('\n' + ' '.join(command) + '\n')
    status = subprocess.Popen(' '.join(command), shell=True).wait()
    if status is not 0:
        raise Exception('ERROR in svn checkout of sentinelStack')

###########################################################################################
if __name__ == '__main__':
    main()
