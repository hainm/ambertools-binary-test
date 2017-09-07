ambertools_version='18'

export TEST_TASK=fast

function run_tests(){
    export PATH=$HOME/miniconda/bin:$PATH
    if [ "$CONDA" = "True" ]; then
        export AMBERHOME=`python -c "import sys; print(sys.prefix)"`
    else
        source $HOME/amber${ambertools_version}/amber.sh
    fi
    $AMBERHOME/bin/amber.run_tests -t $TEST_TASK -x ambertools-ci-base/EXCLUDED_TESTS --circleci
    cp test*.log $HOME/
}

run_tests
