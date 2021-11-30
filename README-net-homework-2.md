Домашнее задание к занятию "3.7. Компьютерные сети, лекция 2"  
  
1.    Проверьте список доступных сетевых интерфейсов на вашем компьютере. Какие команды есть для этого в Linux и в Windows?  
  windows: ipconfig /all  
  linux: ifconfig , ip  
___
	ivanov@lusankiya:~/vagrant$ ip -c -br link 
	lo               UNKNOWN        00:00:00:00:00:00 <LOOPBACK,UP,LOWER_UP> 
	enp7s0           UP             08:97:98:82:52:93 <BROADCAST,MULTICAST,UP,LOWER_UP> 
	wlp8s0           UP             4c:1d:96:c3:1c:7a <BROADCAST,MULTICAST,UP,LOWER_UP> 
	ivanov@lusankiya:~/vagrant$ ifconfig
	enp7s0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
	        inet 192.168.1.13  netmask 255.255.255.0  broadcast 192.168.1.255
	        inet6 fe80::6d2b:f604:5557:f76b  prefixlen 64  scopeid 0x20<link>
	        ether 08:97:98:82:52:93  txqueuelen 1000  (Ethernet)
	        RX packets 16596341  bytes 19853549413 (19.8 GB)
	        RX errors 0  dropped 204  overruns 0  frame 0
	        TX packets 9584718  bytes 1248849582 (1.2 GB)
	        TX errors 32  dropped 0 overruns 0  carrier 21  collisions 3
	
	lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
	        inet 127.0.0.1  netmask 255.0.0.0
	        inet6 ::1  prefixlen 128  scopeid 0x10<host>
	        loop  txqueuelen 1000  (Локальная петля (Loopback))
	        RX packets 1151101  bytes 99655179 (99.6 MB)
	        RX errors 0  dropped 0  overruns 0  frame 0
	        TX packets 1151101  bytes 99655179 (99.6 MB)
	        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
	
	wlp8s0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
	        inet 192.168.1.3  netmask 255.255.255.0  broadcast 192.168.1.255
	        inet6 fe80::5a6e:be35:20b7:d24a  prefixlen 64  scopeid 0x20<link>
	        ether 4c:1d:96:c3:1c:7a  txqueuelen 1000  (Ethernet)
	        RX packets 9763346  bytes 13285486853 (13.2 GB)
	        RX errors 0  dropped 0  overruns 0  frame 0
	        TX packets 1586036  bytes 154201943 (154.2 MB)
	        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
  

2.    Какой протокол используется для распознавания соседа по сетевому интерфейсу? Какой пакет и команды есть в Linux для этого?  
___  
	LLDP – протокол для обмена информацией между соседними устройствами, позволяет определить к какому порту коммутатора подключен сервер.  
	ivanov@lusankiya:~/vagrant$ sudo apt install lldpd  
	ivanov@lusankiya:~/vagrant$ lldpctl
	-------------------------------------------------------------------------------
	LLDP neighbors:
	-------------------------------------------------------------------------------
	
	
3.    Какая технология используется для разделения L2 коммутатора на несколько виртуальных сетей? Какой пакет и команды есть в Linux для этого? Приведите пример конфига.  
VLAN – виртуальное разделение коммутатора.
___  
	В линукс используется пакет vlan
	ivanov@lusankiya:~/vagrant$ sudo apt install vlan
  	Для сохранения настроек после перезагрузки создается файл
	/etc/network/interfaces
	Например
	auto vlan1400
	iface vlan1400 inet static
	        address 192.168.2.1
	        netmask 255.255.255.0
	        vlan_raw_device enp7s0
	Создает vlan с номером 1400 на интерфейсе enp7s0  
	Или через утилиту:  
	ivanov@lusankiya:~/vagrant$ sudo vconfig add enp7s0 1400
	ivanov@lusankiya:~/vagrant$ ip -c -br link
	lo               UNKNOWN        00:00:00:00:00:00 <LOOPBACK,UP,LOWER_UP> 
	enp7s0           UP             08:97:98:82:52:93 <BROADCAST,MULTICAST,UP,LOWER_UP> 
	wlp8s0           UP             4c:1d:96:c3:1c:7a <BROADCAST,MULTICAST,UP,LOWER_UP> 
	vlan1400@enp7s0  DOWN           08:97:98:82:52:93 <BROADCAST,MULTICAST> 
	ivanov@lusankiya:~/vagrant$ sudo ip link set vlan1400 up
	ivanov@lusankiya:~/vagrant$ sudo ip addr add 192.168.2.1/255.255.255.0 dev vlan1400
	ivanov@lusankiya:~/vagrant$ ip address 
	.....
	4: vlan1400@enp7s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
	link/ether 08:97:98:82:52:93 brd ff:ff:ff:ff:ff:ff
	inet 192.168.2.1/24 scope global vlan1400
	   valid_lft forever preferred_lft forever
	inet6 fe80::a97:98ff:fe82:5293/64 scope link 
	   valid_lft forever preferred_lft forever
	удалить: 
	ivanov@lusankiya:~/vagrant$ sudo vconfig rem vlan1400

	

