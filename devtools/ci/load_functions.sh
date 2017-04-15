#!/bin/sh

url="http://ambermd.org/downloads/ambertools-dev/AmberTools17.tar.gz"
tarfile=`python -c "url='$url'; print(url.split('/')[-1])"`
# binary_tarfile=`python -c "url='${ambertools_binary_url}'; print(url.split('/')[-1])"`
amber_version='16'
ambertools_version='17'
conda_channel='http://ambermd.org/downloads/ambertools/conda/'


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
        tar -xf ${binary_tarfile}
    fi
    cd $cwd
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
