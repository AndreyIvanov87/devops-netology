Домашнее задание к занятию "3.9. Элементы безопасности информационных систем"

1.    Установите Bitwarden плагин для браузера. Зарегестрируйтесь и сохраните несколько паролей.
	https://github.com/AndreyIvanov87/devops-netology/blob/main/opera-with-bitwarden.png

2.    Установите Google authenticator на мобильный телефон. Настройте вход в Bitwarden акаунт через Google authenticator OTP.
	https://github.com/AndreyIvanov87/devops-netology/blob/main/bitwarden-twostep-auth.png

3.    Установите apache2, сгенерируйте самоподписанный сертификат, настройте тестовый сайт для работы по HTTPS.
___  
	vagrant@vagrant:~$ sudo apt install apache2
	vagrant@vagrant:~$ sudo a2enmod ssl
	Considering dependency setenvif for ssl:
	Module setenvif already enabled
	Considering dependency mime for ssl:
	Module mime already enabled
	Considering dependency socache_shmcb for ssl:
	Enabling module socache_shmcb.
	Enabling module ssl.
	See /usr/share/doc/apache2/README.Debian.gz on how to configure SSL and create self-signed certificates.
	To activate the new configuration, you need to run:
	  systemctl restart apache2
	vagrant@vagrant:~$ sudo systemctl restart apache2
	vagrant@vagrant:~$ sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	> -keyout /etc/ssl/private/apache-selfsigned.key \
	> -out /etc/ssl/certs/apache-selfsigned.crt \
	> -subj "/C=RU/ST=St-Petersburg/L=St-Petersburg/O=Company test/OU=Org/CN=www.example.com"
	Generating a RSA private key
	............................+++++
	........................+++++
	writing new private key to '/etc/ssl/private/apache-selfsigned.key'
	-----
	root@vagrant:~#  vim /etc/apache2/sites-available/192.168.1.61
	<VirtualHost 192.168.1.61:443>
	ServerName 192.168.1.61
	ServerAlias example.com,www.example.com
	DocumentRoot /var/www/example.com
	SSLEngine on
	SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
	SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
	</VirtualHost>
	
	root@vagrant:~# mkdir /var/www/example.com
	root@vagrant:~# echo '<h1>it worked!</h1>' > /var/www/example.com/index.html
	root@vagrant:~# mv /etc/apache2/sites-available/192.168.1.61 /etc/apache2/sites-available/192.168.1.61.conf
	root@vagrant:~# a2ensite 192.168.1.61.conf
	Enabling site 192.168.1.61.
	To activate the new configuration, you need to run:
	  systemctl reload apache2
	root@vagrant:~# apache2ctl configtest
	Syntax OK
	root@vagrant:~# systemctl reload apache2

	https://github.com/AndreyIvanov87/devops-netology/blob/main/self-signed-sert-warning.png
	https://github.com/AndreyIvanov87/devops-netology/blob/main/sert-info.png


