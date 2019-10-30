# Zabbix

RabbitMQ, шаблон **RabbitMQ-ZA-template.xml**

Сценарий отправки статистики сервера RabbitMQ на сервер Zabbix

`chmod 750 /etc/zabbix/{JSON.sh,rabbitmq_stat.sh}`

`chgrp zabbix /etc/zabbix/{JSON.sh,rabbitmq_stat.sh}`


В сценарии в подстроке

`... --user Пользователь_мониторинга:Пароль_мониторинга ...`

установить свои значения в переменные $USER и $PASSWORD.


Добавить плагин управления rabbitmq_management
[...,rabbitmq_management].

Добавить RabbitMQ-пользователь мониторинга

```
rabbitmqctl add_user Пользователь_мониторинга Пароль_мониторинга
rabbitmqctl set_user_tags Пользователь_мониторинга monitoring
rabbitmqctl set_permissions Пользователь_мониторинга '' '' ''
```


Скопировать rabbitmq.conf в директорию /etc/zabbix/zabbix_agentd.d

Перезапуск агента

systemctl restart  zabbix-agent 