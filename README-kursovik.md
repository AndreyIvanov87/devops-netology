Курсовая работа по итогам модуля "DevOps и системное администрирование"  
  
Курсовая работа необходима для проверки практических навыков, полученных в ходе прохождения курса "DevOps и системное администрирование".  
  
Мы создадим и настроим виртуальное рабочее место. Позже вы сможете использовать эту систему для выполнения домашних заданий по курсу  
Задание  
  
1.    Создайте виртуальную машину Linux.  
2.    Установите ufw и разрешите к этой машине сессии на порты 22 и 443, при этом трафик на интерфейсе localhost (lo) должен ходить свободно на все порты.  
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
	root@vagrant:~# ufw  allow 443/tcp
	Rule added
	Rule added (v6)
	root@vagrant:~# ufw status  numbered
	Status: active
	
	     To                         Action      From
	     --                         ------      ----
	[ 1] 22/tcp                     ALLOW IN    Anywhere                  
	[ 2] 443/tcp                    ALLOW IN    Anywhere                  
	[ 3] 22/tcp (v6)                ALLOW IN    Anywhere (v6)             
	[ 4] 443/tcp (v6)               ALLOW IN    Anywhere (v6)       

3.    Установите hashicorp vault (инструкция по ссылке).  
___  
	root@vagrant:~# curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
	OK
	root@vagrant:~# apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
	Hit:1 http://archive.ubuntu.com/ubuntu focal InRelease
	Get:2 http://archive.ubuntu.com/ubuntu focal-updates InRelease [114 kB]
	...
	Get:20 http://security.ubuntu.com/ubuntu focal-security/universe Translation-en [111 kB]                                                                        
	Fetched 7,952 kB in 11s (716 kB/s)                                                                                                                              
	Reading package lists... Done
	root@vagrant:~# apt-get update &&  apt-get install vault
	Hit:1 http://archive.ubuntu.com/ubuntu focal InRelease
	Hit:2 http://archive.ubuntu.com/ubuntu focal-updates InRelease
	Hit:3 http://archive.ubuntu.com/ubuntu focal-backports InRelease
	Hit:4 http://security.ubuntu.com/ubuntu focal-security InRelease                                                              
	Hit:5 https://apt.releases.hashicorp.com focal InRelease                                                                      
	Reading package lists... Done                                
	Reading package lists... Done
	Building dependency tree       
	Reading state information... Done
	The following NEW packages will be installed:
	  vault
	0 upgraded, 1 newly installed, 0 to remove and 107 not upgraded.
	Need to get 69.4 MB of archives.
	After this operation, 188 MB of additional disk space will be used.
	Get:1 https://apt.releases.hashicorp.com focal/main amd64 vault amd64 1.9.1 [69.4 MB]
	Fetched 69.4 MB in 19s (3,664 kB/s)                                                                                                                             
	Selecting previously unselected package vault.
	(Reading database ... 42326 files and directories currently installed.)
	Preparing to unpack .../archives/vault_1.9.1_amd64.deb ...
	Unpacking vault (1.9.1) ...
	Setting up vault (1.9.1) ...
	Generating Vault TLS key and self-signed certificate...
	Generating a RSA private key
	..........................................................++++
	...++++
	writing new private key to 'tls.key'
	-----
	Vault TLS key and self-signed certificate have been generated in '/opt/vault/tls'.
	root@vagrant:~# systemctl  enable vault
	Created symlink /etc/systemd/system/multi-user.target.wants/vault.service → /lib/systemd/system/vault.service.
	root@vagrant:~# systemctl status vault
	● vault.service - "HashiCorp Vault - A tool for managing secrets"
	     Loaded: loaded (/lib/systemd/system/vault.service; enabled; vendor preset: enabled)
	     Active: inactive (dead)
	       Docs: https://www.vaultproject.io/docs/
	root@vagrant:~# mv /etc/vault.d/vault.hcl /etc/vault.d/vault.hcl-orig
	root@vagrant:~# vim.tiny /etc/vault.d/vault.hcl
	root@vagrant:~# cat /etc/vault.d/vault.hcl
	storage "raft" {  
		path    = "./vault/data"  
		node_id = "node1"
	}
	listener "tcp" {  
		address     = "127.0.0.1:8200"  
		tls_disable = "true"
		}
	api_addr = "http://127.0.0.1:8200"
	cluster_addr = "https://127.0.0.1:8201"
	ui = true
	root@vagrant:~# systemctl start vault
	root@vagrant:~# systemctl status vault
	● vault.service - "HashiCorp Vault - A tool for managing secrets"
	     Loaded: loaded (/lib/systemd/system/vault.service; enabled; vendor preset: enabled)
	     Active: active (running) since Mon 2021-12-13 06:36:22 UTC; 10min ago
	       Docs: https://www.vaultproject.io/docs/
	   Main PID: 3008 (vault)
	      Tasks: 8 (limit: 1071)
	     Memory: 58.5M
	     CGroup: /system.slice/vault.service
	             └─3008 /usr/bin/vault server -config=/etc/vault.d/vault.hcl
	
	Dec 13 06:36:22 vagrant vault[3008]:                    Mlock: supported: true, enabled: true
	Dec 13 06:36:22 vagrant vault[3008]:            Recovery Mode: false
	Dec 13 06:36:22 vagrant vault[3008]:                  Storage: file
	Dec 13 06:36:22 vagrant vault[3008]:                  Version: Vault v1.9.1
	Dec 13 06:36:22 vagrant vault[3008]: ==> Vault server started! Log data will stream in below:
	Dec 13 06:36:22 vagrant vault[3008]: 2021-12-13T06:36:22.049Z [INFO]  proxy environment: http_proxy="\"\"" https_proxy="\"\"" no_proxy="\"\""
	Dec 13 06:36:22 vagrant vault[3008]: 2021-12-13T06:36:22.049Z [WARN]  no `api_addr` value specified in config or in VAULT_API_ADDR; falling back to detection if>
	Dec 13 06:36:22 vagrant vault[3008]: 2021-12-13T06:36:22.068Z [INFO]  core: Initializing VersionTimestamps for core
	Dec 13 06:36:28 vagrant vault[3008]: 2021-12-13T06:36:28.235Z [INFO]  http: TLS handshake error from 127.0.0.1:47108: remote error: tls: bad certificate
	Dec 13 06:39:31 vagrant vault[3008]: 2021-12-13T06:39:31.567Z [INFO]  http: TLS handshake error from 127.0.0.1:47110: remote error: tls: bad certificate
	