4.    Проверьте на TLS уязвимости произвольный сайт в интернете.
___  
	vagrant@vagrant:~$ git clone --depth 1 https://github.com/drwetter/testssl.sh.git
	vagrant@vagrant:~/testssl.sh$ ./testssl.sh -U --sneaky https://cisco.com
	
	###########################################################
	    testssl.sh       3.1dev from https://testssl.sh/dev/
	    (dc782a8 2021-12-08 11:50:55 -- )
	
	      This program is free software. Distribution and
	             modification under GPLv2 permitted.
	      USAGE w/o ANY WARRANTY. USE IT AT YOUR OWN RISK!
	
	       Please file bugs @ https://testssl.sh/bugs/
	
	###########################################################
	
	 Using "OpenSSL 1.0.2-chacha (1.0.2k-dev)" [~183 ciphers]
	 on vagrant:./bin/openssl.Linux.x86_64
	 (built: "Jan 18 17:12:17 2019", platform: "linux-x86_64")
	
	
	 Start 2021-12-08 13:16:59        -->> 72.163.4.185:443 (cisco.com) <<--
	
	 Further IP addresses:   2001:420:1101:1::185 
	 rDNS (72.163.4.185):    redirect-ns.cisco.com.
	 Service detected:       HTTP
	
	
	 Testing vulnerabilities 
	
	 Heartbleed (CVE-2014-0160)                not vulnerable (OK), no heartbeat extension
	 CCS (CVE-2014-0224)                       not vulnerable (OK)
	 Ticketbleed (CVE-2016-9244), experiment.  not vulnerable (OK), no session ticket extension
	 ROBOT                                     not vulnerable (OK)
	 Secure Renegotiation (RFC 5746)           Not supported / VULNERABLE (NOT ok)
	 Secure Client-Initiated Renegotiation     not vulnerable (OK)
	 CRIME, TLS (CVE-2012-4929)                not vulnerable (OK)
	 BREACH (CVE-2013-3587)                    no gzip/deflate/compress/br HTTP compression (OK)  - only supplied "/" tested
	 POODLE, SSL (CVE-2014-3566)               not vulnerable (OK)
	 TLS_FALLBACK_SCSV (RFC 7507)              Downgrade attack prevention supported (OK)
	 SWEET32 (CVE-2016-2183, CVE-2016-6329)    not vulnerable (OK)
	 FREAK (CVE-2015-0204)                     not vulnerable (OK)
	 DROWN (CVE-2016-0800, CVE-2016-0703)      not vulnerable on this host and port (OK)
	                                           make sure you don't use this certificate elsewhere with SSLv2 enabled services
	                                           https://censys.io/ipv4?q=7C2CE19FE0720A47B1AC36D16C03E2AB67F04C363F08CB202CA12982CAF5E4D7 could help you to find out
	 LOGJAM (CVE-2015-4000), experimental      not vulnerable (OK): no DH EXPORT ciphers, no DH key detected with <= TLS 1.2
	 BEAST (CVE-2011-3389)                     TLS1: AES256-SHA AES128-SHA ECDHE-RSA-AES256-SHA ECDHE-RSA-AES128-SHA 
	                                           VULNERABLE -- but also supports higher protocols  TLSv1.1 TLSv1.2 (likely mitigated)
	 LUCKY13 (CVE-2013-0169), experimental     potentially VULNERABLE, uses cipher block chaining (CBC) ciphers with TLS. Check patches
	 Winshock (CVE-2014-6321), experimental    not vulnerable (OK) - CAMELLIA or ECDHE_RSA GCM ciphers found
	 RC4 (CVE-2013-2566, CVE-2015-2808)        no RC4 ciphers detected (OK)
	
	
	 Done 2021-12-08 13:18:29 [  91s] -->> 72.163.4.185:443 (cisco.com) <<--
	
	
5.    Установите на Ubuntu ssh сервер, сгенерируйте новый приватный ключ. Скопируйте свой публичный ключ на другой сервер. Подключитесь к серверу по SSH-ключу.
___  
	vagrant@vagrant:~$ sudo ss -nl  -t -p | grep 22
	LISTEN    0         128                0.0.0.0:22               0.0.0.0:*        users:(("sshd",pid=822,fd=3))                                                  
	LISTEN    0         128                   [::]:22                  [::]:*        users:(("sshd",pid=822,fd=4))             
	
	ivanov@lusankiya:~/netology/devops-netology$ ssh-keygen 
	Generating public/private rsa key pair.
	Enter file in which to save the key (/home/ivanov/.ssh/id_rsa): /home/ivanov/.ssh/id_rsa-vagrant-test
	Enter passphrase (empty for no passphrase): 
	Enter same passphrase again: 
	Your identification has been saved in /home/ivanov/.ssh/id_rsa-vagrant-test
	Your public key has been saved in /home/ivanov/.ssh/id_rsa-vagrant-test.pub
	The key fingerprint is:
	SHA256:MbRpwxPr3/3oc0bxUrhXe4NyzHrOhP43Kuuh5qOGcSc ivanov@lusankiya
	The key's randomart image is:
	+---[RSA 3072]----+
	|        o        |
	|       o =       |
	|        @      . |
	|       o =    ..o|
	|        S   o .o=|
	|     . E o o.*oo=|
	|      + o .o=..+o|
	|     . . ooo+..=o|
	|      ..+oo+**=+o|
	+----[SHA256]-----+
	ivanov@lusankiya:~/netology/devops-netology$ ssh-copy-id -i /home/ivanov/.ssh/id_rsa-vagrant-test vagrant@192.168.1.61
	/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/ivanov/.ssh/id_rsa-vagrant-test.pub"
	/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
	/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
	vagrant@192.168.1.61's password: 
	
	Number of key(s) added: 1
	
	Now try logging into the machine, with:   "ssh 'vagrant@192.168.1.61'"
	and check to make sure that only the key(s) you wanted were added.
	
	ivanov@lusankiya:~/netology/devops-netology$ ssh 'vagrant@192.168.1.61'
	Welcome to Ubuntu 20.04.2 LTS (GNU/Linux 5.4.0-80-generic x86_64)
	
	 * Documentation:  https://help.ubuntu.com
	 * Management:     https://landscape.canonical.com
	 * Support:        https://ubuntu.com/advantage
	
	  System information as of Wed 08 Dec 2021 01:49:06 PM UTC
	
	  System load:  0.0               Processes:             115
	  Usage of /:   2.5% of 61.31GB   Users logged in:       1
	  Memory usage: 17%               IPv4 address for eth0: 10.0.2.15
	  Swap usage:   0%                IPv4 address for eth1: 192.168.1.61
	
	
	This system is built by the Bento project by Chef Software
	More information can be found at https://github.com/chef/bento
	Last login: Wed Dec  8 13:13:52 2021 from 192.168.1.13
	

