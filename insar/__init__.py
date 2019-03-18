#########################################################################
# Author:  Sara Mirzaee, 2019 Jan                                       #
#########################################################################


import sys
import os
import importlib

insar_path = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(1, insar_path)
sys.path.insert(1, os.path.join(insar_path, 'defaults'))
sys.path.insert(1, os.path.join(insar_path, 'utils'))
sys.path.insert(1, os.path.join(insar_path, 'objects'))
sys.path.insert(1, os.path.join(insar_path, 'docs'))

try:
    os.environ['RSMAS_INSAR']
except KeyError:
    print('Using default PySAR Path: %s' % (insar_path))
    os.environ['RSMAS_INSAR'] = insar_path
    
    
__all__=[
    'create_runfiles',
    'create_batch',
    'dem_rsmas',
    'download_rsmas',
    'email_results',
    'execute_pre_runfiles',
    'execute_runfiles',
    'execute_post_runfiles',
    'ingest_insarmaps',
    'wrapper_rsmas'
]
for module in __all__:
    importlib.import_module(__name__ + '.' + module)