4.    Cоздайте центр сертификации по инструкции (ссылка) и выпустите сертификат для использования его в настройке веб-сервера nginx (срок жизни сертификата - месяц).  
___  
	root@vagrant:~# apt-get install jq
	Reading package lists... Done
	Building dependency tree       
	...
	root@vagrant:/opt# mkdir -p ./vault/data
	root@vagrant:/opt# chown -R vault:vault /opt/vault/
	root@vagrant:/opt# cat /etc/vault.d/vault.hcl
	storage "raft" {  
		path    = "/opt/vault/data"  
		node_id = "node1"
	}
	listener "tcp" {  
		address     = "127.0.0.1:8200"  
		tls_disable = "true"
		}
	api_addr = "http://127.0.0.1:8200"
	cluster_addr = "https://127.0.0.1:8201"
	ui = true
	
	# Enable secrets engine
	path "sys/mounts/*" {  
	capabilities = [ "create", "read", "update", "delete", "list" ]
	}
	# List enabled secrets engine
	path "sys/mounts" {  
	capabilities = [ "read", "list" ]
	}
	# Work with pki secrets engine
	path "pki*" {  
	capabilities = [ "create", "read", "update", "delete", "list", "sudo" ]
	}
___  		
	root@vagrant:~# vault server -dev -dev-root-token-id root

	root@vagrant:/opt# export VAULT_ADDR=http://127.0.0.1:8200
	root@vagrant:/opt# export VAULT_TOKEN=root
	root@vagrant:/opt# vault secrets enable pki
	Success! Enabled the pki secrets engine at: pki/
	root@vagrant:/opt# vault secrets tune -max-lease-ttl=87600h pki
	Success! Tuned the secrets engine at: pki/
	######Generate the root certificate and save the certificate in CA_cert.crt.
	root@vagrant:/opt# vault write -field=certificate pki/root/generate/internal \
	> common_name="example.com" \
	> ttl=744h > CA_cert.crt
	root@vagrant:/opt# ls
	CA_cert.crt  vault  VBoxGuestAdditions-6.1.24
	root@vagrant:/opt# vault write pki/config/urls \
	>  issuing_certificates="$VAULT_ADDR/v1/pki/ca" \
	>      crl_distribution_points="$VAULT_ADDR/v1/pki/crl"
	Success! Data written to: pki/config/urls
	######Step 2: Generate intermediate CA
	root@vagrant:/opt# vault secrets enable -path=pki_int pki
	Success! Enabled the pki secrets engine at: pki_int/
	root@vagrant:/opt# vault secrets tune -max-lease-ttl=744h pki_int
	Success! Tuned the secrets engine at: pki_int/
	root@vagrant:/opt# vault write -format=json pki_int/intermediate/generate/internal \
	>      common_name="example.com Intermediate Authority" \
	> | jq -r '.data.csr' > pki_intermediate.csr
	root@vagrant:/opt# vault write -format=json pki/root/sign-intermediate csr=@pki_intermediate.csr \
	> format=pem_bundle ttl="744h" \
	> | jq -r '.data.certificate' > intermediate.cert.pem
	root@vagrant:/opt# vault write pki_int/intermediate/set-signed certificate=@intermediate.cert.pem
	Success! Data written to: pki_int/intermediate/set-signed
	########Create a role named example-dot-com which allows subdomains.
	root@vagrant:/opt# vault write pki_int/roles/example-dot-com \
	>      allowed_domains="example.com" \
	>  allow_subdomains=true \
	> max_ttl="744h"
	Success! Data written to: pki_int/roles/example-dot-com
	##########Step 4: Request certificates
	root@vagrant:/opt# vault write pki_int/issue/example-dot-com common_name="www.example.com" ttl="743h"
	Key                 Value
	---                 -----
	ca_chain            [-----BEGIN CERTIFICATE-----
	MIIDpjCCAo6gAwIBAgIUKIWUoDRVzPFy7Tu5T32ofMCcsMowDQYJKoZIhvcNAQEL
	...
	4EwUAUj8to3MD9sBVNyF0uqlFIYgEJupPCnO9ko8J3XCx43/iFU=
	-----END RSA PRIVATE KEY-----
	private_key_type    rsa
	serial_number       79:de:a7:36:ac:28:e4:ad:87:a4:a7:26:9e:c9:ca:4f:51:94:59:0d


5.    Установите корневой сертификат созданного центра сертификации в доверенные в хостовой системе.  
___  
	root@lusankiya:~# vim.tiny /usr/local/share/ca-certificates/vargant-root-CA_cert.crt
	root@lusankiya:~# update-ca-certificates
	Updating certificates in /etc/ssl/certs...
	1 added, 0 removed; done.
	Running hooks in /etc/ca-certificates/update.d...
	done.
	ivanov@lusankiya:~$ sudo apt install libnss3-tools
	ivanov@lusankiya:~$ certutil -A -n "example.com" -t "TCu,Cuw,Tuw" -i /usr/local/share/ca-certificates/vargant-root-CA_cert.crt -d sql:"/home/ivanov/.mozilla/firefox/inxcrs87.default-release"
	Notice: Trust flag u is set automatically if the private key is present.
	

6.    Установите nginx.  
___  
	root@vagrant:~# apt-get install nginx
	root@vagrant:~# systemctl enable nginx
	Synchronizing state of nginx.service with SysV service script with /lib/systemd/systemd-sysv-install.
	Executing: /lib/systemd/systemd-sysv-install enable nginx


7.    По инструкции (ссылка) настройте nginx на https, используя ранее подготовленный сертификат:  
  
    можно использовать стандартную стартовую страницу nginx для демонстрации работы сервера;  
    можно использовать и другой html файл, сделанный вами;  
___  
	root@vagrant:/etc/nginx# cat sites-available/www.example.com 
	server {
	    listen              443 ssl;
	    server_name         www.example.com 192.168.1.61 example.com;
		root /var/www/example.com;
		index index.html;
	    ssl_certificate     www.example.com.crt;
	    ssl_certificate_key www.example.com.key;
	    ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
	    ssl_ciphers         HIGH:!aNULL:!MD5;
	 }
	root@vagrant:/etc/nginx# grep -A 3 BEGIN  www.example.com.*
	www.example.com.crt:-----BEGIN CERTIFICATE-----
	www.example.com.crt-MIIDZDCCAkygAwIBAgIUed6nNqwo5K2HpKcmnsnKT1GUWQ0wDQYJKoZIhvcNAQEL
	www.example.com.crt-BQAwLTErMCkGA1UEAxMiZXhhbXBsZS5jb20gSW50ZXJtZWRpYXRlIEF1dGhvcml0
	www.example.com.crt-eTAeFw0yMTEyMTMwODU3MzJaFw0yMjAxMTMwNzU4MDFaMBoxGDAWBgNVBAMTD3d3
	--
	www.example.com.crt:-----BEGIN CERTIFICATE-----
	www.example.com.crt-MIIDpjCCAo6gAwIBAgIUKIWUoDRVzPFy7Tu5T32ofMCcsMowDQYJKoZIhvcNAQEL
	www.example.com.crt-BQAwFjEUMBIGA1UEAxMLZXhhbXBsZS5jb20wHhcNMjExMjEzMDg0MDI2WhcNMjIw
	www.example.com.crt-MTEzMDg0MDU2WjAtMSswKQYDVQQDEyJleGFtcGxlLmNvbSBJbnRlcm1lZGlhdGUg
	--
	www.example.com.key:-----BEGIN RSA PRIVATE KEY-----
	www.example.com.key-MIIEogIBAAKCAQEAwf+HSQwp2psefVa4do4jv4iLSpPe9PfuzNvlmgF1c8TuNNur
	www.example.com.key-kYaZQqfwkHD8bjHrKszaBhUes1E9YuMtBofZqv2JawT1J7HwyHZ+KHj/RFMGRf/+
	www.example.com.key-RAV4NF8spx+JEL1nZ//Sv3+AzXG/KvgSx698dnaJBcwaKM0ItDx7ErpzTGTlyqZE
	root@vagrant:/etc/nginx# ln -s /etc/nginx/sites-available/www.example.com sites-enabled/www.example.com 
	root@vagrant:/etc/nginx# nginx -t
	nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
	nginx: configuration file /etc/nginx/nginx.conf test is successful
	root@vagrant:/etc/nginx# systemctl start nginx
	root@vagrant:/etc/nginx# systemctl status nginx
	● nginx.service - A high performance web server and a reverse proxy server
	     Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
	     Active: active (running) since Mon 2021-12-13 10:44:32 UTC; 5s ago
	       Docs: man:nginx(8)
	    Process: 4776 ExecStartPre=/usr/sbin/nginx -t -q -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
	    Process: 4787 ExecStart=/usr/sbin/nginx -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
	   Main PID: 4788 (nginx)
	      Tasks: 3 (limit: 1071)
	     Memory: 3.4M
	     CGroup: /system.slice/nginx.service
	             ├─4788 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
	             ├─4789 nginx: worker process
	             └─4790 nginx: worker process

	Dec 13 10:44:32 vagrant systemd[1]: Starting A high performance web server and a reverse proxy server...
	Dec 13 10:44:32 vagrant systemd[1]: Started A high performance web server and a reverse proxy server.

	
8.    Откройте в браузере на хосте https адрес страницы, которую обслуживает сервер nginx.  
___  
	ivanov@lusankiya:~$ cat /etc/hosts | grep example
	192.168.1.61	example.com
	192.168.1.61    www.example.com

https://github.com/AndreyIvanov87/devops-netology/blob/main/ssl-browser.png  

9.    Создайте скрипт, который будет генерировать новый сертификат в vault:  
  
    генерируем новый сертификат так, чтобы не переписывать конфиг nginx;  
    перезапускаем nginx для применения нового сертификата.  
___  
	#!/usr/bin/env bash
	export VAULT_ADDR=http://127.0.0.1:8200
	export VAULT_TOKEN=root
	
	NUMBER=`grep serial_number /etc/nginx/www.example.com.key | awk '{print $2}'`
	echo $NUMBER
	vault write pki_int/revoke serial_number=$NUMBER
	
	vault write pki_int/issue/example-dot-com common_name="www.example.com" ttl="700h"  |  grep -v expiration | grep -A 1000 certificate | sed 's/private_key         //' | sed 's/issuing_ca          //' | sed 's/certificate         //' > /tmp/prepare-sert.txt
	
	
	grep -B 1000 'BEGIN RSA PRIVATE KEY' /tmp/prepare-sert.txt | head -n -1 > /tmp/www.example.com.crt
	grep -A 1000 'BEGIN RSA PRIVATE KEY' /tmp/prepare-sert.txt > /tmp/www.example.com.key
	
	mv /etc/nginx/www.example.com.crt /etc/nginx/www.example.com.crt-bak
	mv /etc/nginx/www.example.com.key /etc/nginx/www.example.com.key-bak
	mv /tmp/www.example.com.crt /etc/nginx/www.example.com.crt
	mv /tmp/www.example.com.key /etc/nginx/www.example.com.key
	rm /tmp/prepare-sert.txt
	rm cat /tmp/sert.txt 
	systemctl reload nginx
  
10.    Поместите скрипт в crontab, чтобы сертификат обновлялся какого-то числа каждого месяца в удобное для вас время.  
___    
	root@vagrant:/etc/nginx# crontab -l | tail -n 3
	# m h  dom mon dow   command
	#*	*	*	*	* 	/root/test.sh
	30	10	14	*	*	/root/update-sert.sh
	root@vagrant:/etc/nginx# systemctl restart cron
	root@vagrant:/etc/nginx# tail /var/log/syslog
	Dec 14 10:30:01 vagrant CRON[6025]: (root) CMD (/root/update-sert.sh)
	Dec 14 10:30:01 vagrant systemd[1]: Reloading A high performance web server and a reverse proxy server.
	Dec 14 10:30:01 vagrant systemd[1]: Reloaded A high performance web server and a reverse proxy server.
	root@vagrant:/etc/nginx# ls -alh /etc/nginx/www.example.com.*
	-rw-r--r-- 1 root root 2.6K Dec 14 10:30 /etc/nginx/www.example.com.crt
	-rw-r--r-- 1 root root 2.6K Dec 14 10:19 /etc/nginx/www.example.com.crt-bak
	-rw-r--r-- 1 root root 1.8K Dec 14 10:30 /etc/nginx/www.example.com.key
	-rw-r--r-- 1 root root 1.8K Dec 14 10:19 /etc/nginx/www.example.com.key-bak

https://github.com/AndreyIvanov87/devops-netology/blob/main/new-sert-updated.png
	

  
  
Результатом курсовой работы должны быть снимки экрана или текст:  
  
    Процесс установки и настройки ufw  
    Процесс установки и выпуска сертификата с помощью hashicorp vault  
    Процесс установки и настройки сервера nginx  
    Страница сервера nginx в браузере хоста не содержит предупреждений  
    Скрипт генерации нового сертификата работает (сертификат сервера ngnix должен быть "зеленым")  
    Crontab работает (выберите число и время так, чтобы показать что crontab запускается и делает что надо)  






