
``` bash
wget https://raw.githubusercontent.com/AdrianoRuseler/moodledev-plugins/main/config/LDAP/breduperson.ldif -O breduperson.ldif
wget https://raw.githubusercontent.com/AdrianoRuseler/moodledev-plugins/main/config/LDAP/openLdapEduperson.ldif -O breduperson.ldif

sudo ldapadd -Q -Y EXTERNAL -H ldapi:/// -f openLdapEduperson.ldif
sudo ldapadd -Q -Y EXTERNAL -H ldapi:/// -f breduperson.ldif

´´´