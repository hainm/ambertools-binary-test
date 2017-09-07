#!/bin/sh

url="http://ambermd.org/downloads/ambertools-dev/AmberTools18-dev.tar.gz"
tarfile=`python -c "url='$url'; print(url.split('/')[-1])"`
amber_version='16'
ambertools_version='18'


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
    echo "HOME = $HOME"
    cwd=`pwd`
    mkdir $HOME/source_code
    cd $HOME/source_code
    if [ ! -f $HOME/source_code/$tarfile ]; then
        echo "Do not have $HOME/source_code/$tarfile"
        echo "Downloading ..."
        wget $url -O $tarfile
    else
        echo "Using cache folder $HOME/source_code/$tarfile"
    fi
    tar -xf $tarfile
    install_python

    cd $HOME
    python $cwd/devtools/ci/download_circleci_AmberTools.py
    if [ "$CONDA" = "True" ]; then
        binary_tarfile=`ls ambertools*${ambertools_version}*tar.bz2`
        conda install ${binary_tarfile}
    else
        binary_tarfile=`ls linux-64.ambertools*${ambertools_version}*tar.bz2`
        tar -xf ${binary_tarfile}
    fi
    cd $cwd
}


function setup_ambertools_circleci(){
    echo "Nothing"
}


make_test_links(){
	cd $AMBERHOME/test/amd             && ln -s -f ../../bin/sander .
	cd $AMBERHOME/test/chamber         && ln -s -f ../../bin/sander .
	cd $AMBERHOME/test/nmropt          && ln -s -f ../../bin/sander .
	cd $AMBERHOME/test/qmmm2           && ln -s -f ../../bin/sander .
	cd $AMBERHOME/test/qmmm_DFTB       && ln -s -f ../../bin/sander .
	cd $AMBERHOME/test/abfqmmm         && ln -s -f ../../bin/sander .
	cd $AMBERHOME/test/rism3d          && ln -s -f ../../bin/sander .
	cd $AMBERHOME/test/sander_pbsa_frc && ln -s -f ../../bin/sander .
	cd $AMBERHOME/test/rism3d          && ln -s -f ../../bin/sander .
}


function setup_tests(){
    export PATH=$HOME/miniconda/bin:$PATH
    if [ "$CONDA" = "True" ]; then
        export AMBERHOME=`python -c "import sys; print(sys.prefix)"`
    else
        source $HOME/amber${ambertools_version}/amber.sh
    fi
    $AMBERHOME/bin/amber.setup_test_folders $HOME/source_code/amber${amber_version}
    make_test_links # FIXME: remove in amber?
    git clone https://github.com/Amber-MD/ambertools-binary-build
    cp ambertools-binary-build/conda_tools/amber.run_tests $AMBERHOME/bin/
    git clone https://github.com/Amber-MD/ambertools-ci-base
}


function run_tests(){
    # re-export for circleci
    export PATH=$HOME/miniconda/bin:$PATH
    if [ "$CONDA" = "True" ]; then
        export AMBERHOME=`python -c "import sys; print(sys.prefix)"`
    else
        source $HOME/amber${ambertools_version}/amber.sh
    fi
    $AMBERHOME/bin/amber.run_tests -t $TEST_TASK -x ambertools-ci-base/EXCLUDED_TESTS -n 4
    cp test*.log $HOME/
}
