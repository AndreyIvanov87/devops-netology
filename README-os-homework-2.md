# Домашнее задание к занятию "3.4. Операционные системы, лекция 2"

1. На лекции мы познакомились с [node_exporter](https://github.com/prometheus/node_exporter/releases). В демонстрации его исполняемый файл запускался в background. Этого достаточно для демо, но не для настоящей production-системы, где процессы должны находиться под внешним управлением. Используя знания из лекции по systemd, создайте самостоятельно простой [unit-файл](https://www.freedesktop.org/software/systemd/man/systemd.service.html) для node_exporter:  
  
    * поместите его в автозагрузку,  
    * предусмотрите возможность добавления опций к запускаемому процессу через внешний файл (посмотрите, например, на `systemctl cat cron`),  
    * удостоверьтесь, что с помощью systemctl процесс корректно стартует, завершается, а после перезагрузки автоматически поднимается. 

________________________________	
	vagrant@vagrant:~$ wget https://github.com/prometheus/node_exporter/releases/download/v1.3.0/node_exporter-1.3.0.linux-amd64.tar.gz  
	node_exporter-1.3.0.linux-amd64.ta 100%[================================================================>]   8.61M  9.50MB/s    in 0.9s      
	vagrant@vagrant:~$ tar xvfz node_exporter-1.3.0.linux-amd64.tar.gz   
	node_exporter-1.3.0.linux-amd64/  
	node_exporter-1.3.0.linux-amd64/LICENSE  
	node_exporter-1.3.0.linux-amd64/NOTICE  
	node_exporter-1.3.0.linux-amd64/node_exporter  
	root@vagrant:~# cp /lib/systemd/system/cron.service /lib/systemd/system/node_exporter.service  
	root@vagrant:~# vim.tiny /lib/systemd/system/node_exporter.service  
	root@vagrant:~# cp /home/vagrant/node_exporter-1.3.0.linux-amd64/node_exporter /usr/sbin/  
	root@vagrant:~# touch /etc/default/node_exporter  
	root@vagrant:~# cat /etc/default/node_exporter  
	OPTIONS="--collector.textfile.directory /var/lib/node_exporter/textfile_collector"  
	root@vagrant:~# mkdir -p /var/lib/node_exporter/textfile_collector  
	root@vagrant:~# chown -R vagrant:vagrant /var/lib/node_exporter  
	root@vagrant:~# systemctl cat node_exporter  
	# /lib/systemd/system/node_exporter.service  
	[Unit]  
	Description=Node Exporter  
	  
	[Service]  
	User=vagrant  
	EnvironmentFile=/etc/default/node_exporter  
	ExecStart=/usr/sbin/node_exporter $OPTIONS  
	   
	[Install]  
	WantedBy=multi-user.target  
  
________________________________  
	root@vagrant:~# systemctl status node_exporter  
	● node_exporter.service - Node Exporter  
	     Loaded: loaded (/lib/systemd/system/node_exporter.service; disabled; vendor preset: enabled)  
	     Active: inactive (dead)  
	root@vagrant:~# systemctl start node_exporter  
	root@vagrant:~# systemctl status node_exporter  
	● node_exporter.service - Node Exporter  
	     Loaded: loaded (/lib/systemd/system/node_exporter.service; disabled; vendor preset: enabled)  
	     Active: active (running) since Tue 2021-11-23 12:37:37 UTC; 1s ago  
	   Main PID: 1210 (node_exporter)  
	      Tasks: 4 (limit: 2279)  
	     Memory: 2.3M  
	     CGroup: /system.slice/node_exporter.service  
	             └─1210 /usr/sbin/node_exporter --collector.textfile.directory /var/lib/node_exporter/textfile_collector  
	  
	Nov 23 12:37:37 vagrant node_exporter[1210]: ts=2021-11-23T12:37:37.661Z caller=node_exporter.go:115 level=info collector=thermal_zone  
	Nov 23 12:37:37 vagrant node_exporter[1210]: ts=2021-11-23T12:37:37.661Z caller=node_exporter.go:115 level=info collector=time  
	Nov 23 12:37:37 vagrant node_exporter[1210]: ts=2021-11-23T12:37:37.661Z caller=node_exporter.go:115 level=info collector=timex  
	Nov 23 12:37:37 vagrant node_exporter[1210]: ts=2021-11-23T12:37:37.661Z caller=node_exporter.go:115 level=info collector=udp_queues  
	Nov 23 12:37:37 vagrant node_exporter[1210]: ts=2021-11-23T12:37:37.661Z caller=node_exporter.go:115 level=info collector=uname  
	Nov 23 12:37:37 vagrant node_exporter[1210]: ts=2021-11-23T12:37:37.661Z caller=node_exporter.go:115 level=info collector=vmstat  
	Nov 23 12:37:37 vagrant node_exporter[1210]: ts=2021-11-23T12:37:37.661Z caller=node_exporter.go:115 level=info collector=xfs  
	Nov 23 12:37:37 vagrant node_exporter[1210]: ts=2021-11-23T12:37:37.661Z caller=node_exporter.go:115 level=info collector=zfs  
	Nov 23 12:37:37 vagrant node_exporter[1210]: ts=2021-11-23T12:37:37.661Z caller=node_exporter.go:199 level=info msg="Listening on" address=>  
	Nov 23 12:37:37 vagrant node_exporter[1210]: ts=2021-11-23T12:37:37.664Z caller=tls_config.go:195 level=info msg="TLS is disabled." http2=f>  
	root@vagrant:~# systemctl stop node_exporter  
	root@vagrant:~# systemctl status node_exporter  
	● node_exporter.service - Node Exporter  
	     Loaded: loaded (/lib/systemd/system/node_exporter.service; disabled; vendor preset: enabled)  
	     Active: inactive (dead)  
	root@vagrant:~# systemctl enable node_exporter  
	Created symlink /etc/systemd/system/multi-user.target.wants/node_exporter.service → /lib/systemd/system/node_exporter.service.  
	reboot  
	vagrant@vagrant:~$ systemctl status node_exporter  
	● node_exporter.service - Node Exporter  
	     Loaded: loaded (/lib/systemd/system/node_exporter.service; enabled; vendor preset: enabled)  
	     Active: active (running) since Tue 2021-11-23 08:04:59 UTC; 4h 36min ago  
	   Main PID: 620 (node_exporter)  
	      Tasks: 4 (limit: 2279)  
	     Memory: 14.0M  
	     CGroup: /system.slice/node_exporter.service  
	             └─620 /usr/sbin/node_exporter --collector.textfile.directory /var/lib/node_exporter/textfile_collector  
	  
	 

2. Ознакомьтесь с опциями node_exporter и выводом `/metrics` по-умолчанию. Приведите несколько опций, которые вы бы выбрали для базового мониторинга хоста по CPU, памяти, диску и сети.  
	vagrant@vagrant:~$ curl http://localhost:9100/metrics  | grep node_load  
	  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current  
	                                 Dload  Upload   Total   Spent    Left  Speed  
	  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0# HELP node_load1 1m load average.  
	# TYPE node_load1 gauge  
	node_load1 0  
	# HELP node_load15 15m load average.  
	# TYPE node_load15 gauge  
	node_load15 0  
	# HELP node_load5 5m load average.  
	# TYPE node_load5 gauge  
	node_load5 0  
	100 60647    0 60647    0     0  11.5M      0 --:--:-- --:--:-- --:--:-- 11.5M  
Работает.   
Опции для мониторинга хоста по CPU, памяти, диску и сети:  
CPU  
node_load1 0  
node_load5 0  
node_load15 0  
  
RAM  
node_memory_MemAvailable_bytes 1.812107264e+09  
node_memory_MemFree_bytes 1.501995008e+09  
node_memory_MemTotal_bytes 2.08408576e+09  
node_memory_SwapFree_bytes 1.027600384e+09  
node_memory_SwapTotal_bytes 1.027600384e+09  
  
network  
node_network_receive_bytes_total{device="eth0"} 102568  
node_network_transmit_bytes_total{device="eth0"} 143118  
  
disk  
node_disk_io_time_seconds_total{device="sda"} 9.396  
node_disk_read_time_seconds_total{device="sda"} 7.464  
node_disk_reads_completed_total{device="sda"} 15720  
node_disk_write_time_seconds_total{device="sda"} 0.749  
node_disk_writes_completed_total{device="sda"} 775  

  


3. Установите в свою виртуальную машину [Netdata](https://github.com/netdata/netdata). Воспользуйтесь [готовыми пакетами](https://packagecloud.io/netdata/netdata/install) для установки (`sudo apt install -y netdata`). После успешной установки:  
    * в конфигурационном файле `/etc/netdata/netdata.conf` в секции [web] замените значение с localhost на `bind to = 0.0.0.0`,  
    * добавьте в Vagrantfile проброс порта Netdata на свой локальный компьютер и сделайте `vagrant reload`:  
  
	    ```bash  
	    config.vm.network "forwarded_port", guest: 19999, host: 19999  
	    ```  

    После успешной перезагрузки в браузере *на своем ПК* (не в виртуальной машине) вы должны суметь зайти на `localhost:19999`. Ознакомьтесь с метриками, которые по умолчанию собираются Netdata и с комментариями, которые даны к этим метрикам.  
  
	sudo apt install -y netdata  
	sudo vim.tiny /etc/netdata/netdata.conf   
	
	root@vagrant:~# service netdata status  
	● netdata.service - netdata - Real-time performance monitoring  
	     Loaded: loaded (/lib/systemd/system/netdata.service; enabled; vendor preset: enabled)  
	     Active: active (running) since Wed 2021-11-24 09:03:22 UTC; 3min 26s ago  
	root@vagrant:~# apt install net-tools  
	root@vagrant:~# netstat -an | grep 19999  
	tcp        0      0 0.0.0.0:19999           0.0.0.0:*               LISTEN       
	exit  
	ivanov@lusankiya:~/vagrant$ cat Vagrantfile   
	Vagrant.configure("2") do |config|  
	 	config.vm.box = "bento/ubuntu-20.04"  
		config.vm.network "forwarded_port", guest: 19999, host: 19999  
		config.vm.provider "virtualbox" do |v|   
		        v.memory = 2048  
		        v.cpus = 2  
		end  
	 end  
	  
	ivanov@lusankiya:~/vagrant$ vagrant reload  
	  
`localhost:19999` список метрик:  
 System Overview  
    cpu  
    load  
    disk  
    ram  
    swap  
    network  
    processes  
    idlejitter  
    interrupts  
    softirqs  
    softnet  
    entropy  
    uptime  
    ipc semaphores  
    ipc shared memory  
далее подробнее по:   
CPUs  
Memory  
Disks  
Networking Stack  
IPv4 Networking  
IPv6 Networking  
Network Interfaces  
Power Supply  
systemd Services  
Applications  
User Groups  
Users  
Netdata Monitoring  
add more charts  
  
    add more alarms  
    Every second, Netdata collects 1 255 metrics on vagrant, presents them in 227 charts and monitors them with 102 alarms.  
       
    netdata    v1.19.0  
  

4. Можно ли по выводу `dmesg` понять, осознает ли ОС, что загружена не на настоящем оборудовании, а на системе виртуализации?  
 Да (в описании оборудования указано что диск, видео - виртуальные, а так же прямо сказано что применятеся виртуализация KVM):  
	vagrant@vagrant:~$ dmesg | grep VBOX  
	[    0.054404] ACPI: RSDP 0x00000000000E0000 000024 (v02 VBOX  )  
	[    0.054406] ACPI: XSDT 0x000000007FFF0030 00003C (v01 VBOX   VBOXXSDT 00000001 ASL  00000061)  
	[    0.054410] ACPI: FACP 0x000000007FFF00F0 0000F4 (v04 VBOX   VBOXFACP 00000001 ASL  00000061)  
	[    0.054413] ACPI: DSDT 0x000000007FFF0470 002325 (v02 VBOX   VBOXBIOS 00000002 INTL 20190509)  
	[    0.054418] ACPI: APIC 0x000000007FFF0240 00005C (v02 VBOX   VBOXAPIC 00000001 ASL  00000061)  
	[    0.054420] ACPI: SSDT 0x000000007FFF02A0 0001CC (v01 VBOX   VBOXCPUT 00000002 INTL 20190509)  
	[    1.030457] ata3.00: ATA-6: VBOX HARDDISK, 1.0, max UDMA/133  
	[    1.030604] scsi 2:0:0:0: Direct-Access     ATA      VBOX HARDDISK    1.0  PQ: 0 ANSI: 5  
	vagrant@vagrant:~$ dmesg | grep virtual  
	[    0.001167] CPU MTRRs all blank - virtualized system.  
	[    0.058659] Booting paravirtualized kernel on KVM  
	[    2.324589] systemd[1]: Detected virtualization oracle.  
	vagrant@vagrant:~$ dmesg | grep box  
	[    0.726719] vboxvideo: loading out-of-tree module taints kernel.  
	[    0.726735] vboxvideo: module verification failed: signature and/or required key missing - tainting kernel  

5. Как настроен sysctl `fs.nr_open` на системе по-умолчанию? Узнайте, что означает этот параметр. Какой другой существующий лимит не позволит достичь такого числа (`ulimit --help`)?  
	root@vagrant:~# sysctl fs.nr_open  
	fs.nr_open = 1048576	
This denotes the maximum number of file-handles a process can allocate. Default value is 1024*1024 (1048576) which should be enough for most machines. То есть максимальное количество файлов которое может открыть один процесс.  
 Другой существующий лимит относится к командной оболочки.    
ulimit используется для ресурсов, занятых процессом запуска оболочки, и может использоваться для установки системных ограничений.  
	vagrant@vagrant:~$ ulimit -n  
	1024  


6. Запустите любой долгоживущий процесс (не `ls`, который отработает мгновенно, а, например, `sleep 1h`) в отдельном неймспейсе процессов; покажите, что ваш процесс работает под PID 1 через `nsenter`. Для простоты работайте в данном задании под root (`sudo -i`). Под обычным пользователем требуются дополнительные опции (`--map-root-user`) и т.д.  
	screen  
	root@vagrant:~# unshare -f --pid --mount-proc sleep 100  
	root       90300  0.0  0.0   8080   596 pts/2    S+   12:10   0:00 unshare -f --pid --mount-proc sleep 100  
	root       90301  0.0  0.0   8076   592 pts/2    S+   12:10   0:00 sleep 100  
	root       90302  0.0  0.1  11492  3428 pts/0    R+   12:10   0:00 ps aux  
	root@vagrant:~# nsenter --target 90301 --pid --mount  
	root@vagrant:/# ps aux  
	USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND  
	root           1  0.0  0.0   8076   592 pts/2    S+   12:10   0:00 sleep 100  
	root           2  0.0  0.1   9836  3988 pts/0    S    12:10   0:00 -bash  
	root          11  0.0  0.1  11492  3308 pts/0    R+   12:10   0:00 ps aux  
  
  
7. Найдите информацию о том, что такое `:(){ :|:& };:`. Запустите эту команду в своей виртуальной машине Vagrant с Ubuntu 20.04 (**это важно, поведение в других ОС не проверялось**). Некоторое время все будет "плохо", после чего (минуты) – ОС должна стабилизироваться. Вызов `dmesg` расскажет, какой механизм помог автоматической стабилизации. Как настроен этот механизм по-умолчанию, и как изменить число процессов, которое можно создать в сессии?  
Логическая бомба (известная также как fork bomb), забивающая память системы, что в итоге приводит к её зависанию.  
Вывод в dmesg при запуске:  
	[418512.224260] cgroup: fork rejected by pids controller in /user.slice/user-1000.slice/session-46.scope  

 cgroups - Linux control groups  
  Control  groups,  usually  referred  to as cgroups, are a Linux kernel feature which allow  
       processes to be organized into  hierarchical  groups  whose  usage  of  various  types  of  
       resources  can  then  be limited and monitored.  The kernel's cgroup interface is provided  
       through a pseudo-filesystem called cgroupfs.   
	  
То есть это возможность ядра группировать процессы и задавать им лимиты на различные ресурсы. Управляется через псевдо-файловую систему. Текущая настройка:  
	vagrant@vagrant:/sys/fs/cgroup/pids$ cat /sys/fs/cgroup/pids/user.slice/user-1000.slice/pids.max  
	5014  
При поднятии этого лимита до 50 000 и запуске бомбы еще раз вывод top:
	Tasks: 7690 total,   1 running, 7689 sleeping,   0 stopped,   0 zombie
Выше не поднимается, видимо потому, что  
	vagrant@vagrant:/sys/fs/cgroup/pids$ ulimit -u  
	7597  

