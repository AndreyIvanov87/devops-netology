# Домашнее задание к занятию "6.2. SQL"

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.

vagrant@server1:~$ docker pull postgres:12.10
#vagrant@server1:~$ docker run -d  -p 5432:5432 -e POSTGRES_PASSWORD=password postgres:12.10 
vagrant@server1:~/postgres-dz$ cat docker-compose.yaml 
version: '3.9'
services:
  postgres:
    image: postgres:12.10
    container_name: postgres
    environment:
      #POSTGRES_DB: "test_db"
      #POSTGRES_USER: "admin"
      POSTGRES_PASSWORD: "password1"
      PGDATA: "/var/lib/postgresql/data/pgdata"
    volumes:
      - /home/vagrant/postgres-dz/postgres-data:/var/lib/postgresql/data
      - /home/vagrant/postgres-dz/postgres-backup:/backup
    ports:
      - "5432:5432"
    restart: always



## Задача 2

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db
```sql
postgres=# CREATE DATABASE test_db;
CREATE DATABASE
postgres=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
(4 rows)
postgres=# CREATE USER "test-admin-user" WITH PASSWORD 'password2';
CREATE ROLE
postgres=# SELECT usename FROM pg_user;
     usename     
-----------------
 postgres
 test-admin-user
(2 rows)

```
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
```sql
postgres=# \c test_db;
psql (12.9 (Ubuntu 12.9-0ubuntu0.20.04.1), server 12.10 (Debian 12.10-1.pgdg110+1))
You are now connected to database "test_db" as user "postgres".
test_db=# CREATE TABLE orders (id serial primary key, наименование CHAR(20) , цена numeric);
CREATE TABLE
test_db=# CREATE TABLE clients (id serial primary key, фамилия CHAR(20) , "страна проживания" CHAR(20) , заказ int ,   FOREIGN KEY (заказ) REFERENCES orders (id) );
CREATE TABLE
test_db=# CREATE  INDEX country_ind ON clients ("страна проживания");
CREATE INDEX

```
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db  
	test_db=# GRANT ALL PRIVILEGES ON clients,orders TO "test-admin-user" ;
	GRANT
	test_db=# GRANT USAGE, SELECT ON SEQUENCE clients_id_seq TO "test-admin-user";
	test_db=# GRANT USAGE, SELECT ON SEQUENCE orders_id_seq TO "test-admin-user";

- создайте пользователя test-simple-user  
	test_db=# CREATE USER "test-simple-user" WITH PASSWORD 'password3';  
	CREATE ROLE  

- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db  
	test_db=# GRANT SELECT,INSERT,UPDATE,DELETE ON clients,orders TO "test-simple-user" ;  
	GRANT  
	GRANT USAGE, SELECT ON SEQUENCE orders_id_seq TO "test-simple-user";  
	GRANT  

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Приведите:
- итоговый список БД после выполнения пунктов выше,
```sql
test_db=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =Tc/postgres         +
           |          |          |            |            | postgres=CTc/postgres
(4 rows)

```
- описание таблиц (describe)
```sql
test_db=# \d orders;
                                  Table "public.orders"
    Column    |     Type      | Collation | Nullable |              Default               
--------------+---------------+-----------+----------+------------------------------------
 id           | integer       |           | not null | nextval('orders_id_seq'::regclass)
 наименование | character(20) |           |          | 
 цена         | numeric       |           |          | 
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)
test_db=# \d clients
                                     Table "public.clients"
      Column       |     Type      | Collation | Nullable |               Default               
-------------------+---------------+-----------+----------+-------------------------------------
 id                | integer       |           | not null | nextval('clients_id_seq'::regclass)
 фамилия           | character(20) |           |          | 
 страна проживания | character(20) |           |          | 
 заказ             | integer       |           |          | 
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
    "country_ind" btree ("страна проживания")
Foreign-key constraints:
    "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)

```
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
- список пользователей с правами над таблицами test_db
```sql
test_db=# \dp clients;
                                      Access privileges
 Schema |  Name   | Type  |         Access privileges          | Column privileges | Policies 
--------+---------+-------+------------------------------------+-------------------+----------
 public | clients | table | postgres=arwdDxt/postgres         +|                   | 
        |         |       | "test-admin-user"=arwdDxt/postgres+|                   | 
        |         |       | "test-simple-user"=arwd/postgres   |                   | 
(1 row)

test_db=# \dp orders;
                                      Access privileges
 Schema |  Name  | Type  |         Access privileges          | Column privileges | Policies 
--------+--------+-------+------------------------------------+-------------------+----------
 public | orders | table | postgres=arwdDxt/postgres         +|                   | 
        |        |       | "test-admin-user"=arwdDxt/postgres+|                   | 
        |        |       | "test-simple-user"=arwd/postgres   |                   | 
(1 row)
```


## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
- приведите в ответе:
    - запросы 
    - результаты их выполнения.
```sql
You are now connected to database "test_db" as user "test-admin-user".
test_db=> INSERT INTO orders (наименование,цена) VALUES ('Шоколад','10');
test_db=> INSERT INTO orders (наименование,цена) VALUES ('Принтер','3000');
test_db=> INSERT INTO orders (наименование,цена) VALUES ('Книга','500');
test_db=> INSERT INTO orders (наименование,цена) VALUES ('Монитор','7000');
test_db=> INSERT INTO orders (наименование,цена) VALUES ('Гитара','4000');
test_db=> select * from orders;
 id |     наименование     | цена 
----+----------------------+------
  1 | Шоколад              |   10
  2 | Принтер              | 3000
  3 | Книга                |  500
  4 | Монитор              | 7000
  5 | Гитара               | 4000
(5 rows)

test_db=> select count(*) from orders;
 count 
-------
     5
(1 row)
test_db=> INSERT INTO clients (фамилия,"страна проживания") VALUES ('Иванов Иван Иванович','USA');
test_db=> INSERT INTO clients (фамилия,"страна проживания") VALUES ('Петров Петр Петрович','Canada');
test_db=> INSERT INTO clients (фамилия,"страна проживания") VALUES ('Иоганн Себастьян Бах','Japan');
test_db=> INSERT INTO clients (фамилия,"страна проживания") VALUES ('Ронни Джеймс Дио','Russia');
test_db=> INSERT INTO clients (фамилия,"страна проживания") VALUES ('Ritchie Blackmore','Russia');
test_db=> select * from clients;
 id |       фамилия        |  страна проживания   | заказ 
----+----------------------+----------------------+-------
  1 | Иванов Иван Иванович | USA                  |     
  2 | Петров Петр Петрович | Canada               |     
  3 | Иоганн Себастьян Бах | Japan                |     
  4 | Ронни Джеймс Дио     | Russia               |     
  5 | Ritchie Blackmore    | Russia               |     
(5 rows)

test_db=> select count(*) from clients;
 count 
-------
     5
(1 row)


```

## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.
```sql
test_db=> update clients set заказ=(select id from orders where наименование='Книга') where фамилия='Иванов Иван Иванович';
test_db=> update clients set заказ=(select id from orders where наименование='Монитор') where фамилия='Петров Петр Петрович';
test_db=> update clients set заказ=(select id from orders where наименование='Гитара') where фамилия='Иоганн Себастьян Бах';

```
Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.
```sql
test_db=> SELECT * FROM clients INNER JOIN orders ON clients.заказ=orders.id;
 id |       фамилия        |  страна проживания   | заказ | id |     наименование     | цена 
----+----------------------+----------------------+-------+----+----------------------+------
  1 | Иванов Иван Иванович | USA                  |     3 |  3 | Книга                |  500
  2 | Петров Петр Петрович | Canada               |     4 |  4 | Монитор              | 7000
  3 | Иоганн Себастьян Бах | Japan                |     5 |  5 | Гитара               | 4000
(3 rows)
test_db=>  SELECT a.id, a.фамилия, b.id , b.наименование, b.цена FROM clients a INNER JOIN orders b ON a.заказ=b.id;
 id |       фамилия        | id |     наименование     | цена 
----+----------------------+----+----------------------+------
  1 | Иванов Иван Иванович |  3 | Книга                |  500
  2 | Петров Петр Петрович |  4 | Монитор              | 7000
  3 | Иоганн Себастьян Бах |  5 | Гитара               | 4000
(3 rows)

``` 
Подсказк - используйте директиву `UPDATE`.

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.
```sql
test_db=> EXPLAIN  SELECT a.id, a.фамилия, b.id , b.наименование, b.цена FROM clients a INNER JOIN orders b ON a.заказ=b.id;
                               QUERY PLAN                                
-------------------------------------------------------------------------
 Hash Join  (cost=22.38..37.44 rows=400 width=208)
   Hash Cond: (a."заказ" = b.id)
   ->  Seq Scan on clients a  (cost=0.00..14.00 rows=400 width=92)
   ->  Hash  (cost=15.50..15.50 rows=550 width=120)
         ->  Seq Scan on orders b  (cost=0.00..15.50 rows=550 width=120)
(5 rows)
```
Seq Scan — последовательное, блок за блоком, чтение данных таблицы clients  
Сначала просматривается (Seq Scan) таблица clients. Для каждой её строки вычисляется хэш (Hash).  
Затем сканируется Seq Scan таблица orders, и для каждой строки этой таблицы вычисляется хэш, который сравнивается (Hash Join) с хэшем таблицы bar по условию Hash Cond. Если соответствие найдено, выводится результирующая строка, иначе строка будет пропущена.  
cost=0.00..14.00 понятие, призванное оценить затратность операции. Первое значение 0.00 — затраты на получение первой строки. Второе — 14.00 — затраты на получение всех строк.  
rows — приблизительное количество возвращаемых строк при выполнении операции Seq Scan. Это значение возвращает планировщик.  
width — средний размер одной строки в байтах.  




## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления. 
```bash
vagrant@server1:~/postgres-dz$ docker ps
CONTAINER ID   IMAGE            COMMAND                  CREATED      STATUS      PORTS                                       NAMES
5082278feb01   postgres:12.10   "docker-entrypoint.s…"   2 days ago   Up 2 days   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp   postgres
vagrant@server1:~/postgres-dz$ docker exec -it postgres bash
root@5082278feb01:/# cd /backup/
root@5082278feb01:/backup# pg_dump -h localhost  -O -F p -c -U postgres test_db  > mydb.sql
vagrant@server1:~/postgres-dz$ docker-compose ps
  Name                Command              State                    Ports                  
-------------------------------------------------------------------------------------------
postgres   docker-entrypoint.sh postgres   Up      0.0.0.0:5432->5432/tcp,:::5432->5432/tcp
vagrant@server1:~/postgres-dz$ docker-compose stop postgres
Stopping postgres ... done
vagrant@server1:/tmp$ cat docker-compose.yaml 
version: '3.9'


services:
  postgres:
    image: postgres:12.10
    container_name: postgres-test-restore
    environment:
      #POSTGRES_DB: "test_db"
      #POSTGRES_USER: "admin"
      POSTGRES_PASSWORD: "password1"
      PGDATA: "/var/lib/postgresql/data/pgdata"
    volumes:
      - /home/vagrant/postgres-dz/postgres-backup:/backup
    ports:
      - "5432:5432"
    restart: always
vagrant@server1:/tmp$ docker-compose up
Creating network "tmp_default" with the default driver
Starting postgres-test-restore ... done
Attaching to postgres-test-restore
^CGracefully stopping... (press Ctrl+C again to force)
Stopping postgres-test-restore ... done
vagrant@server1:/tmp$ docker-compose start
Starting postgres ... done
vagrant@server1:/tmp$ docker-compose ps
        Name                       Command              State                   Ports                
-----------------------------------------------------------------------------------------------------
postgres-test-restore   docker-entrypoint.sh postgres   Up      0.0.0.0:5432->5432/tcp,:::5432->5432/
                                                                tcp          
vagrant@server1:~/postgres-dz$ psql -U postgres -h localhost
Password for user postgres: 
psql (12.9 (Ubuntu 12.9-0ubuntu0.20.04.1), server 12.10 (Debian 12.10-1.pgdg110+1))
Type "help" for help.

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
postgres=# CREATE DATABASE test_db;
CREATE DATABASE

vagrant@server1:/tmp$ docker exec -it postgres-test-restore bash
root@521f1250da2c:/# ls /backup/
mydb.sql
root@521f1250da2c:/backup# psql -h localhost -U postgres -d test_db -f mydb.sql 

postgres=# \c test_db;
psql (12.9 (Ubuntu 12.9-0ubuntu0.20.04.1), server 12.10 (Debian 12.10-1.pgdg110+1))
You are now connected to database "test_db" as user "postgres".
test_db=# \dt;
          List of relations
 Schema |  Name   | Type  |  Owner   
--------+---------+-------+----------
 public | clients | table | postgres
 public | orders  | table | postgres
(2 rows)

test_db=# select * from clients;
 id |       фамилия        |  страна проживания   | заказ 
----+----------------------+----------------------+-------
  4 | Ронни Джеймс Дио     | Russia               |      
  5 | Ritchie Blackmore    | Russia               |      
  1 | Иванов Иван Иванович | USA                  |     3
  2 | Петров Петр Петрович | Canada               |     4
  3 | Иоганн Себастьян Бах | Japan                |     5
(5 rows)





```

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
