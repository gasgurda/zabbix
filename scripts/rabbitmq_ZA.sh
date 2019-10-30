#!/bin/bash
# Отправка статистики сервера RabbitMQ на сервер Zabbix

USER=zabbix_mon
PASSWORD=zabbix_pass

if [ -z $1 ]; then
	echo $1 Not found
	exit 1
fi

CurlAPI(){

RespStr=$(/usr/bin/curl --max-time 20 --no-keepalive --silent --user $USER:$PASSWORD "http://127.0.0.1:15672/api/$REQ" | /etc/zabbix/scripts/JSON.sh -l 2>/dev/null)
 [ $? != 0 ] && echo 0 && exit 1
}

if [ -n "$2" ]; then
 REQ="queues/%2f/$1?columns=$2"
 CurlAPI
 echo $RespStr | sed 's/[^0-9]*//g'
 exit
fi

OutStr=''
IFS=$'\n'

if [ "$1" = 'queues' ]; then
 REQ='queues?columns=name'
 CurlAPI 
 es=''
 for q in $RespStr; do
  OutStr="$OutStr$es{\"{#QUEUENAME}\":\"${q#*	}\"}"
  es=","
 done
echo -e "{\"data\":[$OutStr]}"
exit
fi


if [ "$1" == "status" ]; then
        REQ="cluster-name"
        CurlAPI
        echo 1
        exit
fi


REQ="overview?columns=message_stats,queue_totals,object_totals"
CurlAPI
printf '%s\n' ${RespStr} | grep -w $1 | sed 's/[^0-9]*//g'

