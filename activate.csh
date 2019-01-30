#!/bin/csh

# Get the name of this script

if ( $?_ ) then
	# With tcsh the name of the file being sourced is available in
	# $_.
	set script_name = `basename $_`
else
	# Fall back to $0 which, sometimes, will be the name of the
	# shell instead of the file being sourced.
	set script_name = `basename $0`
endif

# Get arguments
if ( $#argv < 1 ) then
	echo ""
	echo "Usage: source $script_name <CONDAENV>"
	exit 2
endif
set conda_env = $1

# Make sure the $CONDA_ENVS_PATH env var is defined
if ( ! $?CONDA_ENVS_PATH ) then
	echo ""
	echo 'You must set the environment variable $CONDA_ENVS_PATH to point to the parent directory containing your conda environments\n'
	echo "Usage: source $script_name <CONDAENV>"
	exit 2
endif

# Make sure the $CONDA_ENVS_PATH env var isn't empty
if ( "$CONDA_ENVS_PATH" == "" ) then
	echo ""
	echo "You must set the environment variable \$CONDA_ENVS_PATH to point to the parent directory containing your conda environments\n\n"
	echo "Usage: source $script_name <CONDAENV>"
	exit 2
endif

# See if the given Anaconda environment exists under $CONDA_ENVS_PATH
if ( ! -d "$CONDA_ENVS_PATH/$conda_env" ) then
	echo ""
	echo "The '$conda_env' conda environment was not found in $CONDA_ENVS_PATH"
	echo ""
	echo "Did you create one with 'conda create -n <myenv> python'?"
	exit 2
endif

# Remove duplicates from $PATH
set new_path = `echo $PATH | sed -e 's/$/:/;s/^/:/;s/:/::/g;:a;s#\(:[^:]\{1,\}:\)\(.*\)\1#\1\2#g;ta;s/::*/:/g;s/^://;s/:$//;'`

# Determine the active python environment
set active_python=`which python`

# If the active python environment is the production environment
set python_bin_dir=`which python | sed 's|/python$||'`
set test=`echo $active_python | awk -v test="$CONDA_ENVS_PATH" '$0 ~ test { print "MATCH" }'`
if ( $test != "MATCH" ) then
	setenv CONDA_PROD_ENV_BIN $python_bin_dir
	setenv PATH `echo $PATH | sed -e 's|^'$python_bin_dir':||' -e 's|:'$python_bin_dir':|:|' -e 's|:'$python_bin_dir'$||'`
	# Prepend the name of the conda environment to the prompt
	set prompt_saved="$prompt"
	set prompt="($conda_env)$prompt"
# If the active python environment is a conda environment
else
	# See if this conda environment is already active
	set prev_conda_env=`which python | sed -e 's|^'$CONDA_ENVS_PATH'/||' -e 's|/bin/python$||'`
	if ( $prev_conda_env == $conda_env ) then
		echo ""
		echo "The '$conda_env' conda environment is already active"
		exit 0
	endif
	# Change the name of the conda environment in the prompt
	
	set prompt=`echo $prompt | sed 's|^('$prev_conda_env')|\('$conda_env'\)|'`
	# Remove the current conda environment from $PATH
	setenv PATH `echo $PATH | sed -e 's|^'$python_bin_dir':||' -e 's|:'$python_bin_dir':|:|' -e 's|:'$python_bin_dir'$||'`
endif

# Prepend $CONDA_ENVS_PATH/$conda_env/bin to the $PATH variable
setenv PATH $CONDA_ENVS_PATH/$conda_env/bin:$PATH

# Print help info
echo "Your Python environment has been changed to the '$conda_env' conda environment. Here's the active version of Python:"
which python
python --version
echo "To switch back to your default Python environment, type 'source deactivate.csh'"
