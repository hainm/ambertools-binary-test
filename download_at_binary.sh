set -ex
wget https://github.com/hainm/ambertools-dev-binary/blob/master/tmp_osx_ATaa?raw=true -O tmp_osx_ATaa >& log
wget https://github.com/hainm/ambertools-dev-binary/blob/master/tmp_osx_ATab?raw=true -O tmp_osx_ATab >& log
wget https://github.com/hainm/ambertools-dev-binary/blob/master/tmp_osx_ATac?raw=true -O tmp_osx_ATac >& log
tail -50 log
cat tmp_osx_AT* > AT.tar
mv AT.tar $HOME/
cd $HOME
tar -xf AT.tar
mv amber16 amber18
