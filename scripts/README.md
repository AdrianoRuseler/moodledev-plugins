# README.md
```bash
wget https://raw.githubusercontent.com/AdrianoRuseler/moodledev-plugins/main/scripts/SystemSetup.sh -O SystemSetup.sh
chmod a+x SystemSetup.sh
./SystemSetup.sh
```

```bash
mkdir scripts
cd scripts
wget https://raw.githubusercontent.com/AdrianoRuseler/moodledev-plugins/main/scripts/UpdateScripts.sh -O UpdateScripts.sh
chmod a+x UpdateScripts.sh
./UpdateScripts.sh
```

```bash
export LOCALSITENAME="pma"
./CreateApacheLocalSite.sh
./InstallPMA.sh
```

```bash
export LOCALSITENAME="devtest"
./CreateApacheLocalSite.sh
```

```bash
export LOCALSITENAME="devtest"
export MDLBRANCH="MOODLE_311_STABLE"
export MDLREPO="https://github.com/moodle/moodle.git"
./GetMDL.sh
```

```bash
export LOCALSITENAME="devtest"
./CreateDataBaseUser.sh
```

```bash
export LOCALSITENAME="devtest"
./InstallMDL.sh
```
