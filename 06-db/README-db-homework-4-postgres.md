# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.
```bash
vagrant@server1:~/postgres-dz-2$ docker pull postgres:13.6
vagrant@server1:~/postgres-dz-2$ mkdir postgres-data/
vagrant@server1:~/postgres-dz-2$ cat docker-compose.yaml
version: '3.9'


services:
  postgres:
    image: postgres:13.6
    container_name: postgres13
    environment:
      #POSTGRES_DB: "test_db"
      #POSTGRES_USER: "admin"
      POSTGRES_PASSWORD: "password1"
      PGDATA: "/var/lib/postgresql/data/pgdata"
    volumes:
      - /home/vagrant/postgres-dz-2/postgres-data:/var/lib/postgresql/data  
    ports:
      - "5432:5432"
    restart: always
vagrant@server1:~/postgres-dz-2$ docker-compose up --no-start
Creating network "postgres-dz-2_default" with the default driver
Creating postgres13 ... done
vagrant@server1:~/postgres-dz-2$ docker-compose start
vagrant@server1:~/postgres-dz-2$ docker-compose ps
   Name                 Command              State                    Ports                  
---------------------------------------------------------------------------------------------
postgres13   docker-entrypoint.sh postgres   Up      0.0.0.0:5432->5432/tcp,:::5432->5432/tcp
```


Подключитесь к БД PostgreSQL используя `psql`.  
vagrant@server1:~$ psql -U postgres -h localhost  

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД
```sql
postgres=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
(3 rows)
```
- подключения к БД  
	\c[onnect] {[DBNAME|- USER|- HOST|- PORT|-] | conninfo}  
	connect to new database (currently "postgres")  
- вывода списка таблиц  
	\dt;  
- вывода описания содержимого таблиц  
	\d tablename;  
	структура таблицы tablename.  
- выхода из psql  
	\q  quit psql  


## Задача 2

Используя `psql` создайте БД `test_database`.  
	postgres=# CREATE DATABASE test_database;  
	CREATE DATABASE  

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.
```bash
vagrant@server1:~/postgres-dz-2$ psql -h localhost -U postgres -d test_database -f /home/vagrant/postgres-dz-2/test_dump.sql  
Password for user postgres: 
SET
SET
SET
SET
SET
 set_config 
------------
 
(1 row)

SET
SET
SET
SET
SET
SET
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
ALTER TABLE
COPY 8
 setval 
--------
      8
(1 row)

ALTER TABLE
```


Перейдите в управляющую консоль `psql` внутри контейнера.
	vagrant@server1:~/postgres-dz-2$ docker exec -it postgres13 bash  
	root@557b250e3e45:/# psql -h localhost -U postgres -d test_database  
	psql (13.6 (Debian 13.6-1.pgdg110+1))  

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.
	test_database=# ANALYZE orders;  
	ANALYZE  

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` с наибольшим средним значением размера элементов в байтах.  
```sql
test_database=# SELECT attname,avg_width FROM pg_stats WHERE tablename='orders' ORDER BY avg_width DESC LIMIT 1; 
 attname | avg_width 
---------+-----------
 title   |        16
(1 row)
```

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.
```sql
test_database=# BEGIN;
BEGIN
test_database=# ALTER TABLE orders RENAME TO ordersold;
ALTER TABLE
test_database=*# CREATE TABLE orders ( 
    id integer NOT NULL,
    title character varying(80) NOT NULL,
    price integer DEFAULT 0
) PARTITION BY RANGE (price);
CREATE TABLE
test_database=*# CREATE TABLE orders_500 PARTITION OF orders FOR VALUES FROM ('0') TO ('500');
CREATE TABLE
test_database=*# CREATE TABLE orders_10000 PARTITION OF orders FOR VALUES FROM ('500') TO ('10000');
CREATE TABLE
test_database=*# INSERT INTO orders SELECT * FROM ordersold;
INSERT 0 8
test_database=*# drop table ordersold;
DROP TABLE
test_database=*# COMMIT;
COMMIT
test_database=# select * from orders_500; 
 id |        title         | price 
----+----------------------+-------
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  7 | Me and my bash-pet   |   499
(5 rows)

test_database=# select * from orders_10000; 
 id |       title        | price 
----+--------------------+-------
  2 | My little database |   500
  6 | WAL never lies     |   900
  8 | Dbiezdmin          |   501
(3 rows)

test_database=# select * from orders; 
 id |        title         | price 
----+----------------------+-------
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  7 | Me and my bash-pet   |   499
  2 | My little database   |   500
  6 | WAL never lies       |   900
  8 | Dbiezdmin            |   501
(8 rows)
```

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?  
Да, как сделано выше это можно сделать при создании таблицы.   
Преобразовать обычную таблицу в секционированную и наоборот нельзя.  
  
## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.
```bash
vagrant@server1:~/postgres-dz-2$ docker exec -it  postgres13 bash
root@557b250e3e45:/# cd /var/lib/postgresql/data/pgdata/
root@557b250e3e45:/var/lib/postgresql/data/pgdata# pg_dump -h localhost  -O -F p -c -U postgres test_database  > test_database.sql
exit
vagrant@server1:~/postgres-dz-2$ sudo mv  postgres-data/pgdata/test_database.sql test_database.sql-new
```

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?  
после CREATE TABLE конструкций добавить   
ALTER TABLE  orders  ADD UNIQUE (title, price);	 
но до заполнения таблиц данными

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
