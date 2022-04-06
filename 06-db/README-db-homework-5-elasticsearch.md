# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
```bash
vagrant@server1:~/elasticsearch$ cat Dockerfile
FROM centos:latest
#fix centos bug
RUN cd /etc/yum.repos.d/
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
#################################
RUN yum -y update; 
RUN yum install -y  java-17-openjdk
#RUN yum -y install java;
WORKDIR /home/vagrant/elasticsearch-8.1.1
COPY ./elasticsearch-8.1.1 /home/vagrant/elasticsearch-8.1.1
ARG ES_HOME=/home/vagrant/elasticsearch-8.1.1/
RUN mkdir -p /home/vagrant/elasticsearch-8.1.1/jdk/bin ; \
	#ln -s /usr/bin/java /home/vagrant/elasticsearch-8.1.1/jdk/bin/java; \
	mkdir /var/lib/elasticsearch ; \
        #pw useradd vagrant; \
	adduser vagrant  -d /home/vagrant ; \ 
	chown -R vagrant /var/lib/elasticsearch ;\
        chown -R vagrant /home/vagrant ;\
	#echo 'vm.max_map_count=262144' >> /etc/sysctl.conf
VOLUME /var/lib/elasticsearch
EXPOSE 9200

USER vagrant
CMD /home/vagrant/elasticsearch-8.1.1/bin/elasticsearch  -p pid  

- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
```bash
vagrant@server1:~/elasticsearch$ docker build -t andreyivanov87/elk:0.0.3 ./
Sending build context to Docker daemon  955.4MB
Step 1/14 : FROM centos:latest
 ---> 5d0da3dc9764
Step 2/14 : RUN cd /etc/yum.repos.d/
 ---> Using cache
 ---> f31fcf1774d6
Step 3/14 : RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
 ---> Using cache
 ---> 38bdb5dcda29
Step 4/14 : RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
 ---> Using cache
 ---> df3d6d9176e0
Step 5/14 : RUN yum -y update;
 ---> Using cache
 ---> 6c66e645bd0c
Step 6/14 : RUN yum install -y  java-17-openjdk
 ---> Using cache
 ---> 2e6784850284
Step 7/14 : WORKDIR /home/vagrant/elasticsearch-8.1.1
 ---> Using cache
 ---> 31001b54b16e
Step 8/14 : COPY ./elasticsearch-8.1.1 /home/vagrant/elasticsearch-8.1.1
 ---> a3a0957ab24b
Step 9/14 : ARG ES_HOME=/home/vagrant/elasticsearch-8.1.1/
 ---> Running in 03b4a7d784b8
Removing intermediate container 03b4a7d784b8
 ---> 7c8175b93a9a
Step 10/14 : RUN mkdir -p /home/vagrant/elasticsearch-8.1.1/jdk/bin ; 	mkdir /var/lib/elasticsearch ; 	adduser vagrant  -d /home/vagrant ; 	chown -R vagrant /var/lib/elasticsearch ;        chown -R vagrant /home/vagrant ;	echo 'vm.max_map_count=262144' >> /etc/sysctl.conf
 ---> Running in c370ce1bc6e0
adduser: warning: the home directory already exists.
Not copying any file from skel directory into it.
Removing intermediate container c370ce1bc6e0
 ---> 81b4cf8a8ac7
Step 11/14 : VOLUME /var/lib/elasticsearch
 ---> Running in 601c39214446
Removing intermediate container 601c39214446
 ---> ef1b4a1e2a12
Step 12/14 : EXPOSE 9200
 ---> Running in b249abf83706
Removing intermediate container b249abf83706
 ---> ca560d66fda4
Step 13/14 : USER vagrant
 ---> Running in e3b19d27d6a4
Removing intermediate container e3b19d27d6a4
 ---> f200a5d32a4c
Step 14/14 : CMD /home/vagrant/elasticsearch-8.1.1/bin/elasticsearch  -p pid
 ---> Running in 6fadc7388d8d
Removing intermediate container 6fadc7388d8d
 ---> 218fbcefb3cd
Successfully built 218fbcefb3cd
Successfully tagged andreyivanov87/elk:0.0.3
vagrant@server1:~/elasticsearch$ docker push andreyivanov87/elk:0.0.3
The push refers to repository [docker.io/andreyivanov87/elk]
367765adf468: Pushed 
399906bc1569: Pushed 
438f91c27670: Pushed 
7c0583d7e591: Pushed 
10eb93e506f0: Pushed 
f2eff3b326d4: Pushed 
e5db9bccc8d9: Pushed 
74ddd0ec08fa: Mounted from library/centos 
0.0.3: digest: sha256:5428840c327d17a7ff6bc567c1937a0c85d13ca2bdbfd9cc7b91ff847538bb3a size: 2004

