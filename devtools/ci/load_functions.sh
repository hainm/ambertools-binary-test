#!/bin/sh

url="http://ambermd.org/downloads/ambertools-dev/AmberTools17.tar.gz"
tarfile=`python -c "url='$url'; print(url.split('/')[-1])"`
amber_version='16'
ambertools_version='17'
conda_channel='http://ambermd.org/downloads/ambertools/conda/'
non_conda_root='http://ambermd.org/downloads/ambertools/non-conda/'

fn='ambertools-17.0-0.13Apr17.tar.bz2'
if [ "$TRAVIS_OS_NAME" = "linux" ]; then
    ambertools_binary_url=${non_conda_root}/linux-64.$fn.${SECRET_EXT}
else
    ambertools_binary_url=${non_conda_root}/osx-64.$fn.${SECRET_EXT}
fi
echo "ambertools_binary_url $ambertools_binary_url"
binary_tarfile=`python -c "url='${ambertools_binary_url}'; print(url.split('/')[-1])"`


function shell_session_update(){
    echo "dummy"
}


function install_python(){
    set -e
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
    install_python

    cd $HOME
    
    echo "CONDA = $CONDA"
    if [ "$CONDA" = "True" ]; then
        conda install -y ambertools=${ambertools_version} -c ${conda_channel}
    else
        wget ${ambertools_binary_url} -O ${binary_tarfile}
        mv ${binary_tarfile} AT.tar.bz2
        tar -xf AT.tar.bz2
    fi
    cd $cwd
}


function setup_ambertools_circleci(){
    echo "Nothing"
}


function run_tests(){
    if [ "$CONDA" = "True" ]; then
        export AMBERHOME=`python -c "import sys; print(sys.prefix)"`
        if [ "$TRAVIS_OS_NAME" = "linux" ]; then
            # for nab
            export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$AMBERHOME/lib
        fi
    else
        source $HOME/amber${ambertools_version}/amber.sh
    fi
    amber.setup_test_folders $HOME/source_code/amber${amber_version}
    python $TRAVIS_BUILD_DIR/devtools/ci/ci_test.py $TEST_TASK
    # python $TRAVIS_BUILD_DIR/amber$version/AmberTools/src/conda_tools/amber.run_tests $TEST_TASK
}
