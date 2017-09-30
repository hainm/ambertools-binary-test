#!/bin/sh

# url="http://ambermd.org/downloads/ambertools-dev/AmberTools18-dev.tar.gz"
# tarfile=`python -c "url='$url'; print(url.split('/')[-1])"`
tarfile=AmberTools18-dev.tar.gz
amber_version='16'
ambertools_version='18'


function install_python(){
    if [ "$PYTHON_VERSION" = "2.7" ]; then
        bash $HOME/source_code/amber${amber_version}/AmberTools/src/configure_python --prefix $HOME
        export PATH=$HOME/miniconda/bin:$PATH
    else
        bash $HOME/source_code/amber${amber_version}/AmberTools/src/configure_python --prefix $HOME -v 3
        export PATH=$HOME/miniconda/bin:$PATH
    fi
}


function setup_ambertools(){
    echo "HOME = $HOME"
    echo "Start setup_ambertools"

    cwd=$TRAVIS_BUILD_DIR
    cd $HOME
    python -m pip install requests
    python $cwd/devtools/ci/download_circleci_AmberTools.py > log.download
    tail -50 log.download
    if [ ! -d $HOME/source_code ]; then
        mkdir $HOME/source_code
    fi
    mv $tarfile $HOME/source_code
    cd $HOME/source_code
    tar -xf $tarfile
    install_python > /dev/null
    cd $cwd
    echo "Done setup_ambertools"
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


function run_tests(){
    export PATH=$HOME/miniconda/bin:$PATH
    if [ "$CONDA" = "True" ]; then
        export AMBERHOME=`python -c "import sys; print(sys.prefix)"`
    else
        source $HOME/amber${ambertools_version}/amber.sh
    fi
    $AMBERHOME/bin/amber.setup_test_folders $HOME/source_code/amber${amber_version} --amberhome $AMBERHOME
    make_test_links # FIXME: remove in amber?
    git clone https://github.com/Amber-MD/ambertools-binary-build
    cp ambertools-binary-build/conda_tools/amber.run_tests $AMBERHOME/bin/
    git clone https://github.com/Amber-MD/ambertools-ci-base
    $AMBERHOME/bin/amber.run_tests -t $TEST_TASK -x ambertools-ci-base/EXCLUDED_TESTS -n 1 --debug
    cp test*.log $HOME/
}