```
https://hub.docker.com/r/andreyivanov87/elk  

- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

```bash
vagrant@server1:~/elasticsearch$ docker network create --subnet=172.18.0.0/16 elk
vagrant@server1:~/elasticsearch$ docker run   -itd  -p 9000:9200 --net elk --ip 172.18.0.2  -v /var/lib/elasticsearch:/var/lib/elasticsearch andreyivanov87/elk:0.0.4 
e176b6752575edaa05b1b05ec61e9be0a70d33d9e43d39297429d464209f5cf5
vagrant@server1:~/elasticsearch$ curl -X GET "http://127.0.0.1:9000/"
{
  "name" : "netology_test",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "ymqb8158Si2qvkaK_5s9GA",
  "version" : {
    "number" : "8.1.1",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "d0925dd6f22e07b935750420a3155db6e5c58381",
    "build_date" : "2022-03-17T22:01:32.658689558Z",
    "build_snapshot" : false,
    "lucene_version" : "9.0.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
vagrant@server1:~/elasticsearch$ docker ps
CONTAINER ID   IMAGE                      COMMAND                  CREATED         STATUS         PORTS                                       NAMES
e176b6752575   andreyivanov87/elk:0.0.4   "/bin/sh -c '/home/v…"   3 minutes ago   Up 2 minutes   0.0.0.0:9000->9200/tcp, :::9000->9200/tcp   intelligent_bell

```

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста
- ссылку на образ в репозитории dockerhub
- ответ `elasticsearch` на запрос пути `/` в json виде

Подсказки:
- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch.

## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

```bash
vagrant@server1:~/elasticsearch$ curl -X PUT "172.18.0.2:9200/ind-1?pretty" -H 'Content-Type: application/json' -d' {   "settings": {     "index": {       "number_of_shards": 1,         "number_of_replicas": 0      }   } } ' 
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-1"
}

vagrant@server1:~/elasticsearch$ curl -X PUT "172.18.0.2:9200/ind-2?pretty" -H 'Content-Type: application/json' -d' {   "settings": {     "index": {       "number_of_shards": 2,         "number_of_replicas": 1      }   } } ' 
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-2"
}
vagrant@server1:~/elasticsearch$ curl -X PUT "172.18.0.2:9200/ind-3?pretty" -H 'Content-Type: application/json' -d' {   "settings": {     "index": {       "number_of_shards": 4,         "number_of_replicas": 2      }   } } ' 
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-3"
}
```

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.
```bash
vagrant@server1:~/elasticsearch$ curl -X GET "http://172.18.0.2:9200/_cat/shards?pretty"
ind-2            1 p STARTED    0 225b 172.18.0.2 netology_test
ind-2            1 r UNASSIGNED                   
ind-2            0 p STARTED    0 225b 172.18.0.2 netology_test
ind-2            0 r UNASSIGNED                   
.geoip_databases 0 p STARTED           172.18.0.2 netology_test
ind-1            0 p STARTED    0 225b 172.18.0.2 netology_test
ind-3            2 p STARTED    0 225b 172.18.0.2 netology_test
ind-3            2 r UNASSIGNED                   
ind-3            2 r UNASSIGNED                   
ind-3            3 p STARTED    0 225b 172.18.0.2 netology_test
ind-3            3 r UNASSIGNED                   
ind-3            3 r UNASSIGNED                   
ind-3            1 p STARTED    0 225b 172.18.0.2 netology_test
ind-3            1 r UNASSIGNED                   
ind-3            1 r UNASSIGNED                   
ind-3            0 p STARTED    0 225b 172.18.0.2 netology_test
ind-3            0 r UNASSIGNED                   
ind-3            0 r UNASSIGNED                   
vagrant@server1:~/elasticsearch$ curl -X GET "http://172.18.0.2:9200/_cat/indices?pretty"
green  open ind-1 _hmw-tGORY-Dr3H9R0tSew 1 0 0 0 225b 225b
yellow open ind-3 CzGMGPgfT_aLmR-gaLZxbQ 4 2 0 0 900b 900b
yellow open ind-2 KnqtaIZgTUS7Dmg1arC0hg 2 1 0 0 450b 450b

```

Получите состояние кластера `elasticsearch`, используя API.
```bash
vagrant@server1:~/elasticsearch$ curl -X GET "http://172.18.0.2:9200/_cluster/health?pretty"
{
  "cluster_name" : "elasticsearch",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 8,
  "active_shards" : 8,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 44.44444444444444
}

