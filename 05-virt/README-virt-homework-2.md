
# Домашнее задание к занятию "5.2. Применение принципов IaaC в работе с виртуальными машинами"

## Как сдавать задания

Обязательными к выполнению являются задачи без указания звездочки. Их выполнение необходимо для получения зачета и диплома о профессиональной переподготовке.

Задачи со звездочкой (*) являются дополнительными задачами и/или задачами повышенной сложности. Они не являются обязательными к выполнению, но помогут вам глубже понять тему.

Домашнее задание выполните в файле readme.md в github репозитории. В личном кабинете отправьте на проверку ссылку на .md-файл в вашем репозитории.

Любые вопросы по решению задач задавайте в чате учебной группы.

---

## Задача 1

- Опишите своими словами основные преимущества применения на практике IaaC паттернов.  
	Инфраструктура как код позволяет автоматизировать процесс настройки тестовых и продакшн сред, что дает такие преимущетва как: ускорение настройки серверов , сокращение трудозатрат и времени на развертывание инфраструктуры, легкость масштабирования. И второе - дает понятный, документированный и главное единообразный алгоритм для поднятия нужных окружений - все настраивается одинаково. Так же дает возможность одновременного изменения конфигураций на множестве хостов уже находящийся в работе, облегчает миграцию при необходимости, дает возможность быстрее восстановить инфраструктуру в случае сбоев.  

- Какой из принципов IaaC является основополагающим?  
	Отсюда основой принцип  идемпоте́нтность - при выполнении операции получается такой же результат как при прошлых выполнениях и последующих. То есть IaaC дает понятный, предсказуемый и легко повторяемый результат.  

## Задача 2

- Чем Ansible выгодно отличается от других систем управление конфигурациями?  
	Ansible работает поверх существующего ssh доступа и не требует установки дополнительного агента на целевой системе. Не сложен в освоении и имеет большой набор готовых модулей для типовых задач.  
- Какой, на ваш взгляд, метод работы систем конфигурации более надёжный push или pull?
	На мой взгляд надежнее push, потомучто во-первых целевой системе не надо давать доступ к серверу с системой управления конфигурациями, а во-вторых после push всегда есть обратная связь сразу, понятно успешно все прошло или нет. 

## Задача 3

Установить на личный компьютер:

- VirtualBox
- Vagrant
- Ansible

*Приложить вывод команд установленных версий каждой из программ, оформленный в markdown.*

```bash
ivanov@lusankiya:~$ virtualbox -help
Oracle VM VirtualBox VM Selector v6.1.26_Ubuntu
(C) 2005-2021 Oracle Corporation
All rights reserved.

No special options.

If you are looking for --startvm and related options, you need to use VirtualBoxVM.
ivanov@lusankiya:~$ vagrant --version
Vagrant 2.2.19
ivanov@lusankiya:~$ ansible --version
ansible 2.9.6
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/ivanov/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 3.8.10 (default, Nov 26 2021, 20:14:08) [GCC 9.3.0]
ivanov@lusankiya:~$ 
```



## Задача 4 (*)

Воспроизвести практическую часть лекции самостоятельно.

- Создать виртуальную машину.
- Зайти внутрь ВМ, убедиться, что Docker установлен с помощью команды
```bash
ivanov@lusankiya:~/vagrant$ vagrant up
Bringing machine 'server1.netology' up with 'virtualbox' provider...
==> server1.netology: Importing base box 'bento/ubuntu-20.04'...
==> server1.netology: Matching MAC address for NAT networking...
==> server1.netology: Checking if box 'bento/ubuntu-20.04' version '202107.28.0' is up to date...
................
==> server1.netology: Configuring and enabling network interfaces...
==> server1.netology: Mounting shared folders...
    server1.netology: /vagrant => /home/ivanov/vagrant
==> server1.netology: Running provisioner: ansible...
    server1.netology: Running ansible-playbook...

PLAY [nodes] *******************************************************************

TASK [Gathering Facts] *********************************************************
ok: [server1.netology]

TASK [Create directory for ssh-keys] *******************************************
changed: [server1.netology]

TASK [Adding rsa-key in /root/.ssh/authorized_keys] ****************************
changed: [server1.netology]

TASK [Checking DNS] ************************************************************
changed: [server1.netology]

TASK [Installing tools] ********************************************************
[DEPRECATION WARNING]: Invoking "apt" only once while using a loop via 
squash_actions is deprecated. Instead of using a loop to supply multiple items 
and specifying `package: "{{ item }}"`, please use `package: ['git', 'curl']` 
and remove the loop. This feature will be removed in version 2.11. Deprecation 
warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.
ok: [server1.netology] => (item=['git', 'curl'])

TASK [Installing docker] *******************************************************
changed: [server1.netology]
[WARNING]: Consider using the get_url or uri module rather than running 'curl'.
If you need to use command because get_url or uri is insufficient you can add
'warn: false' to this command task or set 'command_warnings=False' in
ansible.cfg to get rid of this message.

TASK [Add the current user to docker group] ************************************
changed: [server1.netology]

PLAY RECAP *********************************************************************
server1.netology           : ok=7    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   


ivanov@lusankiya:~/vagrant$ vagrant ssh
Welcome to Ubuntu 20.04.2 LTS (GNU/Linux 5.4.0-80-generic x86_64)
...................
vagrant@server1:~$ uname -a
Linux server1 5.4.0-80-generic #90-Ubuntu SMP Fri Jul 9 22:49:44 UTC 2021 x86_64 x86_64 x86_64 GNU/Linux
vagrant@server1:~$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
vagrant@server1:~$ logout
Connection to 127.0.0.1 closed.
ivanov@lusankiya:~/vagrant$ vagrant destroy -f
==> server1.netology: Forcing shutdown of VM...
==> server1.netology: Destroying VM and associated drives...
ivanov@lusankiya:~/vagrant$ 


```
















