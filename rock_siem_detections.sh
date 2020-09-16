echo "This script will setup your local ROCK install with the SIEM Detection engine. This is NOT meant for production."
echo "IMPORTANT. Before executing this script, add the username you created via CentOS and the password created by ROCK to line 6 and 7"

echo "Adding the rock user with password to ES keystore without confirmation"

## BIG BRAIN MODE##

KIBANA_USER="$(grep -E "U: .*" KIBANA_CREDS.README)"
ELASTIC_PASS="$(grep -E "P: .*" KIBANA_CREDS.README)"

printf ${KIBANA_USER#U:} | /usr/share/elasticsearch/bin/elasticsearch-keystore add -x "bootstrap.password" -f
/usr/share/elasticsearch/bin/elasticsearch-users useradd "${KIBANA_USER#U:}" -p "${ELASTIC_PASS#P:}" -r superuser


# KIBANA_UUID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

echo "Stopping Elasticsearch"

systemctl stop elasticsearch

echo "Stopping Kibana"

systemctl stop kibana

echo "Adding required changes to elasticsearch.yml"

echo xpack.security.enabled: true >> /etc/elasticsearch/elasticsearch.yml
echo xpack.security.authc: >> /etc/elasticsearch/elasticsearch.yml
echo "      api_key.enabled: true" >> /etc/elasticsearch/elasticsearch.yml
echo "      anonymous:" >> /etc/elasticsearch/elasticsearch.yml
echo "              username: anonymous" >> /etc/elasticsearch/elasticsearch.yml
echo "              roles: superuser" >> /etc/elasticsearch/elasticsearch.yml
echo "              authz_exception: false" >> /etc/elasticsearch/elasticsearch.yml


echo "Adding required changes to kibana.yml"

cat >/etc/kibana/kibana.yml <<EOF
xpack.security.enabled: true
xpack.ingestManager.fleet.tlsCheckDisabled: true
xpack.encryptedSavedObjects.encryptionKey: 'fhjskloppd678ehkdfdlliverpoolfcr'
EOF

systemctl start elasticsearch

systemctl start kibana

echo "Script done! Make sure everything is running as needed. You will have to edit the es-outputs configurations and add the user and password to the configuration. Per https://huntops.blue/2020/08/02/securing-rocknsm.html"