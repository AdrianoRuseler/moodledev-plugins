#!/bin/bash

rm CreateApacheLocalSite.sh
wget https://raw.githubusercontent.com/AdrianoRuseler/moodledev-plugins/main/scripts/CreateApacheLocalSite.sh
chmod a+x CreateApacheLocalSite.sh

rm CreateDataBaseUser.sh
wget https://raw.githubusercontent.com/AdrianoRuseler/moodledev-plugins/main/scripts/CreateDataBaseUser.sh
chmod a+x CreateDataBaseUser.sh

rm DeleteApacheLocalSite.sh
wget https://raw.githubusercontent.com/AdrianoRuseler/moodledev-plugins/main/scripts/DeleteApacheLocalSite.sh
chmod a+x DeleteApacheLocalSite.sh

rm DropMDL.sh
wget https://raw.githubusercontent.com/AdrianoRuseler/moodledev-plugins/main/scripts/DropMDL.sh
chmod a+x DropMDL.sh

rm GetMDL.sh
wget https://raw.githubusercontent.com/AdrianoRuseler/moodledev-plugins/main/scripts/GetMDL.sh
chmod a+x GetMDL.sh

rm InstallMDL.sh
wget https://raw.githubusercontent.com/AdrianoRuseler/moodledev-plugins/main/scripts/InstallMDL.sh
chmod a+x InstallMDL.sh