4.    Какие типы агрегации интерфейсов есть в Linux? Какие опции есть для балансировки нагрузки? Приведите пример конфига.  
___  
Объеденение двух сетевых интерфейсов в один в терминологии Windows называется teaming, а в терминологии Linux — bonding. Этот режим может использоваться для повышения отказоустойчивости и/или пропускной способности сетевого подключения.  
  
Linux поддерживает несколько режимов агрегации интерфейсов:  
  
    0 (balance-rr) — round-robin распределение пакетов между интерфейсами. Обеспечивает отказоустойчивость и повышение пропускной способности.  
    1 (active-backup) — в каждый момент времени работает только один интерфейс, в случае его выхода из строя, mac-адрес назначается второму интерфейсу и трафик переключается на него.  
    2 (balance-xor) — обеспечивает балансировку между интерфейсами на основании MAC-адресов отправителя и получателя.  
    3 (broadcast) — отправляет пакеты через все интерфейсы одновременно, обеспечивает отказоустойчивость.  
    4 (802.3ad) — обеспечивает агрегацию на основании протокола 802.3ad.  
    5 (balance-tlb) — в этом режиме входящий трафик приходит только на один «активный» интерфейс, исходящий же распределяется по всем интерфейсам.  
    6 (balance-alb) — балансирует исходящий трафик как tlb, а так же входящий IPv4 трафик используя ARP.  
  
Настроим агрегацию сетевых интерфейсов eth0 и eth1 в один bond0, используя round-robin алгоритм балансировки пропускной способности.  
___  
	root@vagrant:~# apt-get install ifenslave
	root@vagrant:~# cat /etc/network/interfaces
	auto lo
	iface lo inet loopback
	
	auto eth0
	iface eth0 inet manual
	bond-master bond0

	auto eth1
	iface eth1 inet manual
	bond-master bond0

	auto bond0
	iface bond0 inet dhcp
	bond-mode 0
	bond-slaves eth0 eth1
	
	root@vagrant:~# cat /etc/modprobe.d/bonding.conf
	alias bond0 bonding
	options bonding mode=0 miimon=100 downdelay=200 updelay=200
	root@vagrant:~# echo "bonding" >> /etc/modules
	root@vagrant:~# modprobe bonding
        root@vagrant:~# reboot
        root@vagrant:~# ifconfig
	bond0: flags=5187<UP,BROADCAST,RUNNING,MASTER,MULTICAST>  mtu 1500
        	inet 10.0.3.15  netmask 255.255.255.0  broadcast 10.0.3.255
        	inet6 fe80::a00:27ff:fec0:986d  prefixlen 64  scopeid 0x20<link>
        	ether 08:00:27:c0:98:6d  txqueuelen 1000  (Ethernet)
        	RX packets 43  bytes 12541 (12.5 KB)
        	RX errors 0  dropped 0  overruns 0  frame 0
        	TX packets 91  bytes 10495 (10.4 KB)
        	TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
	
	eth0: flags=6211<UP,BROADCAST,RUNNING,SLAVE,MULTICAST>  mtu 1500
	        ether 08:00:27:c0:98:6d  txqueuelen 1000  (Ethernet)
	        RX packets 0  bytes 0 (0.0 B)
	        RX errors 0  dropped 0  overruns 0  frame 0
	        TX packets 18  bytes 2232 (2.2 KB)
	        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
		
	eth1: flags=6211<UP,BROADCAST,RUNNING,SLAVE,MULTICAST>  mtu 1500
	        ether 08:00:27:c0:98:6d  txqueuelen 1000  (Ethernet)
	        RX packets 43  bytes 12541 (12.5 KB)
	        RX errors 0  dropped 0  overruns 0  frame 0
	        TX packets 73  bytes 8263 (8.2 KB)
	        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
	
	lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
	        inet 127.0.0.1  netmask 255.0.0.0
	        inet6 ::1  prefixlen 128  scopeid 0x10<host>
	        loop  txqueuelen 1000  (Local Loopback)
	        RX packets 108  bytes 8028 (8.0 KB)
	        RX errors 0  dropped 0  overruns 0  frame 0
	        TX packets 108  bytes 8028 (8.0 KB)
	        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0


