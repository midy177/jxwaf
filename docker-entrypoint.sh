#!/bin/sh
server_name=`ip addr | grep inet | awk '{ print $2; }' | sed 's/\/.*$//'|grep -v 127.0.0.1|head -1`
server_mac=`hostname`
aes_enc_key=`cat /dev/urandom|head -n 10|md5sum|head -c 16`
aes_enc_iv=`cat /dev/urandom|head -n 10|md5sum|head -c 16`
sed -i "s/server_info_detail/$server_name|$server_mac/g" /opt/jxwaf/nginx/conf/jxwaf/jxwaf_config.json
sed -i "s/jxwaf_aes_enc_key/$aes_enc_key/g" /opt/jxwaf/nginx/conf/jxwaf/jxwaf_config.json
sed -i "s/jxwaf_aes_enc_iv/$aes_enc_iv/g" /opt/jxwaf/nginx/conf/jxwaf/jxwaf_config.json
/opt/jxwaf/nginx/sbin/nginx -t
cd /opt/jxwaf/tools
if [ 0"${API_KEY}" = "0" ]; then
    echo "not found env API_KEY"
else
  if [ 0"${API_PASSWORD}" = "0"  ]; then
    echo "not found env API_PASSWORD"
  else
    if [ 0"${WAF_SERVER}" = "0" ]; then
      python3 jxwaf_init.py --api_key=${API_KEY} --api_password=${API_PASSWORD}
    else
      python3 jxwaf_local_init.py --api_key=${API_KEY} --api_password=${API_PASSWORD} --waf_server=${WAF_SERVER}
    fi
  fi
fi
  exec "$@"