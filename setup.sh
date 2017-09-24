git clone https://github.com/Amber-MD/ambertools-ci-base $HOME/ambertools-ci-base
cp -rf $HOME/ambertools-ci-base/EXCLUDED_TESTS $HOME/
cp -rf $HOME/ambertools-ci-base/devtools/ci/install_gfortran.sh devtools/ci/
git clone https://github.com/Amber-MD/ambertools-binary-build $HOME/ambertools-binary-build
cp $HOME/ambertools-binary-build/conda_tools/amber.run_tests $HOME/
cp $HOME/ambertools-binary-build/conda_tools/amber.setup_test_folders $HOME/
