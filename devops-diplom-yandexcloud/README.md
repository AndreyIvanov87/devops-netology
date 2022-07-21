# Дипломный практикум в YandexCloud
  * [Цели:](#цели)
  * [Этапы выполнения:](#этапы-выполнения)
      * [Регистрация доменного имени](#регистрация-доменного-имени)
      * [Создание инфраструктуры](#создание-инфраструктуры)
          * [Установка Nginx и LetsEncrypt](#установка-nginx)
          * [Установка кластера MySQL](#установка-mysql)
          * [Установка WordPress](#установка-wordpress)
          * [Установка Gitlab CE, Gitlab Runner и настройка CI/CD](#установка-gitlab)
          * [Установка Prometheus, Alert Manager, Node Exporter и Grafana](#установка-prometheus)
  * [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
  * [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)

---
## Цели:

1. Зарегистрировать доменное имя (любое на ваш выбор в любой доменной зоне).
2. Подготовить инфраструктуру с помощью Terraform на базе облачного провайдера YandexCloud.
3. Настроить внешний Reverse Proxy на основе Nginx и LetsEncrypt.
4. Настроить кластер MySQL.
5. Установить WordPress.
6. Развернуть Gitlab CE и Gitlab Runner.
7. Настроить CI/CD для автоматического развёртывания приложения.
8. Настроить мониторинг инфраструктуры с помощью стека: Prometheus, Alert Manager и Grafana.

---
## Этапы выполнения:

### Регистрация доменного имени

Подойдет любое доменное имя на ваш выбор в любой доменной зоне.

ПРИМЕЧАНИЕ: Далее в качестве примера используется домен `you.domain` замените его вашим доменом.

Рекомендуемые регистраторы:
  - [nic.ru](https://nic.ru)
  - [reg.ru](https://reg.ru)

Цель:

1. Получить возможность выписывать [TLS сертификаты](https://letsencrypt.org) для веб-сервера.

Ожидаемые результаты:

1. У вас есть доступ к личному кабинету на сайте регистратора.
2. Вы зарезистрировали домен и можете им управлять (редактировать dns записи в рамках этого домена).

Зарегистрирован домен netology.tech , поддомен gate.netology.tech делегирован на доменные сервера Яндекса для возможности управления А-записями в облаке. Делегирован не весь домен, чтобы сохранить возможность управлять остальными записями в панели регистратора. Это не даст управлять записью без www, но в задании к этому требования не было, поэтому выбрана такая схема. Остальные записи указаны как CNAME на делегированный поддомен.  
https://github.com/AndreyIvanov87/devops-netology/blob/main/devops-diplom-yandexcloud/r01-domain-control.png





### Создание инфраструктуры

Для начала необходимо подготовить инфраструктуру в YC при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
- Следует использовать последнюю стабильную версию [Terraform](https://www.terraform.io/).

Предварительная подготовка:

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:
   а. Рекомендуемый вариант: [Terraform Cloud](https://app.terraform.io/)  
   б. Альтернативный вариант: S3 bucket в созданном YC аккаунте.  

Terraform Cloud не доступен без впн, поэтому выбран вариант S3 bucket в YC.  
Есть несколько способов не светить чувстительные данные в репозитории: key.json , export variable. Для работы выбран способ с вынесением данных в отдельный файл terraform.tfvars вне репозитория. 
В репозитории есть файл terraform.tfvars-template куда можно подставить свои данные для работы. Команды terraform следует указывать с подключением файла:  
```bash
terraform plan -var-file ~/diplom/terraform.tfvars

```

```bash
vagrant@server1:~/diplom/devops-diplom/terraform-s3-create$ terraform workspace new stage
vagrant@server1:~/diplom/devops-diplom/terraform-s3-create$ terraform workspace list
  default
* stage
vagrant@server1:~/diplom/devops-diplom/terraform-s3-create$ terraform init
vagrant@server1:~/diplom/devops-diplom/terraform-s3-create$ terraform plan -var-file ~/diplom/terraform.tfvars

Terraform used the selected providers to generate the following execution plan. Resource actions are
indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # yandex_storage_bucket.s3-diplom will be created
  + resource "yandex_storage_bucket" "s3-diplom" {
...
vagrant@server1:~/diplom/devops-diplom/terraform-s3-create$ terraform apply --auto-approve -var-file ~/diplom/terraform.tfvars
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

```

3. Настройте [workspaces](https://www.terraform.io/docs/language/state/workspaces.html)
   а. Рекомендуемый вариант: создайте два workspace: *stage* и *prod*. В случае выбора этого варианта все последующие шаги должны учитывать факт существования нескольких workspace.  
   б. Альтернативный вариант: используйте один workspace, назвав его *stage*. Пожалуйста, не используйте workspace, создаваемый Terraform-ом по-умолчанию (*default*).

В одной из лекций отметили возможность создания workspace, но не рекомендовали к широкому применению, так как в таком коде проще запутаться, поэтому в работе выбран альтернативный вариант с одним workspace.  

```bash
export AWS_ACCESS_KEY_ID="ХХХХХХХХХХХХХХХХХХХ"
export AWS_SECRET_ACCESS_KEY="ХХХХХХХХХХХХХХХ"
vagrant@server1:~/diplom/devops-diplom/terraform$ terraform workspace new stage
Created and switched to workspace "stage"!
vagrant@server1:~/diplom/devops-diplom/terraform$ terraform workspace list
  default
* stage
vagrant@server1:~/diplom/devops-diplom/terraform$ terraform init -var-file ~/diplom/terraform.tfvars

Initializing the backend...
Terraform has been successfully initialized!
```

4. Создайте VPC с подсетями в разных зонах доступности.
5. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
6. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

```bash
vagrant@server1:~/diplom/devops-diplom/terraform$ terraform plan -var-file ~/diplom/terraform.tfvars

Terraform used the selected providers to generate the following execution plan. Resource actions are
indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # local_file.inventory will be created
  + resource "local_file" "inventory" {
      + content              = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "../ansible/inventory"
      + id                   = (known after apply)
    }

  # null_resource.connect will be created
  + resource "null_resource" "connect" {
      + id = (known after apply)
    }

  # null_resource.gate-setup will be created
  + resource "null_resource" "gate-setup" {
      + id = (known after apply)
    }

  # null_resource.gitlab-runner will be created
  + resource "null_resource" "gitlab-runner" {
      + id = (known after apply)
    }

  # null_resource.gitlab-setup will be created
  + resource "null_resource" "gitlab-setup" {
      + id = (known after apply)
    }

  # null_resource.monitoring-setup will be created
  + resource "null_resource" "monitoring-setup" {
      + id = (known after apply)
    }

  # null_resource.mysql-setup will be created
  + resource "null_resource" "mysql-setup" {
      + id = (known after apply)
    }

  # yandex_compute_instance.appvm will be created
  + resource "yandex_compute_instance" "appvm" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
............

```
Ну и так далее. Полный вывод работы терраформа и ансибла будет приложен отдельным файлом, ссылка в конце работы.   

Цель:

1. Повсеместно применять IaaC подход при организации (эксплуатации) инфраструктуры.
2. Иметь возможность быстро создавать (а также удалять) виртуальные машины и сети. С целью экономии денег на вашем аккаунте в YandexCloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

---
### Установка Nginx и LetsEncrypt

Необходимо разработать Ansible роль для установки Nginx и LetsEncrypt.

**Для получения LetsEncrypt сертификатов во время тестов своего кода пользуйтесь [тестовыми сертификатами](https://letsencrypt.org/docs/staging-environment/), так как количество запросов к боевым серверам LetsEncrypt [лимитировано](https://letsencrypt.org/docs/rate-limits/).**

Рекомендации:
  - Имя сервера: `you.domain`
  - Характеристики: 2vCPU, 2 RAM, External address (Public) и Internal address.

Цель:

1. Создать reverse proxy с поддержкой TLS для обеспечения безопасного доступа к веб-сервисам по HTTPS.

Ожидаемые результаты:

1. В вашей доменной зоне настроены все A-записи на внешний адрес этого сервера:
    - `https://www.you.domain` (WordPress)
    - `https://gitlab.you.domain` (Gitlab)
    - `https://grafana.you.domain` (Grafana)
    - `https://prometheus.you.domain` (Prometheus)
    - `https://alertmanager.you.domain` (Alert Manager)
2. Настроены все upstream для выше указанных URL, куда они сейчас ведут на этом шаге не важно, позже вы их отредактируете и укажите верные значения.
2. В браузере можно открыть любой из этих URL и увидеть ответ сервера (502 Bad Gateway). На текущем этапе выполнение задания это нормально!
```bash
root@gate:~# cat /etc/nginx/sites-enabled/
alertmanager.netology.tech.conf  grafana.netology.tech.conf       www.netology.tech.conf
app.netology.tech.conf           prometheus.netology.tech.conf    
gitlab.netology.tech.conf        runner.netology.tech.conf        
vagrant@gate:~$ cat /etc/nginx/sites-enabled/www.netology.tech.conf 
# переадресация с HTTP на HTTPS
#
server {
    if ($host = "www.netology.tech") {
        return 301 https://$host$request_uri;
    }
    
    listen 80;
    listen [::]:80;
    server_name "www.netology.tech";
}

server {
	listen 443 ssl;
	listen [::]:443 ssl;

	server_name "www.netology.tech";
          ssl_certificate /etc/letsencrypt/live/www.netology.tech/fullchain.pem;
          ssl_certificate_key /etc/letsencrypt/live/www.netology.tech/privkey.pem;


	location / {
		proxy_pass http://192.168.2.203:80/;
		proxy_buffering off;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header Host "www.netology.tech";


        	proxy_set_header X-Forwarded-For $remote_addr;
        	proxy_set_header X-Forwarded-Proto $scheme;
		# auth_basic           "monitoring Area";
    		# auth_basic_user_file /etc/nginx/.htpasswd; 

	}
}

```
Для интерфейсов мониторинга часть с авторизацией раскомментирована

___
### Установка кластера MySQL

Необходимо разработать Ansible роль для установки кластера MySQL.

Рекомендации:
  - Имена серверов: `db01.you.domain` и `db02.you.domain`
  - Характеристики: 4vCPU, 4 RAM, Internal address.

Цель:

1. Получить отказоустойчивый кластер баз данных MySQL.

Ожидаемые результаты:

1. MySQL работает в режиме репликации Master/Slave.
2. В кластере автоматически создаётся база данных c именем `wordpress`.
3. В кластере автоматически создаётся пользователь `wordpress` с полными правами на базу `wordpress` и паролем `wordpress`.

**Вы должны понимать, что в рамках обучения это допустимые значения, но в боевой среде использование подобных значений не приемлимо! Считается хорошей практикой использовать логины и пароли повышенного уровня сложности. В которых будут содержаться буквы верхнего и нижнего регистров, цифры, а также специальные символы!**

```bash
vagrant@db02:~$ mysql -ptest-password -uroot
mysql> show slave status \G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for source to send event
                  Master_Host: 192.168.2.201
                  Master_User: root
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000001
          Read_Master_Log_Pos: 1102
               Relay_Log_File: db02-relay-bin.000002
                Relay_Log_Pos: 326
        Relay_Master_Log_File: mysql-bin.000001
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB: 
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 1102
              Relay_Log_Space: 535
              Until_Condition: None
               Until_Log_File: 
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File: 
           Master_SSL_CA_Path: 
              Master_SSL_Cert: 
            Master_SSL_Cipher: 
               Master_SSL_Key: 
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error: 
               Last_SQL_Errno: 0
               Last_SQL_Error: 
  Replicate_Ignore_Server_Ids: 
             Master_Server_Id: 1
                  Master_UUID: f6b8a7df-08f5-11ed-90d8-d00dd0f307b2
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Replica has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind: 
      Last_IO_Error_Timestamp: 
     Last_SQL_Error_Timestamp: 
               Master_SSL_Crl: 
           Master_SSL_Crlpath: 
           Retrieved_Gtid_Set: 
            Executed_Gtid_Set: 
                Auto_Position: 0
         Replicate_Rewrite_DB: 
                 Channel_Name: 
           Master_TLS_Version: 
       Master_public_key_path: 
        Get_master_public_key: 0
            Network_Namespace: 
1 row in set, 1 warning (0.01 sec)

mysql> 

```


___
### Установка WordPress

Необходимо разработать Ansible роль для установки WordPress.

Рекомендации:
  - Имя сервера: `app.you.domain`
  - Характеристики: 4vCPU, 4 RAM, Internal address.

Цель:

1. Установить [WordPress](https://wordpress.org/download/). Это система управления содержимым сайта ([CMS](https://ru.wikipedia.org/wiki/Система_управления_содержимым)) с открытым исходным кодом.

nginx reverse proxy settings for wordpress
https://www.cloudbooklet.com/install-wordpress-with-nginx-reverse-proxy-to-apache-on-ubuntu-18-04-google-cloud/

По данным W3techs, WordPress используют 64,7% всех веб-сайтов, которые сделаны на CMS. Это 41,1% всех существующих в мире сайтов. Эту платформу для своих блогов используют The New York Times и Forbes. Такую популярность WordPress получил за удобство интерфейса и большие возможности.

Ожидаемые результаты:

1. Виртуальная машина на которой установлен WordPress и Nginx/Apache (на ваше усмотрение).
2. В вашей доменной зоне настроена A-запись на внешний адрес reverse proxy:
    - `https://www.you.domain` (WordPress)
3. На сервере `you.domain` отредактирован upstream для выше указанного URL и он смотрит на виртуальную машину на которой установлен WordPress.
4. В браузере можно открыть URL `https://www.you.domain` и увидеть главную страницу WordPress.


https://github.com/AndreyIvanov87/devops-netology/blob/main/devops-diplom-yandexcloud/wordpress.png





---
### Установка Gitlab CE и Gitlab Runner

Необходимо настроить CI/CD систему для автоматического развертывания приложения при изменении кода.

Рекомендации:
  - Имена серверов: `gitlab.you.domain` и `runner.you.domain`
  - Характеристики: 4vCPU, 4 RAM, Internal address.

Цель:
1. Построить pipeline доставки кода в среду эксплуатации, то есть настроить автоматический деплой на сервер `app.you.domain` при коммите в репозиторий с WordPress.

Подробнее об [Gitlab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/)

Ожидаемый результат:

1. Интерфейс Gitlab доступен по https.
2. В вашей доменной зоне настроена A-запись на внешний адрес reverse proxy:
    - `https://gitlab.you.domain` (Gitlab)
3. На сервере `you.domain` отредактирован upstream для выше указанного URL и он смотрит на виртуальную машину на которой установлен Gitlab.
3. При любом коммите в репозиторий с WordPress и создании тега (например, v1.0.0) происходит деплой на виртуальную машину.


Gitlab установлен, в интерфейсе видно что доступен раннер, а так же создан пустой публичный репозиторий root/wordpress  
Пароль есть в конце вывода работы ansible.
https://github.com/AndreyIvanov87/devops-netology/blob/main/devops-diplom-yandexcloud/gitlab-runner.png  

```bash 
vagrant@server1:~$ cd ~ && gunzip -d /tmp/wordpress.tar.gz && tar -xf /tmp/wordpress.tar && cp /tmp/wp-config.php ./wordpress && cd wordpress && git init && git add * && git commit -m 'initial' && git branch -M main 
gzip: /tmp/wordpress.tar already exists; do you wish to overwrite (y or n)? y
Initialized empty Git repository in /home/vagrant/wordpress/.git/
[master (root-commit) 1973873] initial
 Committer: vagrant <vagrant@server1.netology>
Your name and email address were configured automatically based
on your username and hostname. Please check that they are accurate.
You can suppress this message by setting them explicitly. Run the
following command and follow the instructions in your editor to edit
your configuration file:

    git config --global --edit

After doing this, you may fix the identity used for this commit with:

    git commit --amend --reset-author

 2890 files changed, 1285651 insertions(+)
 create mode 100644 index.php
 create mode 100644 license.txt
 create mode 100644 readme.html
 create mode 100644 wp-activate.php
 create mode 100644 wp-admin/about.php
 create mode 100644 wp-admin/admin-ajax.php
 create mode 100644 wp-admin/admin-footer.php
 create mode 100644 wp-admin/admin-functions.php
 create mode 100644 wp-admin/admin-header.php
 create mode 100644 wp-admin/admin-post.php
.....................


vagrant@server1:~/wordpress$ git -c http.sslVerify=false push https://root@gitlab.netology.tech/root/wordpress main && cat /home/vagrant/diplom/devops-diplom/ansible/stack/.gitlab-ci.yml
Username for 'https://gitlab.netology.tech': root
Password for 'https://root@gitlab.netology.tech': 
warning: redirecting to https://gitlab.netology.tech/root/wordpress.git/
Enumerating objects: 3101, done.
Counting objects: 100% (3101/3101), done.
Compressing objects: 100% (3034/3034), done.
Writing objects: 100% (3101/3101), 19.21 MiB | 9.02 MiB/s, done.
Total 3101 (delta 515), reused 0 (delta 0)
remote: Resolving deltas: 100% (515/515), done.
To https://gitlab.netology.tech/root/wordpress
 * [new branch]      main -> main
stages:          # List of stages for jobs, and their order of execution
  - deploy

deploy-job:      # This job runs in the deploy stage.
  only:
    - tags
  stage: deploy  
  script:
    - echo "Deploying application..."
    - git clone http://192.168.2.204/${CI_PROJECT_NAMESPACE}/${CI_PROJECT_NAME}.git
    - rsync --del -a -e "ssh -o StrictHostKeyChecking=no" wordpress vagrant@192.168.2.203:/var/www/
    - rm -rf wordpress
    - echo "Application successfully deployed."

```

Вывод скрипта вставляем в редактор .gitlab-ci.yml  
Вносим изменения в readme.html, коммитим, создаем тег v0.0.1  
https://github.com/AndreyIvanov87/devops-netology/blob/main/devops-diplom-yandexcloud/gitlab-runner.png  

Видим изменения на сервере с wordpress
```bash
vagrant@app:~$ head /var/www/wordpress/readme.html 
<!DOCTYPE html>
<html lang="en">

test change for chech depoy


<head>
	<meta name="viewport" content="width=device-width" />
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>WordPress &#8250; ReadMe</title>
vagrant@app:~$ 

```


___
### Установка Prometheus, Alert Manager, Node Exporter и Grafana

Необходимо разработать Ansible роль для установки Prometheus, Alert Manager и Grafana.

Рекомендации:
  - Имя сервера: `monitoring.you.domain`
  - Характеристики: 4vCPU, 4 RAM, Internal address.

Цель:

1. Получение метрик со всей инфраструктуры.

Ожидаемые результаты:

1. Интерфейсы Prometheus, Alert Manager и Grafana доступены по https.
2. В вашей доменной зоне настроены A-записи на внешний адрес reverse proxy:
  - `https://grafana.you.domain` (Grafana)
  - `https://prometheus.you.domain` (Prometheus)
  - `https://alertmanager.you.domain` (Alert Manager)
3. На сервере `you.domain` отредактированы upstreams для выше указанных URL и они смотрят на виртуальную машину на которой установлены Prometheus, Alert Manager и Grafana.
4. На всех серверах установлен Node Exporter и его метрики доступны Prometheus.
5. У Alert Manager есть необходимый [набор правил](https://awesome-prometheus-alerts.grep.to/rules.html) для создания алертов.
2. В Grafana есть дашборд отображающий метрики из Node Exporter по всем серверам.
3. В Grafana есть дашборд отображающий метрики из MySQL (*).
4. В Grafana есть дашборд отображающий метрики из WordPress (*).

*Примечание: дашборды со звёздочкой являются опциональными заданиями повышенной сложности их выполнение желательно, но не обязательно.*

Пароль на prometheus и alertmanager задается в ansible/roles/nginx/templates/.htpasswd (admin:admin)

https://github.com/AndreyIvanov87/devops-netology/blob/main/devops-diplom-yandexcloud/prometheus.png
https://github.com/AndreyIvanov87/devops-netology/blob/main/devops-diplom-yandexcloud/grafana.png
https://github.com/AndreyIvanov87/devops-netology/blob/main/devops-diplom-yandexcloud/alertmanager.png




---
## Что необходимо для сдачи задания?

1. Репозиторий со всеми Terraform манифестами и готовность продемонстрировать создание всех ресурсов с нуля.
2. Репозиторий со всеми Ansible ролями и готовность продемонстрировать установку всех сервисов с нуля.
Ansible запускается из Terraform, так что оно все в одном репозитории:  
https://github.com/AndreyIvanov87/devops-diplom  

Лог работы Terraform+Ansible: https://github.com/AndreyIvanov87/devops-netology/blob/main/devops-diplom-yandexcloud/terraform-ansible-log.txt  


3. Скриншоты веб-интерфейсов всех сервисов работающих по HTTPS на вашем доменном имени.
  - `https://www.you.domain` (WordPress)
  - `https://gitlab.you.domain` (Gitlab)
  - `https://grafana.you.domain` (Grafana)
  - `https://prometheus.you.domain` (Prometheus)
  - `https://alertmanager.you.domain` (Alert Manager)

https://github.com/AndreyIvanov87/devops-netology/blob/main/devops-diplom-yandexcloud/wordpress.png  
https://github.com/AndreyIvanov87/devops-netology/blob/main/devops-diplom-yandexcloud/gitlab-runner.png  
https://github.com/AndreyIvanov87/devops-netology/blob/main/devops-diplom-yandexcloud/prometheus.png  
https://github.com/AndreyIvanov87/devops-netology/blob/main/devops-diplom-yandexcloud/grafana.png  
https://github.com/AndreyIvanov87/devops-netology/blob/main/devops-diplom-yandexcloud/alertmanager.png  





4. Все репозитории рекомендуется хранить на одном из ресурсов ([github.com](https://github.com) или [gitlab.com](https://gitlab.com)).

---
## Как правильно задавать вопросы дипломному руководителю?

**Что поможет решить большинство частых проблем:**

1. Попробовать найти ответ сначала самостоятельно в интернете или в
  материалах курса и ДЗ и только после этого спрашивать у дипломного
  руководителя. Навык поиска ответов пригодится вам в профессиональной
  деятельности.
2. Если вопросов больше одного, то присылайте их в виде нумерованного
  списка. Так дипломному руководителю будет проще отвечать на каждый из
  них.
3. При необходимости прикрепите к вопросу скриншоты и стрелочкой
  покажите, где не получается.

**Что может стать источником проблем:**

1. Вопросы вида «Ничего не работает. Не запускается. Всё сломалось». Дипломный руководитель не сможет ответить на такой вопрос без дополнительных уточнений. Цените своё время и время других.
2. Откладывание выполнения курсового проекта на последний момент.
3. Ожидание моментального ответа на свой вопрос. Дипломные руководители работающие разработчики, которые занимаются, кроме преподавания, своими проектами. Их время ограничено, поэтому постарайтесь задавать правильные вопросы, чтобы получать быстрые ответы :)
