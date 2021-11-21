#!/bin/bash

mkdir mailhog
cd mailhog
wget https://raw.githubusercontent.com/AdrianoRuseler/moodledev-plugins/main/docker/mailhog/docker-compose.yml -O docker-compose.yml
docker-compose up -d mailhog

a2enmod vhost_alias proxy proxy_http proxy_wstunnel
systemctl restart apache2



/etc/apache2/sites-available/mailhog.conf

    # Proxy config
    ProxyPreserveHost On
    ProxyRequests Off

    # Websocket proxy needs to be defined first
    ProxyPass "/api/v2/websocket" ws://localhost:8025/api/v2/websocket
    ProxyPassReverse "/api/v2/websocket" ws://localhost:8025/api/v2/websocket

    # General proxy
    ProxyPass / http://localhost:8025/
    ProxyPassReverse / http://localhost:8025/


sed -i 's/;sendmail_path =.*/sendmail_path = \/usr\/local\/bin\/mhsendmail/' /etc/php/7.4/apache2/php.ini



mhsendmail test@mailhog.local <<EOF
From: App <app@mailhog.local>
To: Test <test@mailhog.local>
Subject: Test message

Some content!
EOF


