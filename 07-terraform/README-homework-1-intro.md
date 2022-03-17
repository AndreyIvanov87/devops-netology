# Домашнее задание к занятию "7.1. Инфраструктура как код"

## Задача 1. Выбор инструментов. 
 
### Легенда
 
Через час совещание на котором менеджер расскажет о новом проекте. Начать работу над которым надо 
будет уже сегодня. 
На данный момент известно, что это будет сервис, который ваша компания будет предоставлять внешним заказчикам.
Первое время, скорее всего, будет один внешний клиент, со временем внешних клиентов станет больше.

Так же по разговорам в компании есть вероятность, что техническое задание еще не четкое, что приведет к большому
количеству небольших релизов, тестирований интеграций, откатов, доработок, то есть скучно не будет.  
   
Вам, как девопс инженеру, будет необходимо принять решение об инструментах для организации инфраструктуры.
На данный момент в вашей компании уже используются следующие инструменты: 
- остатки Сloud Formation, 
- некоторые образы сделаны при помощи Packer,
- год назад начали активно использовать Terraform, 
- разработчики привыкли использовать Docker, 
- уже есть большая база Kubernetes конфигураций, 
- для автоматизации процессов используется Teamcity, 
- также есть совсем немного Ansible скриптов, 
- и ряд bash скриптов для упрощения рутинных задач.  

Для этого в рамках совещания надо будет выяснить подробности о проекте, что бы в итоге определиться с инструментами:

- надо уточнит стэк технологий, которые планируется использовать в разработке. На каких ОС, ПО, языках программирования планируется реализация.  

1. Какой тип инфраструктуры будем использовать для этого проекта: изменяемый или не изменяемый?  
	Изменяемый, так как предполагается много откатов, доработок итд, да и тз до конца не ясно.  
1. Будет ли центральный сервер для управления инфраструктурой?  
	Лучше не надо. Если со временем внешних клиентов станет больше, то должа быть возможность разделить работу с ними. Имеющиеся инструменты не требуют наличия центрального сервера (о них ниже).  
1. Будут ли агенты на серверах?  
	Нет. Единственная система управления конфигурациями, которая уже используется - Ansible, она рабоает без агента. Как и Терраформ. Для большинства общих задач для развертывания инфраструктуры этого должно хватить, тем более что в компании уже есть наработки с ними. Так же ряд bash скриптов для упрощения рутинных задач имеет смысл интегрировать в работу Ansible, или хотябы использовать ту же топологию с разграничением доступа к серверам. (Ansible работает поверх ssh, и в bash скриптах можно использовать этот же доступ).  
1. Будут ли использованы средства для управления конфигурацией или инициализации ресурсов? 
	Если использовать виртуальные машины (в тех же облаках), то имеющиеся наработки по Terraform,и образам Packer, будут очень кстати. Ну и Ansible можно активнее внедрять и так и при работе на чистом железе. Особенно полезны они будут в случае горизонтального масштабирования, возможность которого заложить надо обязательно.  
 

В связи с тем, что проект стартует уже сегодня, в рамках совещания надо будет определиться со всеми этими вопросами.

### В результате задачи необходимо

1. Ответить на четыре вопроса представленных в разделе "Легенда". 
1. Какие инструменты из уже используемых вы хотели бы использовать для нового проекта? 
1. Хотите ли рассмотреть возможность внедрения новых инструментов для этого проекта? 

Если для ответа на эти вопросы недостаточно информации, то напишите какие моменты уточните на совещании.


## Задача 2. Установка терраформ. 

Официальный сайт: https://www.terraform.io/

Установите терраформ при помощи менеджера пакетов используемого в вашей операционной системе.
В виде результата этой задачи приложите вывод команды `terraform --version`.

