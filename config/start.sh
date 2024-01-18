#/bin/sh

set -x

backend=`cat /etc/varnish/backend.txt`
host=`echo ${backend}|awk 'NR == 1 {print $1}'`
port=`echo ${backend}|awk 'NR == 1 {print $2}'`

sed -i "s|--host--|${host}|g" /etc/varnish/default.vcl
sed -i "s|--port--|${port}|g" /etc/varnish/default.vcl

supervisord -n -c /etc/supervisord.conf