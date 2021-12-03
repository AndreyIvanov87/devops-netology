Домашнее задание к занятию "3.8. Компьютерные сети, лекция 3"

1.    Подключитесь к публичному маршрутизатору в интернет. Найдите маршрут к вашему публичному IP

	telnet route-views.routeviews.org  
	Username: rviews  
	show ip route 95.161.166.5/32  
	show bgp 95.161.166.5/32  
___  
	route-views>show ip route 95.161.166.5 
	Routing entry for 95.161.164.0/22
	  Known via "bgp 6447", distance 20, metric 0
	  Tag 6939, type external
	  Last update from 64.71.137.241 7w0d ago
	  Routing Descriptor Blocks:
	  * 64.71.137.241, from 64.71.137.241, 7w0d ago
	      Route metric is 0, traffic share count is 1
	      AS Hops 2
	      Route tag 6939
	      MPLS label: none
	
	route-views>show bgp 95.161.166.5
	BGP routing table entry for 95.161.164.0/22, version 978702935
	Paths: (24 available, best #23, table default)
	  Not advertised to any peer
	  Refresh Epoch 3
	  3303 9002 8492
	    217.192.89.50 from 217.192.89.50 (138.187.128.158)
	      Origin IGP, localpref 100, valid, external
	      Community: 3303:1004 3303:1007 3303:1030 3303:3067 9002:64667
	      path 7FE1519028B8 RPKI State valid
	      rx pathid: 0, tx pathid: 0
	  Refresh Epoch 1
	  4901 6079 9002 8492
	    162.250.137.254 from 162.250.137.254 (162.250.137.254)
	      Origin IGP, localpref 100, valid, external
	      Community: 65000:10100 65000:10300 65000:10400
	      path 7FE0A55D0A50 RPKI State valid
	      rx pathid: 0, tx pathid: 0
	  Refresh Epoch 1
	  7660 2516 12389 8492
	    203.181.248.168 from 203.181.248.168 (203.181.248.168)
	      Origin IGP, localpref 100, valid, external
	      Community: 2516:1050 7660:9001
	      path 7FE0135BD288 RPKI State valid
	      rx pathid: 0, tx pathid: 0
	  Refresh Epoch 1
	  3267 8492
	    194.85.40.15 from 194.85.40.15 (185.141.126.1)
	      Origin IGP, metric 0, localpref 100, valid, external
	      path 7FE08146EF08 RPKI State valid
	      rx pathid: 0, tx pathid: 0
	  Refresh Epoch 1
	  57866 9002 8492
	    37.139.139.17 from 37.139.139.17 (37.139.139.17)
	      Origin IGP, metric 0, localpref 100, valid, external
	      Community: 9002:0 9002:64667
	      path 7FE013349C88 RPKI State valid
	      rx pathid: 0, tx pathid: 0
	  Refresh Epoch 1
	  7018 1299 31133 8492

	route-views>traceroute 95.161.166.5
	Type escape sequence to abort.
	Tracing the route to 95-161-166-5.obit.ru (95.161.166.5)
	VRF info: (vrf in name/id, vrf out name/id)
	  1 vl-51-gw.uoregon.edu (128.223.51.1) [AS 3582] 48 msec 50 msec 49 msec
	  2 vl-51-gw.uoregon.edu (128.223.51.1) [AS 3582] 49 msec 48 msec 48 msec
	  3 10.252.19.1 [AS 174] 49 msec
	    10.252.20.5 [AS 174] 48 msec
	    10.252.19.1 [AS 174] 48 msec
	  4 10.252.10.249 [AS 174] 48 msec
	    10.252.9.249 [AS 174] 49 msec 48 msec
	  5 10.252.9.246 [AS 174] 117 msec
	    10.252.10.250 [AS 174] 48 msec
	    10.252.9.246 [AS 174] 48 msec
	  6 eugn-pe1-gw.nero.net (207.98.68.190) [AS 3701] 48 msec 48 msec
	    eugn-pe2-gw.nero.net (207.98.68.226) [AS 3701] 48 msec
	  7 eugn-p2-gw.nero.net (207.98.64.204) [AS 3701] [MPLS: Label 300496 Exp 0] 48 msec 48 msec 49 msec
	  8 ptck-p2-gw.nero.net (207.98.64.211) [AS 3701] [MPLS: Label 301232 Exp 0] 48 msec 49 msec 49 msec
	  9 ptck-pe2-gw.nero.net (207.98.64.84) [AS 3701] 50 msec 48 msec 49 msec
	 10 te0-4-0-33.ccr21.pdx01.atlas.cogentco.com (38.142.108.49) [AS 174] 116 msec 48 msec 109 msec
	 11 be2671.ccr21.sea02.atlas.cogentco.com (154.54.31.77) [AS 174] 49 msec 50 msec
	    be2670.ccr22.sea02.atlas.cogentco.com (154.54.42.149) [AS 174] 48 msec
	 12 be2085.ccr21.slc01.atlas.cogentco.com (154.54.2.198) [AS 174] 116 msec 48 msec 48 msec
	 13 be3037.ccr21.den01.atlas.cogentco.com (154.54.41.146) [AS 174] 48 msec 48 msec 48 msec
	 14 be3035.ccr21.mci01.atlas.cogentco.com (154.54.5.90) [AS 174] 98 msec 96 msec 117 msec
	 15 be2831.ccr41.ord01.atlas.cogentco.com (154.54.42.166) [AS 174] 99 msec 97 msec 97 msec
	 16 be2717.ccr21.cle04.atlas.cogentco.com (154.54.6.222) [AS 174] 98 msec 98 msec 117 msec
	 17 be2993.ccr31.yyz02.atlas.cogentco.com (154.54.31.226) [AS 174] 98 msec 101 msec 97 msec
	 18 be3259.ccr21.ymq01.atlas.cogentco.com (154.54.41.206) [AS 174] 98 msec 165 msec 99 msec
	 19 be3042.ccr21.lpl01.atlas.cogentco.com (154.54.44.161) [AS 174] 195 msec 151 msec 197 msec
	 20 be2182.ccr41.ams03.atlas.cogentco.com (154.54.77.245) [AS 174] 168 msec 199 msec 195 msec
	 21 be2815.ccr41.ham01.atlas.cogentco.com (154.54.38.206) [AS 174] 197 msec 208 msec 196 msec
	 22 be2483.ccr21.waw01.atlas.cogentco.com (130.117.51.61) [AS 174] 199 msec
	    be2484.ccr21.waw01.atlas.cogentco.com (130.117.51.105) [AS 174] 210 msec 199 msec
	 23 be2486.rcr21.b016833-0.waw01.atlas.cogentco.com (154.54.37.42) [AS 174] 200 msec 216 msec 198 msec
	 24 149.6.70.250 [AS 174] 198 msec 196 msec 202 msec
	 25 83.169.204.73 [AS 31133] [MPLS: Label 24001 Exp 2] 210 msec
	    83.169.204.69 [AS 31133] [MPLS: Label 24000 Exp 2] 201 msec 202 msec
	 26 83.169.204.172 [AS 31133] [MPLS: Label 24643 Exp 2] 197 msec
	    83.169.204.162 [AS 31133] [MPLS: Label 24616 Exp 2] 197 msec 221 msec
	 27 178.176.190.17 [AS 31133] 196 msec 198 msec 216 msec
	 28 vi-xx-0092.brc2.spb.obit.ru (85.114.1.250) [AS 8492] 198 msec 308 msec 197 msec
	 29  *  *  * 
	 30  *  *  * 


2.    Создайте dummy0 интерфейс в Ubuntu. Добавьте несколько статических маршрутов. Проверьте таблицу маршрутизации.
___ 
	root@vagrant:~# ip -c -br link
	lo               UNKNOWN        00:00:00:00:00:00 <LOOPBACK,UP,LOWER_UP> 
	eth0             UP             08:00:27:73:60:cf <BROADCAST,MULTICAST,UP,LOWER_UP> 
	dummy0           UNKNOWN        0a:f0:4e:1c:d1:d5 <BROADCAST,NOARP,UP,LOWER_UP> 
	root@vagrant:~# ip -c -br address
	lo               UNKNOWN        127.0.0.1/8 ::1/128 
	eth0             UP             10.0.2.15/24 fe80::a00:27ff:fe73:60cf/64 
	dummy0           UNKNOWN        10.2.2.2/32 fe80::8f0:4eff:fe1c:d1d5/64 
	
	root@vagrant:~# ip route show 
	default via 10.0.2.2 dev eth0 proto dhcp src 10.0.2.15 metric 100 
	10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 
	10.0.2.2 dev eth0 proto dhcp scope link src 10.0.2.15 metric 100 
	
	root@vagrant:~# ip route add 192.168.1.0/24 via 10.0.2.2
	root@vagrant:~# ip route add 10.10.20.0/24 dev dummy0
	root@vagrant:~# ip route show 
	default via 10.0.2.2 dev eth0 proto dhcp src 10.0.2.15 metric 100 
	10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 
	10.0.2.2 dev eth0 proto dhcp scope link src 10.0.2.15 metric 100 
	10.10.20.0/24 dev dummy0 scope link 
	192.168.1.0/24 via 10.0.2.2 dev eth0 
	root@vagrant:~# ip -c -br route show 192.168.1.0/24
	192.168.1.0/24 via 10.0.2.2 dev eth0 


3.    Проверьте открытые TCP порты в Ubuntu, какие протоколы и приложения используют эти порты? Приведите несколько примеров.
___  
root@vagrant:~# ss -nl  -t -p
	State          Recv-Q         Send-Q                 Local Address:Port                 Peer Address:Port        Process                                                          
	LISTEN         0              4096                   127.0.0.53%lo:53                        0.0.0.0:*            users:(("systemd-resolve",pid=560,fd=13))                       
	LISTEN         0              128                          0.0.0.0:22                        0.0.0.0:*            users:(("sshd",pid=2268,fd=3))                                  
	LISTEN         0              4096                         0.0.0.0:111                       0.0.0.0:*            users:(("rpcbind",pid=559,fd=4),("systemd",pid=1,fd=35))        
	LISTEN         0              128                             [::]:22                           [::]:*            users:(("sshd",pid=2268,fd=4))                                  
	LISTEN         0              4096                            [::]:111                          [::]:*            users:(("rpcbind",pid=559,fd=6),("systemd",pid=1,fd=37))        
sshd слушает порт 22 на всех интерфейсах по ipv4 & ipv6 , обрабатывает соединения по протоколу ssh  
systemd-resolved на порту 53 на локальном интерфейсе 127.0.0.53 обрабатывает локальные запросы к dns  

4.    Проверьте используемые UDP сокеты в Ubuntu, какие протоколы и приложения используют эти порты?
___  
	root@vagrant:~# ss -nl  -u -p
	State         Recv-Q         Send-Q                  Local Address:Port                 Peer Address:Port        Process                                                          
	UNCONN        0              0                       127.0.0.53%lo:53                        0.0.0.0:*            users:(("systemd-resolve",pid=560,fd=12))                       
	UNCONN        0              0                      10.0.2.15%eth0:68                        0.0.0.0:*            users:(("systemd-network",pid=400,fd=19))                       
	UNCONN        0              0                             0.0.0.0:111                       0.0.0.0:*            users:(("rpcbind",pid=559,fd=5),("systemd",pid=1,fd=36))        
	UNCONN        0              0                                [::]:111                          [::]:*            users:(("rpcbind",pid=559,fd=7),("systemd",pid=1,fd=38))        
rpcbind на udp порту 111 на всех интерфейсах. Портмаппер это специальный сервис в Linux, который обеспечивает службы RPC (Remote Procedure Call), такие как NFS - служба, например.  
systemd-resolved на порту 53 (udp) на локальном интерфейсе 127.0.0.53 обрабатывает локальные запросы к dns.  


5.    Используя diagrams.net, создайте L3 диаграмму вашей домашней сети или любой другой сети, с которой вы работали.  
схема домашней сети https://github.com/AndreyIvanov87/devops-netology/blob/main/network.drawio.png  