```bash
root@server2:~# curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
OK
root@server2:~# sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
Hit:1 http://archive.ubuntu.com/ubuntu focal InRelease
Hit:2 https://download.docker.com/linux/ubuntu focal InRelease                                      
Hit:3 http://security.ubuntu.com/ubuntu focal-security InRelease                                    
Get:4 https://apt.releases.hashicorp.com focal InRelease [14.6 kB]                       
Get:5 https://apt.releases.hashicorp.com focal/main amd64 Packages [50.5 kB]       
Hit:6 http://archive.ubuntu.com/ubuntu focal-updates InRelease
Hit:7 http://archive.ubuntu.com/ubuntu focal-backports InRelease
Fetched 65.1 kB in 2s (26.8 kB/s)                        
Reading package lists... Done
root@server2:~# sudo apt-get update && sudo apt-get install terraform
Hit:1 http://archive.ubuntu.com/ubuntu focal InRelease
Hit:2 http://archive.ubuntu.com/ubuntu focal-updates InRelease
Hit:3 http://archive.ubuntu.com/ubuntu focal-backports InRelease            
Hit:4 http://security.ubuntu.com/ubuntu focal-security InRelease            
Hit:5 https://download.docker.com/linux/ubuntu focal InRelease            
Hit:6 https://apt.releases.hashicorp.com focal InRelease
Reading package lists... Done
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following NEW packages will be installed:
  terraform
0 upgraded, 1 newly installed, 0 to remove and 139 not upgraded.
Need to get 18.8 MB of archives.
After this operation, 63.3 MB of additional disk space will be used.
Get:1 https://apt.releases.hashicorp.com focal/main amd64 terraform amd64 1.1.7 [18.8 MB]
Fetched 18.8 MB in 1min 39s (190 kB/s)                                                              
Selecting previously unselected package terraform.
(Reading database ... 41797 files and directories currently installed.)
Preparing to unpack .../terraform_1.1.7_amd64.deb ...
Unpacking terraform (1.1.7) ...
Setting up terraform (1.1.7) ...
root@server2:~# terraform --version
Terraform v1.1.7
on linux_amd64
```


## Задача 3. Поддержка легаси кода. 

В какой-то момент вы обновили терраформ до новой версии, например с 0.12 до 0.13. 
А код одного из проектов настолько устарел, что не может работать с версией 0.13. 
В связи с этим необходимо сделать так, чтобы вы могли одновременно использовать последнюю версию терраформа установленную при помощи
штатного менеджера пакетов и устаревшую версию 0.12. 

В виде результата этой задачи приложите вывод `--version` двух версий терраформа доступных на вашем компьютере 
или виртуальной машине.

```bash
root@server2:~# wget https://releases.hashicorp.com/terraform/1.0.11/terraform_1.0.11_linux_amd64.zip
--2022-03-17 12:32:55--  https://releases.hashicorp.com/terraform/1.0.11/terraform_1.0.11_linux_amd64.zip
Resolving releases.hashicorp.com (releases.hashicorp.com)... 151.101.37.183, 2a04:4e42:9::439
Connecting to releases.hashicorp.com (releases.hashicorp.com)|151.101.37.183|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 18082446 (17M) [application/zip]
Saving to: ‘terraform_1.0.11_linux_amd64.zip’

terraform_1.0.11_linux_am 100%[==================================>]  17.24M   149KB/s    in 2m 6s   

2022-03-17 12:35:02 (140 KB/s) - ‘terraform_1.0.11_linux_amd64.zip’ saved [18082446/18082446]

root@server2:~# apt-get install unzip
Reading package lists... Done
Building dependency tree       
Reading state information... Done
Suggested packages:
  zip
The following NEW packages will be installed:
  unzip
0 upgraded, 1 newly installed, 0 to remove and 139 not upgraded.
Need to get 169 kB of archives.
After this operation, 593 kB of additional disk space will be used.
Get:1 http://archive.ubuntu.com/ubuntu focal/main amd64 unzip amd64 6.0-25ubuntu1 [169 kB]
Fetched 169 kB in 1s (133 kB/s)                      
Selecting previously unselected package unzip.
(Reading database ... 41800 files and directories currently installed.)
Preparing to unpack .../unzip_6.0-25ubuntu1_amd64.deb ...
Unpacking unzip (6.0-25ubuntu1) ...
Setting up unzip (6.0-25ubuntu1) ...
Processing triggers for mime-support (3.64ubuntu1) ...
Processing triggers for man-db (2.9.1-1) ...
root@server2:~# unzip terraform_1.0.11_linux_amd64.zip 
Archive:  terraform_1.0.11_linux_amd64.zip
  inflating: terraform       
root@server2:~# /usr/bin/terraform --version
Terraform v1.1.7
on linux_amd64
root@server2:~# /root/terraform --version
Terraform v1.0.11
on linux_amd64

Your version of Terraform is out of date! The latest version
is 1.1.7. You can update by downloading from https://www.terraform.io/downloads.html
```


---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
