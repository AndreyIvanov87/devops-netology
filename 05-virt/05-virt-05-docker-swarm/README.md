# Домашнее задание к занятию "5.5. Оркестрация кластером Docker контейнеров на примере Docker Swarm"

## Как сдавать задания

Обязательными к выполнению являются задачи без указания звездочки. Их выполнение необходимо для получения зачета и диплома о профессиональной переподготовке.

Задачи со звездочкой (*) являются дополнительными задачами и/или задачами повышенной сложности. Они не являются обязательными к выполнению, но помогут вам глубже понять тему.

Домашнее задание выполните в файле readme.md в github репозитории. В личном кабинете отправьте на проверку ссылку на .md-файл в вашем репозитории.

Любые вопросы по решению задач задавайте в чате учебной группы.

---

## Задача 1

Дайте письменые ответы на следующие вопросы:

- В чём отличие режимов работы сервисов в Docker Swarm кластере: replication и global?  
	replication указывает число нод, на которых надо поднять микросервис, global - поднимает сервис на каждой ноде в кластере.  
- Какой алгоритм выбора лидера используется в Docker Swarm кластере?  
	Raft.  
- Что такое Overlay Network?  
	это сетевой драйвер для соединения нескольких демонов Docker между собой и которые позволяют docker-swarm службам взаимодействовать друг с другом.  
## Задача 2  

Создать ваш первый Docker Swarm кластер в Яндекс.Облаке

Для получения зачета, вам необходимо предоставить скриншот из терминала (консоли), с выводом команды:
```bash
vagrant@server1:~/docker-swarm/src/terraform$ ssh centos@51.250.15.228
[centos@node01 ~]$ sudo -i
[root@node01 ~]# docker node list
ID                            HOSTNAME             STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
lra5v1wp8zey8ttnvvngjambx *   node01.netology.yc   Ready     Active         Leader           20.10.12
v3csuwsmb356y64iauoy8fhfh     node02.netology.yc   Ready     Active         Reachable        20.10.12
dnid5mqw3qcjzr0p5r4xnujj6     node03.netology.yc   Ready     Active         Reachable        20.10.12
np5ayk7f211nhexdjaxr3nn2o     node04.netology.yc   Ready     Active                          20.10.12
0m5cnvrw7bovg4i9jlf7vw3ja     node05.netology.yc   Ready     Active                          20.10.12
2raof3oe17a3lwauh3fby3u7b     node06.netology.yc   Ready     Active                          20.10.12

vagrant@server1:~/docker-swarm/src/terraform$ yc compute  instances list
+----------------------+--------+---------------+---------+---------------+----------------+
|          ID          |  NAME  |    ZONE ID    | STATUS  |  EXTERNAL IP  |  INTERNAL IP   |
+----------------------+--------+---------------+---------+---------------+----------------+
| fhmgqbvrp2reamdpb7h2 | node06 | ru-central1-a | RUNNING | 51.250.14.152 | 192.168.101.16 |
| fhmofdounneohbao3n53 | node04 | ru-central1-a | RUNNING | 51.250.4.150  | 192.168.101.14 |
| fhmoff3sd6rf6lp72q0b | node03 | ru-central1-a | RUNNING | 51.250.5.55   | 192.168.101.13 |
| fhmoupcokf31kue8dhhc | node01 | ru-central1-a | RUNNING | 51.250.15.228 | 192.168.101.11 |
| fhmsnjje22h5io67u3nk | node02 | ru-central1-a | RUNNING | 51.250.8.76   | 192.168.101.12 |
| fhmv53b4uil27kll99na | node05 | ru-central1-a | RUNNING | 51.250.14.100 | 192.168.101.15 |
+----------------------+--------+---------------+---------+---------------+----------------+

```

## Задача 3

Создать ваш первый, готовый к боевой эксплуатации кластер мониторинга, состоящий из стека микросервисов.

Для получения зачета, вам необходимо предоставить скриншот из терминала (консоли), с выводом команды:
```bash
[root@node01 ~]# docker service ls
ID             NAME                                MODE         REPLICAS   IMAGE                                          PORTS
ihbgjz0mf0qz   swarm_monitoring_alertmanager       replicated   1/1        stefanprodan/swarmprom-alertmanager:v0.14.0    
sru3c54sm9za   swarm_monitoring_caddy              replicated   1/1        stefanprodan/caddy:latest                      *:3000->3000/tcp, *:9090->9090/tcp, *:9093-9094->9093-9094/tcp
tm3acse7h5s4   swarm_monitoring_cadvisor           global       6/6        google/cadvisor:latest                         
7vwtffvyetqo   swarm_monitoring_dockerd-exporter   global       6/6        stefanprodan/caddy:latest                      
v8ccrhm7u46q   swarm_monitoring_grafana            replicated   1/1        stefanprodan/swarmprom-grafana:5.3.4           
qsf0g32k9mkb   swarm_monitoring_node-exporter      global       6/6        stefanprodan/swarmprom-node-exporter:v0.16.0   
m52wq8gfl92i   swarm_monitoring_prometheus         replicated   1/1        stefanprodan/swarmprom-prometheus:v2.5.0       
yhsmt8foxazm   swarm_monitoring_unsee              replicated   1/1        cloudflare/unsee:v0.8.0                        


```

## Задача 4 (*)

Выполнить на лидере Docker Swarm кластера команду (указанную ниже) и дать письменное описание её функционала, что она делает и зачем она нужна:
```
# см.документацию: https://docs.docker.com/engine/swarm/swarm_manager_locking/
docker swarm update --autolock=true
```

