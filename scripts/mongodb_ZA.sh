#!/bin/bash

MONGO_USER=mongouser
MONGO_PASSWORD=mongopassword

MongoAPI(){

 # Параметры mongo:
 #  --quiet     'тихий' вывод оболочки;
 #  --eval      вычисляемое JavaScript выражение
 RespStr=$(/usr/bin/mongo --host 127.0.0.1 --username "mongouser" --password "mongopassword" --authenticationDatabase admin --quiet --eval "rs.slaveOk(); print(JSON.stringify($REQ))" $database  | /etc/zabbix/scripts/JSON.sh -l 2>/dev/null)
 # Статистика недоступна - возврат статуса сервиса - 'не работает'
 [ $? != 0 ] && echo 0 && exit 1
}

if [ -z $1 ];then
	echo Need argument \$1
	exit 1
fi

REQ='db.getMongo().getDBs()'
MongoAPI
DBStr=$((cat <<EOF
$RespStr
EOF
) | awk -F\\t '$1~/^databases..+.name$/ && $2!~/^local$/ {
 print $2
}')


if [ "$1" == "status" ]; then
  REQ="db.getMongo().getDBs()"
  MongoAPI
  echo 1
  exit

elif [ "$1" = 'db' ]; then
  es=''
  for db in $DBStr; do
    OutStr="$OutStr$es{\"{#DBNAME}\":\"${db#*     }\"}"
    es=","
  done
  echo -e "{\"data\":[$OutStr]}"
  exit

elif [ "$1" == "members" ]; then

  REQ='db.adminCommand( { replSetGetStatus: 1, initialSync: 1 } )'
  MongoAPI
  echo $RespStr | grep NoReplicationEnabled

  if [ "$?" -eq 0 ];then
          echo Replication not enabled
          exit 1
  fi

  MEMBERS=$(echo $RespStr | xargs -n2 | egrep members\.[0-9]\.name | awk '{print $2}' | cut -d":" -f1)
  es=''

  for mn in $MEMBERS; do
    OutStr="$OutStr$es{\"{#MEMBERS.NAME}\":\"${mn#*     }\"}"
    es=","
  done

  # Convert members replica.set to  JSON
  echo -e "{\"data\":[$OutStr]}"
  exit 0
fi


if  [ "$3" = "mongodb_cluster" ];then
  REQ='db.adminCommand( { replSetGetStatus: 1, initialSync: 1 } )'
  MongoAPI

  MEMBER_ID=$(echo $RespStr | xargs -n2 | egrep members\.[0-9]\.name | grep $1 | awk -F. '{print $2}')

  echo $RespStr | xargs -n2 | grep -w members.$MEMBER_ID.$2 | awk '{print $2}'
  exit 0
fi



if [ "$2" == "common" ]; then
 REQ='db.serverStatus({cursors: 0, locks:0, wiredTiger: 0})'
 MongoAPI 
 OutStr=$((cat <<EOF
$RespStr
EOF
) | awk -F\\t '$1~/^(metrics.(cursor.(open.total|timedOut)|document.(deleted|inserted|returned|updated))|connections.(current|available)|globalLock.(currentQueue.(readers|total|writers)|activeClients.(total|readers|writers)|totalTime)|extra_info.(heap_usage_bytes|page_faults)|mem.(resident|virtual|mapped)|uptime|network.(bytes(In|Out)|numRequests)|opcounters.(command|delete|getmore|insert|query|update))(.floatApprox|.\$numberLong)?$/ {
  sub(".floatApprox", "", $1)
  sub(".\\$numberLong", "", $1)
  print "- mongodb." $1, int($2)
 }')
echo $OutStr | sed 's/- /\n/g' | grep -w $1 | sed 's/[^0-9]*//g'
exit 0
else
 database=$1
 REQ='db.stats()' 
 MongoAPI
 echo $RespStr | xargs -n2 | grep $2 | sed 's/[^0-9]*//g'
exit 0
fi
