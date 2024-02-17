#!/bin/sh

set -x

backend=`cat /etc/varnish/backend.txt`
host=`echo ${backend}|awk 'NR == 1 {print $1}'`
port=`echo ${backend}|awk 'NR == 1 {print $2}'`

sed -i "s|--host--|${host}|g" /etc/varnish/default.vcl
sed -i "s|--port--|${port}|g" /etc/varnish/default.vcl

supervisord -n -c /etc/supervisord.conf &
sleep 5
varnishlog -i ReqURL -i RespStatus -i ReqMethod -I ReqHeader:Referer -I RespHeader:Date -q 'RespHeader:X-Cache eq MISS' | /etc/varnish/processlogs.sh
varnishlog | /etc/varnish/processlogs.sh
