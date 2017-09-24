wget https://github.com/hainm/ambertools-dev-binary/blob/master/tmp_osx_ATaa?raw=true -O $HOME/tmp_osx_ATab
wget https://github.com/hainm/ambertools-dev-binary/blob/master/tmp_osx_ATab?raw=true -O $HOME/tmp_osx_ATab
wget https://github.com/hainm/ambertools-dev-binary/blob/master/tmp_osx_ATac?raw=true -O $HOME/tmp_osx_ATac
cat $HOME/tmp_osx_AT* > $HOME/AT.tar
cd $HOME
tar -xf AT.tar
