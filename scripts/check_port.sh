#!/bin/bash


STATUS=$(nmap -Pn -p $2 $1 | head -6 | tail -1 | awk '{print $2}')

if [ "$STATUS" = "open" ];then
        echo 1
else
        echo 0
fi
