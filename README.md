# Zabbix

# RabbitMQ, шаблон **RabbitMQ-ZA-template.xml**

Сценарий отправки статистики сервера RabbitMQ на сервер Zabbix. Тип проверки Zabbix-agent.

`chmod 750 /etc/zabbix/scripts/{JSON.sh,rabbitmq_ZA.sh}`

`chgrp zabbix /etc/zabbix/scripts/{JSON.sh,rabbitmq_ZA.sh}`


В сценарии rabbitmq_ZA.sh в подстроке

`... --user Пользователь_мониторинга:Пароль_мониторинга ...`

установить свои значения в переменные $USER и $PASSWORD.


Добавить плагин управления rabbitmq_management
[...,rabbitmq_management].

Добавить RabbitMQ-пользователя мониторинга

```
rabbitmqctl add_user Пользователь_мониторинга Пароль_мониторинга
rabbitmqctl set_user_tags Пользователь_мониторинга monitoring
rabbitmqctl set_permissions Пользователь_мониторинга '' '' ''
```


Скопировать rabbitmq.conf в директорию /etc/zabbix/zabbix_agentd.d

Перезапуск агента

systemctl restart  zabbix-agent 


# MongoDB, шаблон **MongoDB-ZA-template.xml**

Данный шаблон можно применять и к SECONDARY и к PRIMARY серверу replicaSet.

Сценарий отправки статистики сервера MongoDB на сервер Zabbix. Тип проверки Zabbix-agent.

`chmod 750 /etc/zabbix/scripts/{JSON.sh,mongodb_ZA.sh}`

`chgrp zabbix /etc/zabbix/scripts/{JSON.sh,mongodb_ZA.sh}`

Создать пользователя мониторинга в mongo:

```
use admin
db.createUser( { user: "mongouser", pwd: "mongopassword", roles: [ { role: "clusterMonitor", db: "admin" } ] } )
```

В скрипте mongodb_ZA.sh поменять значение переменных $MONGO_USER и $MONGO_PASSWORD на те что указали при создание пользователя мониторинга.

Скопировать mongodb.conf в директорию /etc/zabbix/zabbix_agentd.d

Перезапуск агента

systemctl restart  zabbix-agent


# ElasticSearch, шаблон **ElasticSearch-ZA-template.xml**


Сценарий отправки статистики сервера Elasticsearch на сервер Zabbix. Тип проверки Zabbix-agent.

`chmod 750 /etc/zabbix/scripts/{JSON.sh,elasticsearch_ZA.sh}`

`chgrp zabbix /etc/zabbix/scripts/{JSON.sh,elasticsearch_ZA.sh}`


Скопировать mongodb.conf в директорию /etc/zabbix/zabbix_agentd.d

Перезапуск агента

systemctl restart  zabbix-agent



# Проверка локального порта. Тип проверки Zabbix-agent.

Использовать только для проверок с ограниченной сетевой  доступностью портов для Zabbix Server.

Предворительное требование:
- пакет nmap

Скопировать scripts/check_port.sh в /etc/zabbix/scripts/check_port.sh
Скопировать zabbix_agentd.d/check_port.conf в /etc/zabbix/zabbix_agentd.d/check_port.conf
`chmod 750 /etc/zabbix/scipts/check_port.sh`
`chown .zabbix /etc/zabbix/scipts/check_port.sh`

Создать Teamplate , в нем Item с ключём check_port[{HOST.IP},22] (22 - номер порта SSH для проверки, поменять на требуемый. {HOST.IP} - ip адрес указанный в настроках узла Zabbix хоста).
