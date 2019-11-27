#!/bin/bash

TOMCAT_USER=tomcatadmin
TOMCAT_PASSWORD=tomcatpassword


es=''
for i in $(/usr/bin/curl -ss --max-time 5 -u $TOMCAT_USER:$TOMCAT_PASSWORD "http://localhost:8080/manager/text/list" | grep '^/' | awk -F: '{print $1}' | sed 's/\///g')
do
OutStr="$OutStr$es{\"{#CONTEXT}\":\"${i#*   }\"}"
es=","
done

echo -e "{\"data\":[$OutStr]}"
