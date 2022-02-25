# Домашнее задание к занятию "6.3. MySQL"

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.

```bash
vagrant@server1:~/postgres-dz$ docker pull mysql:8.0.28-debian
vagrant@server1:~/mysql-dz$ cat docker-compose.yaml 
version: '3.9'

services:
  db:
    image: mysql:8.0.28-debian
    container_name: mysql
    command: --default-authentication-plugin=mysql_native_password
    environment:
      MYSQL_ROOT_PASSWORD: password1
    volumes:
      - /home/vagrant/mysql-dz/mysql-data:/var/lib/mysql/
    ports:
      - "3306:3306"
    restart: always
vagrant@server1:~/mysql-dz$ docker-compose up --no-start
Creating network "mysql-dz_default" with the default driver
vagrant@server1:~/mysql-dz$ docker-compose start
Starting db ... done
vagrant@server1:~/mysql-dz$ sudo apt-get install mysql-client
vagrant@server1:~/mysql-dz$ mysql -h127.0.0.1 -uroot  -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 9
Server version: 8.0.28 MySQL Community Server - GPL
mysql> CREATE DATABASE test_db;
Query OK, 1 row affected (0.02 sec)


Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и 
восстановитесь из него.
vagrant@server1:~/mysql-dz$ mysql -h127.0.0.1 -uroot  -p test_db  < test_dump.sql 


Перейдите в управляющую консоль `mysql` внутри контейнера.

Используя команду `\h` получите список управляющих команд.

Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.
```sql
mysql> \s;
--------------
mysql  Ver 8.0.28-0ubuntu0.20.04.3 for Linux on x86_64 ((Ubuntu))
```

Подключитесь к восстановленной БД и получите список таблиц из этой БД.

**Приведите в ответе** количество записей с `price` > 300.
```sql
mysql> select * from orders where price>300;
+----+----------------+-------+
| id | title          | price |
+----+----------------+-------+
|  2 | My little pony |   500 |
+----+----------------+-------+
1 row in set (0.00 sec)
mysql> select count(*) from orders where price>300;
+----------+
| count(*) |
+----------+
|        1 |
+----------+
1 row in set (0.00 sec)

```

В следующих заданиях мы будем продолжать работу с данным контейнером.

## Задача 2

Создайте пользователя test в БД c паролем test-pass, используя:
- плагин авторизации mysql_native_password
- срок истечения пароля - 180 дней 
- количество попыток авторизации - 3 
- максимальное количество запросов в час - 100
- аттрибуты пользователя:
    - Фамилия "Pretty"
    - Имя "James"

```sql
mysql> CREATE USER 'test'@'%'
    -> IDENTIFIED WITH mysql_native_password BY 'test-pass'
    -> PASSWORD EXPIRE INTERVAL 180 DAY
    -> FAILED_LOGIN_ATTEMPTS 3
    -> ATTRIBUTE '{"name": "James", "surname": "Pretty"}';
Query OK, 0 rows affected (0.01 sec)
mysql> ALTER USER 'test'@'%' WITH MAX_QUERIES_PER_HOUR 100;
Query OK, 0 rows affected (0.01 sec)

Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.
mysql> GRANT SELECT ON test_db.* TO 'test'@'%';
Query OK, 0 rows affected (0.00 sec)
mysql> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.01 sec)
```
    
Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и 
**приведите в ответе к задаче**.
```sql
mysql> SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES where user='test';
+------+------+----------------------------------------+
| USER | HOST | ATTRIBUTE                              |
+------+------+----------------------------------------+
| test | %    | {"name": "James", "surname": "Pretty"} |
+------+------+----------------------------------------+
mysql> select host,user,password_lifetime,max_questions,plugin from user where user='test';
+------+------+-------------------+---------------+-----------------------+
| host | user | password_lifetime | max_questions | plugin                |
+------+------+-------------------+---------------+-----------------------+
| %    | test |               180 |           100 | mysql_native_password |
+------+------+-------------------+---------------+-----------------------+
1 row in set (0.01 sec)

vagrant@server1:~/mysql-dz$ mysql -p -h127.0.0.1 -utest test_db
mysql> select * from orders;
+----+-----------------------+-------+
| id | title                 | price |
+----+-----------------------+-------+
|  1 | War and Peace         |   100 |
|  2 | My little pony        |   500 |
|  3 | Adventure mysql times |   300 |
|  4 | Server gravity falls  |   300 |
|  5 | Log gossips           |   123 |
+----+-----------------------+-------+
5 rows in set (0.00 sec)

mysql> delete from orders where id=1;
ERROR 1142 (42000): DELETE command denied to user 'test'@'172.20.0.1' for table 'orders'



```

## Задача 3

Установите профилирование `SET profiling = 1`.
Изучите вывод профилирования команд `SHOW PROFILES;`.

Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.
```sql
mysql> show create table orders;
| orders | CREATE TABLE `orders` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(80) NOT NULL,
  `price` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci |
	