```


Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?  
	В кластере настроена только одна нода, поэтому все индексы где число реплик больше нуля не могут разместить их на других нодах и создают только на одной мастер ноде нужное число шардов без репликации.  
Удалите все индексы.
```bash
vagrant@server1:~/elasticsearch$ curl -X DELETE "http://172.18.0.2:9200/ind-3"
{"acknowledged":true}
vagrant@server1:~/elasticsearch$ curl -X DELETE "http://172.18.0.2:9200/ind-2?pretty"
{
  "acknowledged" : true
}
vagrant@server1:~/elasticsearch$ curl -X DELETE "http://172.18.0.2:9200/ind-1?pretty"
{
  "acknowledged" : true
}
```

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.
```bash
vagrant@server1:~/elasticsearch$ docker exec -it elk-4-good bash
bash-4.4$ mkdir snapshots
```

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.
```bash
vagrant@server1:~/elasticsearch$ curl -X PUT "172.18.0.2:9200/_snapshot/netology_backup?pretty" -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "/home/vagrant/elasticsearch-8.1.1/snapshots"
  }
}
'
{
  "acknowledged" : true
}
```


Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.
```bash
vagrant@server1:~/elasticsearch$ curl -X GET "http://172.18.0.2:9200/_cat/indices?pretty"
green open test VMzJC-YfS4y7BwLKGOGZJw 1 0 0 0 225b 225b
```
[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.
```bash
vagrant@server1:~/elasticsearch$ curl -X PUT "172.18.0.2:9200/_snapshot/netology_backup/my_snapshot_2022-04?wait_for_completion=true&pretty"
{
  "snapshot" : {
    "snapshot" : "my_snapshot_2022-04",
    "uuid" : "SNvQ0JtVRtW_fS2axF1vyA",
    "repository" : "netology_backup",
    "version_id" : 8010199,
    "version" : "8.1.1",
    "indices" : [
      "test",
      ".geoip_databases"
    ],
    "data_streams" : [ ],
    "include_global_state" : true,
    "state" : "SUCCESS",
    "start_time" : "2022-04-06T12:23:31.037Z",
    "start_time_in_millis" : 1649247811037,
    "end_time" : "2022-04-06T12:23:32.240Z",
    "end_time_in_millis" : 1649247812240,
    "duration_in_millis" : 1203,
    "failures" : [ ],
    "shards" : {
      "total" : 2,
      "failed" : 0,
      "successful" : 2
    },
    "feature_states" : [
      {
        "feature_name" : "geoip",
        "indices" : [
          ".geoip_databases"
        ]
      }
    ]
  }
}
```
**Приведите в ответе** список файлов в директории со `snapshot`ами.
```bash
bash-4.4$ ls snapshots/
index-0  index.latest  indices	meta-SNvQ0JtVRtW_fS2axF1vyA.dat  snap-SNvQ0JtVRtW_fS2axF1vyA.dat
```

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.
```bash
vagrant@server1:~/elasticsearch$ curl -X DELETE "http://172.18.0.2:9200/test?pretty"
{
  "acknowledged" : true
}
vagrant@server1:~/elasticsearch$ curl -X PUT "172.18.0.2:9200/test-2?pretty" -H 'Content-Type: application/json' -d' {   "settings": {     "index": {       "number_of_shards": 1,         "number_of_replicas": 0      }   } } '
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "test-2"
}
vagrant@server1:~/elasticsearch$ curl -X GET "http://172.18.0.2:9200/_cat/indices?pretty"
green open test-2 dvPhMnKSTsOkh6tVi-GWgw 1 0 0 0 225b 225b
```

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.
```bash
vagrant@server1:~/elasticsearch$ curl -X PUT "localhost:9200/_cluster/settings?pretty" -H 'Content-Type: application/json' -d'
> {
>   "persistent": {
>     "action.destructive_requires_name": false
>   }
> }
> '
{
  "acknowledged" : true,
  "persistent" : {
    "action" : {
      "destructive_requires_name" : "false"
    }
  },
  "transient" : { }
}
vagrant@server1:~/elasticsearch$ curl -X DELETE "localhost:9200/*?expand_wildcards=all&pretty"
{
  "acknowledged" : true
}
vagrant@server1:~/elasticsearch$ curl -X GET "http://172.18.0.2:9200/_cat/indices?pretty"

vagrant@server1:~/elasticsearch$ curl -X POST "172.18.0.2:9200/_snapshot/netology_backup/my_snapshot_2022-04/_restore?pretty" -H 'Content-Type: application/json' -d'
> {
>   "indices": "*",
>   "include_global_state": true
> }
> '
{
  "accepted" : true
}
vagrant@server1:~/elasticsearch$ curl -X GET "http://172.18.0.2:9200/_cat/indices?pretty"
green open test Y8Ko2UMJS3-DgrwzMakVEw 1 0 0 0 225b 225b


```

Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`
```bash
vagrant@server1:~/elasticsearch$ cat elasticsearch-8.1.1/config/elasticsearch.yml | grep repo
path.repo: /home/vagrant/elasticsearch-8.1.1/snapshots
```
---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