5.    Сколько IP адресов в сети с маской /29 ? Сколько /29 подсетей можно получить из сети с маской /24. Приведите несколько примеров /29 подсетей внутри сети 10.10.10.0/24.  
адресов в сети с маской /29 6 штук (не считая номер сети и броудкаст), подсетей /29 из /24 можно получить 32. 2 примера внизу листинга  
___  
	ivanov@lusankiya:~/vagrant$ ipcalc 10.10.10.0/24 /29
	Address:   10.10.10.0           00001010.00001010.00001010. 00000000
	Netmask:   255.255.255.0 = 24   11111111.11111111.11111111. 00000000
	Wildcard:  0.0.0.255            00000000.00000000.00000000. 11111111
	=>
	Network:   10.10.10.0/24        00001010.00001010.00001010. 00000000
	HostMin:   10.10.10.1           00001010.00001010.00001010. 00000001
	HostMax:   10.10.10.254         00001010.00001010.00001010. 11111110
	Broadcast: 10.10.10.255         00001010.00001010.00001010. 11111111
	Hosts/Net: 254                   Class A, Private Internet
	
	Subnets after transition from /24 to /29
	
	Netmask:   255.255.255.248 = 29 11111111.11111111.11111111.11111 000
	Wildcard:  0.0.0.7              00000000.00000000.00000000.00000 111
	
	 1.
	Network:   10.10.10.0/29        00001010.00001010.00001010.00000 000
	HostMin:   10.10.10.1           00001010.00001010.00001010.00000 001
	HostMax:   10.10.10.6           00001010.00001010.00001010.00000 110
	Broadcast: 10.10.10.7           00001010.00001010.00001010.00000 111
	Hosts/Net: 6                     Class A, Private Internet
	
	 2.
	Network:   10.10.10.8/29        00001010.00001010.00001010.00001 000
	HostMin:   10.10.10.9           00001010.00001010.00001010.00001 001
	HostMax:   10.10.10.14          00001010.00001010.00001010.00001 110
	Broadcast: 10.10.10.15          00001010.00001010.00001010.00001 111
	Hosts/Net: 6                     Class A, Private Internet
	
  
6.    Задача: вас попросили организовать стык между 2-мя организациями. Диапазоны 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 уже заняты. Из какой подсети допустимо взять частные IP адреса? Маску выберите из расчета максимум 40-50 хостов внутри подсети.  
100.64.0.0 — 100.127.255.255 (маска подсети 255.192.0.0 или /10) - Данная подсеть рекомендована согласно RFC 6598 для использования в качестве адресов для CGN (Carrier-Grade NAT).  
Маска для 40-50 хостов :100.64.0.0/26  
___  
	Netmask:   255.255.255.192 = 26 11111111.11111111.11111111.11 000000
	Network:   100.64.0.0/26        01100100.01000000.00000000.00 000000
	HostMin:   100.64.0.1           01100100.01000000.00000000.00 000001
	HostMax:   100.64.0.62          01100100.01000000.00000000.00 111110
	Broadcast: 100.64.0.63          01100100.01000000.00000000.00 111111
	Hosts/Net: 62                    Class A

  
7.    Как проверить ARP таблицу в Linux, Windows? Как очистить ARP кеш полностью? Как из ARP таблицы удалить только один нужный IP?  
windows:
___  
	C:\Users\sergey.myasnikov>arp -a
	Интерфейс: 100.100.14.113 --- 0x3  
	адрес в Интернете      Физический адрес      Тип  
	100.100.14.1          00-00-0c-9f-f0-02     динамический  
	100.100.14.8          6c-9c-ed-40-42-c1     динамический  
	100.100.14.9          40-55-39-0c-dd-c1     динамический  
	224.0.0.22            01-00-5e-00-00-16     статический  
	255.255.255.255       ff-ff-ff-ff-ff-ff     статический
	
	arp -d 192.168.100.25 <----удалить этот адрес из кэша arp  
	arp -d -a  <---- очистить все
linux:
___  
	ivanov@lusankiya:~/vagrant$ sudo arp -en
	Адрес HW-тип HW-адрес Флаги Маска Интерфейс
	192.168.1.5              ether   ac:b5:7d:58:a0:2d   C                     wlp8s0
	192.168.1.1              ether   24:4b:fe:9d:4b:18   C                     enp7s0
	192.168.1.200            ether   00:25:22:ad:9f:69   C                     wlp8s0
	192.168.1.1              ether   24:4b:fe:9d:4b:18   C                     wlp8s0
	192.168.1.200            ether   00:25:22:ad:9f:69   C                     enp7s0
	#remove one address:
	ivanov@lusankiya:~/vagrant$ sudo arp -i wlp8s0 -d 192.168.1.5
	ivanov@lusankiya:~/vagrant$ sudo arp -en
	Адрес HW-тип HW-адрес Флаги Маска Интерфейс
	192.168.1.1              ether   24:4b:fe:9d:4b:18   C                     enp7s0
	192.168.1.200            ether   00:25:22:ad:9f:69   C                     wlp8s0
	192.168.1.1              ether   24:4b:fe:9d:4b:18   C                     wlp8s0
	192.168.1.200            ether   00:25:22:ad:9f:69   C                     enp7s0
	#remove all arp cache
	ivanov@lusankiya:~/vagrant$ sudo ip  neigh flush all









