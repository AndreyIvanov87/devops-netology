Домашнее задание к занятию "3.6. Компьютерные сети, лекция 1"

1.    Работа c HTTP через телнет.  
  
    Подключитесь утилитой телнет к сайту stackoverflow.com telnet stackoverflow.com 80  
    отправьте HTTP запрос  
  
GET /questions HTTP/1.0  
HOST: stackoverflow.com  
[press enter]  
[press enter]  
  
    В ответе укажите полученный HTTP код, что он означает?  
________________________
	vagrant@vagrant:~$ telnet stackoverflow.com 80  
	Trying 151.101.1.69...
	Connected to stackoverflow.com.
	Escape character is '^]'.
	GET /questions HTTP/1.0
	HOST: stackoverflow.com
	
	HTTP/1.1 301 Moved Permanently
	cache-control: no-cache, no-store, must-revalidate
	location: https://stackoverflow.com/questions
	x-request-guid: 5535d54c-7d8d-4275-a6a6-777ba13d9d13
	feature-policy: microphone 'none'; speaker 'none'
	content-security-policy: upgrade-insecure-requests; frame-ancestors 'self' https://stackexchange.com
	Accept-Ranges: bytes
	Date: Mon, 29 Nov 2021 06:03:10 GMT
	Via: 1.1 varnish
	Connection: close
	X-Served-By: cache-hhn4074-HHN
	X-Cache: MISS
	X-Cache-Hits: 0
	X-Timer: S1638165790.419716,VS0,VE92
	Vary: Fastly-SSL
	X-DNS-Prefetch-Control: off
	Set-Cookie: prov=2b0971fe-675c-bddf-37fa-316de448fddd; domain=.stackoverflow.com; expires=Fri, 01-Jan-2055 00:00:00 GMT; path=/; HttpOnly

	Connection closed by foreign host.

HTTP/1.1 301 Moved Permanently  
стандартный код ответа HTTP, получаемый в ответ от сервера в ситуации, когда запрошенный ресурс был на постоянной основе перемещён в новое месторасположение, и указывающий на то, что текущие ссылки, использующие данный URL, должны быть обновлены. Адрес нового месторасположения ресурса указывается в поле Location получаемого в ответ заголовка пакета протокола HTTP  


2.    Повторите задание 1 в браузере, используя консоль разработчика F12.  
  
    откройте вкладку Network  
    отправьте запрос http://stackoverflow.com  
    найдите первый ответ HTTP сервера, откройте вкладку Headers  
    укажите в ответе полученный HTTP код.  
	Состояние   
	200  
	OK  
	ВерсияHTTP/2  
	Передано51,73 КБ (размер 172,83 КБ)  
    проверьте время загрузки страницы, какой запрос обрабатывался дольше всего?  
	Первый запрос дольше всего, 300мс. Всего остальные 895 мс.  
    приложите скриншот консоли браузера в ответ.  
	https://github.com/AndreyIvanov87/devops-netology/blob/main/browser-console.png  	

3.    Какой IP адрес у вас в интернете?  
	inetnum:        95.161.144.0 - 95.161.239.255
4.    Какому провайдеру принадлежит ваш IP адрес? Какой автономной системе AS? Воспользуйтесь утилитой whois  
_____________________________  
	ivanov@lusankiya:~/vagrant$ sudo apt-get install whois 
	ivanov@lusankiya:~/vagrant$ whois 95.161.166.5
	inetnum:        95.161.144.0 - 95.161.239.255
	netname:        RU-OBIT-20081223 <- Провайдер - Обит.
	origin:         AS8492 <- номер AS
	

5.    Через какие сети проходит пакет, отправленный с вашего компьютера на адрес 8.8.8.8? Через какие AS? Воспользуйтесь утилитой traceroute  
____________________________  
	sudo apt install traceroute
	ivanov@lusankiya:~/vagrant$ traceroute -An 8.8.8.8
	traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets
	 1  192.168.1.1 [*]  0.626 ms  382.663 ms  382.640 ms
	 2  79.134.198.145 [AS8492]  1.955 ms  1.985 ms  2.020 ms
	 3  172.29.192.220 [*]  2.207 ms  2.419 ms  2.765 ms
	 4  172.29.194.250 [*]  1.950 ms  1.994 ms  2.109 ms
	 5  172.29.194.179 [*]  2.175 ms  2.322 ms  2.382 ms
	 6  172.29.194.169 [*]  2.434 ms  1.245 ms  1.437 ms
	 7  172.29.194.186 [*]  16.195 ms  16.155 ms  16.116 ms
	 8  85.114.1.12 [AS8492]  1.954 ms  1.916 ms  2.002 ms
	 9  72.14.198.236 [AS15169]  4.499 ms  4.468 ms  4.435 ms
	10  74.125.244.133 [AS15169]  2.647 ms  2.619 ms  2.584 ms
	11  72.14.232.84 [AS15169]  3.199 ms 142.251.61.221 [AS15169]  6.984 ms 142.251.51.187 [AS15169]  7.887 ms
	12  142.250.209.25 [AS15169]  6.168 ms 142.250.56.13 [AS15169]  5.228 ms 172.253.64.57 [AS15169]  7.345 ms
	13  * 142.250.210.103 [AS15169]  6.298 ms *
	14  * * *
	15  * * *
	16  * * *
	17  * * *
	18  * * *
	19  * * *
	20  * * *
	21  * * *
	22  * * 8.8.8.8 [AS15169]  5.170 ms
AS:AS8492,AS15169  


6.    Повторите задание 5 в утилите mtr. На каком участке наибольшая задержка - delay?  
Наибольшая задержка на 12м хопе - 9.5  
https://github.com/AndreyIvanov87/devops-netology/blob/main/mtr.png  

7.    Какие DNS сервера отвечают за доменное имя dns.google? Какие A записи? воспользуйтесь утилитой dig  
___
	ivanov@lusankiya:~/vagrant$ whois dns.google
	Name Server: ns1.zdns.google
	Name Server: ns2.zdns.google
	Name Server: ns3.zdns.google
	Name Server: ns4.zdns.google
	ivanov@lusankiya:~/vagrant$ dig -t A @ns2.zdns.google dns.google | grep -v ';'
	dns.google.		900	IN	A	8.8.8.8
	dns.google.		900	IN	A	8.8.4.4
	

8.    Проверьте PTR записи для IP адресов из задания 7. Какое доменное имя привязано к IP? воспользуйтесь утилитой dig  
___
	ivanov@lusankiya:~/vagrant$ dig -t PTR  8.8.8.8.in-addr.arpa | grep -v ';'
	8.8.8.8.in-addr.arpa.	6312	IN	PTR	dns.google.
	ivanov@lusankiya:~/vagrant$ dig -t PTR  4.4.8.8.in-addr.arpa | grep -v ';'
	4.4.8.8.in-addr.arpa.	5146	IN	PTR	dns.google.


