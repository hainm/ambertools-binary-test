#!/bin/sh

url="http://ambermd.org/downloads/ambertools-dev/AmberTools17.tar.gz"
tarfile=`python -c "url='$url'; print(url.split('/')[-1])"`
if [ "$CONDA" = "True" ]; then
    ambertools_binary_url='https://480-81537431-gh.circle-artifacts.com/0/tmp/circle-artifacts.SHoEmLc/ambertools-build/amber-conda-bld/linux-64/ambertools-17.0-0.tar.bz2'
else
    ambertools_binary_url='https://480-81537431-gh.circle-artifacts.com/0/tmp/circle-artifacts.SHoEmLc/ambertools-build/amber-conda-bld/non-conda-install/linux-64.ambertools-17.0-0.16Apr17.H0417.tar.bz2'
fi
binar_tarfile=`python -c "url='${ambertools_binary_url}'; print(url.split('/')[-1])"`
amber_version='16'
ambertools_version='17'


function install_python(){
    set -ex
    if [ "$PYTHON_VERSION" = "2.7" ]; then
        bash amber${amber_version}/AmberTools/src/configure_python --prefix $HOME
        export PATH=$HOME/miniconda/bin:$PATH
    else
        bash amber${amber_version}/AmberTools/src/configure_python --prefix $HOME -v 3
        export PATH=$HOME/miniconda/bin:$PATH
    fi
}


function setup_ambertools(){
    cwd=`pwd`
    mkdir $HOME/source_code
    cd $HOME/source_code
    wget $url -O $tarfile
    tar -xf $tarfile
    ls .
    install_python
    cd $cwd
    install_python

    wget ${ambertools_binary_url} -O ${binary_tarfile}
    if [ "$CONDA" = "True" ]; then
        conda install ${binary_tarfile}
    else
        tar -xf ${binary_tarfile}
    fi
}


function setup_ambertools_circleci(){
    echo "Nothing"
}


function run_tests(){
    if [ "$CONDA" = "True" ]; then
        export AMBERHOME=`python -c "import sys; print(sys.prefix)"`
    else
        source $HOME/amber${ambertools_version}/amber.sh
    fi
    amber.setup_test_folders $HOME/source_code/amber${amber_version}
    python $TRAVIS_BUILD_DIR/devtools/ci/ci_test.py $TEST_TASK
    # python $TRAVIS_BUILD_DIR/amber$version/AmberTools/src/conda_tools/amber.run_tests $TEST_TASK
}