```

Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
- на `MyISAM`

```sql
mysql> ALTER TABLE orders ENGINE = 'MYISAM';
Query OK, 5 rows affected (0.04 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> SHOW PROFILE;
+--------------------------------+----------+
| Status                         | Duration |
+--------------------------------+----------+
| starting                       | 0.000130 |
| Executing hook on transaction  | 0.000017 |
| starting                       | 0.000043 |
| checking permissions           | 0.000017 |
| checking permissions           | 0.000015 |
| init                           | 0.000029 |
| Opening tables                 | 0.000629 |
| setup                          | 0.000318 |
| creating table                 | 0.008714 |
| waiting for handler commit     | 0.000037 |
| waiting for handler commit     | 0.005198 |
| After create                   | 0.000954 |
| System lock                    | 0.000028 |
| copy to tmp table              | 0.000219 |
| waiting for handler commit     | 0.000022 |
| waiting for handler commit     | 0.000028 |
| waiting for handler commit     | 0.000068 |
| rename result table            | 0.000188 |
| waiting for handler commit     | 0.010541 |
| waiting for handler commit     | 0.000016 |
| waiting for handler commit     | 0.002748 |
| waiting for handler commit     | 0.000012 |
| waiting for handler commit     | 0.005914 |
| waiting for handler commit     | 0.000012 |
| waiting for handler commit     | 0.002406 |
| end                            | 0.003997 |
| query end                      | 0.001493 |
| closing tables                 | 0.000006 |
| waiting for handler commit     | 0.000013 |
| freeing items                  | 0.000259 |
| cleaning up                    | 0.000020 |
+--------------------------------+----------+
31 rows in set, 1 warning (0.00 sec)

mysql> show create table orders;
+--------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Table  | Create Table                                                                                                                                                                                                                              |
+--------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| orders | CREATE TABLE `orders` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(80) NOT NULL,
  `price` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci |
+--------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)
```

- на `InnoDB`

```sql
mysql> ALTER TABLE orders ENGINE=InnoDB;
Query OK, 5 rows affected (0.07 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> SHOW PROFILE;
+--------------------------------+----------+
| Status                         | Duration |
+--------------------------------+----------+
| starting                       | 0.000124 |
| Executing hook on transaction  | 0.000018 |
| starting                       | 0.000039 |
| checking permissions           | 0.000018 |
| checking permissions           | 0.000013 |
| init                           | 0.000026 |
| Opening tables                 | 0.000403 |
| setup                          | 0.000110 |
| creating table                 | 0.000174 |
| After create                   | 0.040453 |
| System lock                    | 0.000048 |
| copy to tmp table              | 0.000290 |
| rename result table            | 0.002182 |
| waiting for handler commit     | 0.000029 |
| waiting for handler commit     | 0.005544 |
| waiting for handler commit     | 0.000025 |
| waiting for handler commit     | 0.016280 |
| waiting for handler commit     | 0.000017 |
| waiting for handler commit     | 0.003747 |
| waiting for handler commit     | 0.000011 |
| waiting for handler commit     | 0.002817 |
| end                            | 0.000379 |
| query end                      | 0.001494 |
| closing tables                 | 0.000008 |
| waiting for handler commit     | 0.000378 |
| freeing items                  | 0.000403 |
| cleaning up                    | 0.000032 |
+--------------------------------+----------+
27 rows in set, 1 warning (0.00 sec)

mysql> show create table orders;
+--------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Table  | Create Table                                                                                                                                                                                                                              |
+--------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| orders | CREATE TABLE `orders` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(80) NOT NULL,
  `price` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci |
+--------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.01 sec)
```





## Задача 4 

Изучите файл `my.cnf` в директории /etc/mysql.

Измените его согласно ТЗ (движок InnoDB):
- Скорость IO важнее сохранности данных
- Нужна компрессия таблиц для экономии места на диске
- Размер буффера с незакомиченными транзакциями 1 Мб
- Буффер кеширования 30% от ОЗУ
- Размер файла логов операций 100 Мб

Приведите в ответе измененный файл `my.cnf`.
```bash
vagrant@server1:~/mysql-dz$ docker exec -it mysql bash
root@f9eae135d37d:/# cat /etc/mysql/my.cnf
[mysqld]
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
datadir         = /var/lib/mysql
secure-file-priv= NULL

# Custom config should go here
!includedir /etc/mysql/conf.d/

innodb_ﬂush_method	= O_DSYNC
innodb_ﬂush_log_at_trx_commit = 2
innodb_file_per_table   = 1 
innodb_log_buffer_size	= 1M
innodb_buffer_pool_size = 333M
innodb_log_ﬁle_size	= 100M


```

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
