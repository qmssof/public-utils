#!/bin/bash
ARCHIVE_NAME=solr-${SOLR_VERSION}.tgz
ARCHIVE_URL=https://www.apache.org/dyn/closer.lua/lucene/solr/${SOLR_VERSION}/${ARCHIVE_NAME}?action=download
DIR_NAME=solr-${SOLR_VERSION}

if test -f "${ARCHIVE_NAME}"; then
  echo "File ${ARCHIVE_NAME} already exists. Aborting setup."
  exit 1
fi

sudo apt update
sudo apt upgrade -y
sudo apt install openjdk-17-jre-headless -y
wget "${ARCHIVE_URL}" -O ${ARCHIVE_NAME}
tar -xvf ${ARCHIVE_NAME}
sudo ${DIR_NAME}/bin/install_solr_service.sh ${ARCHIVE_NAME} -d /solrdata

cat <<EOT >> solr.service
[Unit]
Description=Apache SOLR

[Service]
Type=forking
User=solr
Environment=SOLR_INCLUDE=/etc/default/solr.in.sh
ExecStart=/opt/solr/bin/solr start
ExecStop=/opt/solr/bin/solr stop
Restart=on-failure
LimitNOFILE=65000
LimitNPROC=65000
TimeoutSec=180s

[Install]
WantedBy=multi-user.target
EOT
sudo mv solr.service /etc/systemd/system/
sudo systemctl stop solr
sudo systemctl daemon-reload
sudo systemctl enable solr
sudo systemctl start solr
