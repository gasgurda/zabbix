#!/bin/bash

TOMCAT_USER=tomcatadmin
TOMCAT_PASSWORD=tomcatpassword

if [ -z $1 ];then
es=''
for i in $(/usr/bin/curl -ss --max-time 5 -u $TOMCAT_USER:$TOMCAT_PASSWORD "http://localhost:8080/manager/text/list" | grep '^/' | awk -F: '{print $1}' | sed 's/\///g')
do
OutStr="$OutStr$es{\"{#CONTEXT}\":\"${i#*   }\"}"
es=","
done

echo -e "{\"data\":[$OutStr]}"
exit
fi


if [ -n $1 ];then
/usr/bin/curl -ss --max-time 5 -u tomcatadmin:5TYjwCDgZfHYPDbK "http://localhost:8080/manager/text/list" | grep $1: | grep running &>/dev/null ; if [ $? -eq 0 ];then echo 1 ; else echo 0; fi
exit
fi

