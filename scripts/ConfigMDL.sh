#!/bin/bash

cd /var/www/html/moodle

mdlver=$(cat version.php | grep '$release' | cut -d\' -f 2) # Gets Moodle Version

echo "Enable the maintenance mode..."
sudo -u www-data /usr/bin/php admin/cli/maintenance.php --enable

echo "Setting configurations..."
sudo -u www-data /usr/bin/php admin/cli/cfg.php --name=theme --set=classic
sudo -u www-data /usr/bin/php admin/cli/cfg.php --name=allowthemechangeonurl --set=1
sudo -u www-data /usr/bin/php admin/cli/cfg.php --name=allowuserthemes --set=1
sudo -u www-data /usr/bin/php admin/cli/cfg.php --name=allowcoursethemes --set=1
sudo -u www-data /usr/bin/php admin/cli/cfg.php --name=allowcategorythemes --set=1
sudo -u www-data /usr/bin/php admin/cli/cfg.php --name=allowcohortthemes --set=1
sudo -u www-data /usr/bin/php admin/cli/cfg.php --name=downloadcoursecontentallowed --set=1
sudo -u www-data /usr/bin/php admin/cli/cfg.php --name=lang --set=pt_br
sudo -u www-data /usr/bin/php admin/cli/cfg.php --name=doclang --set=en

echo "disable the maintenance mode..."
sudo -u www-data /usr/bin/php admin/cli/maintenance.php --disable


