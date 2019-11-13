#!/bin/bash
# Отправка статистики сервера ElasticSearch на сервер Zabbix

CurlAPI(){
# Запрос к API ElasticSearch

 # Параметры curl:
 #  --max-time		максимальное время операции в секундах;
 #  --no-keepalive	отключение keepalive-сообщений в TCP-соединении;
 #  --silent		отключение индикаторов загрузки и сообщений об ошибках;
 RespStr=$(/usr/bin/curl --max-time 20 --no-keepalive --silent "http://127.0.0.1:9200/$REQ" | /etc/zabbix/scripts/JSON.sh -l 2>/dev/null)
 # Статистика недоступна - возврат статуса сервиса - 'не работает'
 [ $? != 0 ] && echo 0 && exit 1
}

if [ "$2" = "cluster" ];then
REQ='_cluster/health'
CurlAPI 
OutStr=$((cat <<EOF
$RespStr
EOF
) | awk -F\\t '$1~/^((active_primary|active|initializing|relocating|unassigned)_shards|(number_of_data|number_of)_nodes|status)$/ {
 if( $2 == "green"  ) $2 = 0
 if( $2 == "yellow" ) $2 = 1
 if( $2 == "red"    ) $2 = 2
 print  $1, int($2)
}')

echo $OutStr | xargs -n2 | grep -w $1 | sed 's/[^0-9]*//g'
exit 0
fi

if [ "$2" = "nodes" ]; then
REQ='_nodes/_local/stats/indices,jvm'
CurlAPI
# Фильтрация, форматирование данных статистики
OutStr=$((cat <<EOF
$RespStr
EOF
) | awk -F\\t '$1~/(indices.(docs.(count|deleted)|store.size_in_bytes|indexing.(index_total|index_current|delete_total|delete_current)|get.(total|exists_total|missing_total|current)|search.(open_contexts|query_total|query_current|fetch_total|fetch_current)|merges.(current|current_docs|current_size_in_bytes|total|total_docs|total_size_in_bytes)|(refresh|flush).total|warmer.(current|total)|(filter_cache|id_cache|fielddata).memory_size_in_bytes|percolate.(total|current|memory_size_in_bytes|queries)|completion.size_in_bytes|segments.(count|memory_in_bytes)|translog.(operations|size_in_bytes)|suggest.(total|current))|jvm.(mem.(heap_(used|committed)_in_bytes|non_heap_(used|committed)_in_bytes)|threads.count))$/ {
 sub("^nodes.[^.]+.", "", $1)
 print $1, int($2)
}')
echo $OutStr | xargs -n2 | grep -w $1 | sed 's/[^0-9]*//g'
exit 0
fi

if [ "$1" = "status" ];then
	echo 1
fi