6.    Переименуйте файлы ключей из задания 5. Настройте файл конфигурации SSH клиента, так чтобы вход на удаленный сервер осуществлялся по имени сервера.
___  
	ivanov@lusankiya:~/netology/devops-netology$ mv ~/.ssh/id_rsa-vagrant-test ~/.ssh/id_rsa-vagrant-test1
	ivanov@lusankiya:~/netology/devops-netology$ cat ~/.ssh/config 
	Host my_server  
		HostName 192.168.1.61  
		IdentityFile ~/.ssh/id_rsa-vagrant-test1  
		User vagrant
	ivanov@lusankiya:~/netology/devops-netology$ ssh my_server
	Welcome to Ubuntu 20.04.2 LTS (GNU/Linux 5.4.0-80-generic x86_64)
	
	 * Documentation:  https://help.ubuntu.com
	 * Management:     https://landscape.canonical.com
	 * Support:        https://ubuntu.com/advantage
	
	  System information as of Wed 08 Dec 2021 07:56:57 PM UTC
	
	  System load:  0.0               Processes:             116
	  Usage of /:   2.5% of 61.31GB   Users logged in:       1
	  Memory usage: 18%               IPv4 address for eth0: 10.0.2.15
	  Swap usage:   0%                IPv4 address for eth1: 192.168.1.61
	
	
	This system is built by the Bento project by Chef Software
	More information can be found at https://github.com/chef/bento
	Last login: Wed Dec  8 19:55:34 2021 from 192.168.1.13
	vagrant@vagrant:~$ hostname
	vagrant

7.    Соберите дамп трафика утилитой tcpdump в формате pcap, 100 пакетов. Откройте файл pcap в Wireshark.
___  
	root@lusankiya:~# tcpdump -w /tmp/enp7s0.pcap -i enp7s0 -c 100
	tcpdump: listening on enp7s0, link-type EN10MB (Ethernet), capture size 262144 bytes
	100 packets captured
	118 packets received by filter
	0 packets dropped by kernel
https://github.com/AndreyIvanov87/devops-netology/blob/main/wireshark.png  


Задание для самостоятельной отработки (необязательно к выполнению)

8*. Просканируйте хост scanme.nmap.org. Какие сервисы запущены?
___  
	ivanov@lusankiya:~/netology/devops-netology$ sudo nmap -A scanme.nmap.org
	Starting Nmap 7.80 ( https://nmap.org ) at 2021-12-08 23:04 MSK
	Nmap scan report for scanme.nmap.org (45.33.32.156)
	Host is up (0.19s latency).
	Other addresses for scanme.nmap.org (not scanned): 2600:3c01::f03c:91ff:fe18:bb2f
	Not shown: 992 closed ports
		PORT      STATE    SERVICE      VERSION
	22/tcp    open     ssh          OpenSSH 6.6.1p1 Ubuntu 2ubuntu2.13 (Ubuntu Linux; protocol 2.0)		<<<<<------тут начинается список сервисов
	| ssh-hostkey: 
	|   1024 ac:00:a0:1a:82:ff:cc:55:99:dc:67:2b:34:97:6b:75 (DSA)
	|   2048 20:3d:2d:44:62:2a:b0:5a:9d:b5:b3:05:14:c2:a6:b2 (RSA)
	|   256 96:02:bb:5e:57:54:1c:4e:45:2f:56:4c:4a:24:b2:57 (ECDSA)
	|_  256 33:fa:91:0f:e0:e1:7b:1f:6d:05:a2:b0:f1:54:41:56 (ED25519)
	80/tcp    open     http         Apache httpd 2.4.7 ((Ubuntu))
	|_http-server-header: Apache/2.4.7 (Ubuntu)
	|_http-title: Go ahead and ScanMe!
	135/tcp   filtered msrpc
	139/tcp   filtered netbios-ssn
	445/tcp   filtered microsoft-ds
	5357/tcp  filtered wsdapi
	9929/tcp  open     nping-echo   Nping echo
	31337/tcp open     tcpwrapped
	Aggressive OS guesses: Linux 2.6.32 - 3.13 (93%), Linux 2.6.22 - 2.6.36 (91%), Linux 3.10 - 4.11 (91%), Linux 3.2 - 4.9 (90%), Linux 3.10 (90%), Linux 2.6.32 - 3.10 (90%), Linux 2.6.18 (90%), Linux 3.16 - 4.6 (90%), Linux 2.6.32 (90%), HP P2000 G3 NAS device (89%)
	No exact OS matches for host (test conditions non-ideal).
	Network Distance: 27 hops
	Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
	
	TRACEROUTE (using port 1025/tcp)
	HOP RTT       ADDRESS
	1   0.65 ms   router.asus.com (192.168.1.1)
	2   2.71 ms   79-134-198-145.obit.ru (79.134.198.145)
	3   1.92 ms   172.29.192.220
	4   1.93 ms   172.29.194.250
	5   1.96 ms   172.29.194.179
	6   1.25 ms   172.29.194.169
	7   2.28 ms   172.29.194.186
	8   2.38 ms   spb-r2-cr1.ae54-1125.rascom.as20764.net (80.64.103.2)
	9   ... 10
	11  23.10 ms  be3377.ccr22.sto03.atlas.cogentco.com (154.54.36.89)
	12  32.82 ms  be2555.rcr21.cph01.atlas.cogentco.com (154.54.61.237)
	13  34.15 ms  be2496.ccr41.ham01.atlas.cogentco.com (154.54.61.221)
	14  42.34 ms  be2815.ccr41.ams03.atlas.cogentco.com (154.54.38.205)
	15  136.69 ms be12194.ccr41.lon13.atlas.cogentco.com (154.54.56.93)
	16  138.57 ms be2317.ccr41.jfk02.atlas.cogentco.com (154.54.30.185)
	17  136.73 ms be3599.ccr21.alb02.atlas.cogentco.com (66.28.4.237)
	18  139.60 ms be2717.ccr41.ord01.atlas.cogentco.com (154.54.6.221)
	19  143.21 ms be2717.ccr41.ord01.atlas.cogentco.com (154.54.6.221)
	20  161.08 ms be3035.ccr21.den01.atlas.cogentco.com (154.54.5.89)
	21  172.72 ms be3037.ccr21.slc01.atlas.cogentco.com (154.54.41.145)
	22  170.43 ms be3037.ccr21.slc01.atlas.cogentco.com (154.54.41.145)
	23  188.62 ms be3178.ccr21.sjc01.atlas.cogentco.com (154.54.43.70)
	24  189.93 ms be2063.rcr21.b001848-1.sjc01.atlas.cogentco.com (154.54.1.162)
	25  188.24 ms 38.142.11.154
	26  191.83 ms if-1-6.csw5-fnc1.linode.com (173.230.159.67)
	27  196.59 ms scanme.nmap.org (45.33.32.156)
	
	OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
	Nmap done: 1 IP address (1 host up) scanned in 28.08 seconds
	
9*. Установите и настройте фаервол ufw на web-сервер из задания 3. Откройте доступ снаружи только к портам 22,80,443
___  
	root@vagrant:~# ufw status
	Status: inactive
	root@vagrant:~# ufw enable
	Command may disrupt existing ssh connections. Proceed with operation (y|n)? y
	Firewall is active and enabled on system startup
	root@vagrant:~# ufw status
	Status: active
	root@vagrant:~# ufw allow  ssh/tcp 
	Rule added
	Rule added (v6)
	root@vagrant:~# ufw default deny incoming
	Default incoming policy changed to 'deny'
	(be sure to update your rules accordingly)
	root@vagrant:~# ufw default allow outgoing
	Default outgoing policy changed to 'allow'
	(be sure to update your rules accordingly)
	root@vagrant:~# ufw status verbose
	Status: active
	Logging: on (low)
	Default: deny (incoming), allow (outgoing), disabled (routed)
	New profiles: skip
	
	To                         Action      From
	--                         ------      ----
	22/tcp                     ALLOW IN    Anywhere                  
	80                         ALLOW IN    Anywhere                  
	443                        ALLOW IN    Anywhere                  
	22/tcp (v6)                ALLOW IN    Anywhere (v6)             
	80 (v6)                    ALLOW IN    Anywhere (v6)             
	443 (v6)                   ALLOW IN    Anywhere (v6)             


