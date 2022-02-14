## devops-netology homework 2021-11-16
Домашнее задание к занятию "3.2. Работа в терминале, лекция 2"  

1. Какого типа команда cd? Попробуйте объяснить, почему она именно такого типа;   
	Это встроенная команда оболочки. Командная оболочка должна поддерживать базовые операции с файлами и каталогами, это одна из них.  

2. Какая альтернатива без pipe команде grep <some_string> <some_file> | wc -l? man grep поможет в ответе на этот вопрос.  
	grep -c  <some_string> <some_file>  

3. Какой процесс с PID 1 является родителем для всех процессов в вашей виртуальной машине Ubuntu 20.04?  
	vagrant@vagrant:~$ ps auxww | grep ' 1 '  
	root           1  1.5  0.5 101808 11212 ?        Ss   12:17   0:00 /sbin/init  
  
4. Как будет выглядеть команда, которая перенаправит вывод stderr ls на другую сессию терминала?   
	ls dfgjldfjglkdfjgl 2>/dev/pts/1  

5. Получится ли одновременно передать команде файл на stdin и вывести ее stdout в другой файл? Приведите работающий пример.  
	cat /var/log/auth.log  | grep sudo > /tmp/result.txt  

	----->>>> доработано  
	Redirecting Input  
       Redirection of input causes the file whose name results from the expansion of word to be opened for reading on file descriptor n,  
       or the standard input (file descriptor 0) if n is not specified.  
       The general format for redirecting input is:  
              [n]<word  

	vagrant@vagrant:/tmp$ grep sudo < /var/log/auth.log > /tmp/result.txt   
	vagrant@vagrant:/tmp$ cat /tmp/result.txt   
	Jul 28 17:57:27 vagrant sudo: pam_unix(sudo:session): session closed for user root  
	Jul 28 17:57:27 vagrant sudo:  vagrant : TTY=unknown ; PWD=/home/vagrant ; USER=root ; COMMAND=/usr/bin/sh -eux /tmp/script_3439.sh  
	Jul 28 17:57:27 vagrant sudo: pam_unix(sudo:session): session opened for user root by (uid=0)  
	Jul 28 17:59:17 vagrant sudo: pam_unix(sudo:session): session closed for user root  


6. Получится ли находясь в графическом режиме, вывести данные из PTY в какой-либо из эмуляторов TTY? Сможете ли вы наблюдать выводимые данные?  
	ls > /dev/tty3   
	Посмотреть результат: ctrl+alt+f3

7. Выполните команду bash 5>&1. К чему она приведет? Что будет, если вы выполните echo netology > /proc/$$/fd/5? Почему так происходит?  
	vagrant@vagrant:$ ls -l /proc/$$/fd/ 
	total 0  
	lrwx------ 1 vagrant vagrant 64 Nov 16 13:07 0 -> /dev/pts/0  
	lrwx------ 1 vagrant vagrant 64 Nov 16 13:07 1 -> /dev/pts/0  
	lrwx------ 1 vagrant vagrant 64 Nov 16 13:07 2 -> /dev/pts/0  
	lrwx------ 1 vagrant vagrant 64 Nov 16 13:07 255 -> /dev/pts/0  
	lrwx------ 1 vagrant vagrant 64 Nov 16 13:07 5 -> /dev/pts/0  
	vagrant@vagrant:$ echo netology > /proc/$$/fd/5  
	netology  
  
	Мы вызвали bash , создали файловый дескриптор и перенаправили этот поток в stdout баша  
	
8. Получится ли в качестве входного потока для pipe использовать только stderr команды, не потеряв при этом отображение stdout на pty? Напоминаем: по умолчанию через pipe передается только stdout команды слева от | на stdin команды справа. Это можно сделать, поменяв стандартные потоки местами через промежуточный новый дескриптор, который вы научились создавать в предыдущем вопросе.  

	vagrant@vagrant:$ echo netology >  /tmp/test   
	vagrant@vagrant:$ cat /var/log/auth.logsfdf /tmp/test  3>&2 2>&1 1>&3 | grep cat  
	netology  
	cat: /var/log/auth.logsfdf: No such file or directory  

9. Что выведет команда cat /proc/$$/environ? Как еще можно получить аналогичный по содержанию вывод?  
	/proc/$$/environ выведет список переменных окружения bash. Такой же вывод можно получить еще вот так:  
	 env | tr -d '\n'  

10. Используя man, опишите что доступно по адресам /proc/PID/cmdline, /proc/PID/exe  
 	/proc/$$/cmdline содержит команду с помощью которой был запущен процесс, а также переданные ей параметры  
	exe - ссылка на исполняемый файл  
	/proc/1398/exe -> /usr/bin/bash  
  
11. Узнайте, какую наиболее старшую версию набора инструкций SSE поддерживает ваш процессор с помощью /proc/cpuinfo.
	sse4_2  
12. При открытии нового окна терминала и vagrant ssh создается новая сессия и выделяется pty. Это можно подтвердить командой tty, которая упоминалась в лекции 3.2. Однако:  
  
	vagrant@netology1:$ ssh localhost 'tty'  
	not a tty  
Почитайте, почему так происходит, и как изменить поведение.  

	ssh получает команду tty на stdin , не выделяя терминал для нее, о чем говорит ошибка. С опцией -t Force pseudo-terminal allocation.работает   
	vagrant@vagrant:$ ssh localhost 'tty'  
	vagrant@localhost's password:   
	not a tty  
	vagrant@vagrant:$ ssh -t localhost 'tty'  
	vagrant@localhost's password:   
	/dev/pts/1  
	vagrant@vagrant:$ 
	Connection to localhost closed.  
	vagrant@vagrant:$ tty   
	/dev/pts/0  
13.	Бывает, что есть необходимость переместить запущенный процесс из одной сессии в другую. Попробуйте сделать это, воспользовавшись reptyr. Например, так можно перенести в screen процесс, который вы запустили по ошибке в обычной SSH-сессии.  
	
	vagrant@vagrant:$ cat /dev/random > /dev/null  
	в другом терминале   
	vagrant@vagrant:$ ps aux| grep cat  
	vagrant     2097  0.0  0.0   8220   592 pts/0    S    14:56   0:00 cat /dev/random  
	vagrant@vagrant:$screen  
	vagrant@vagrant:$ sudo bash  
	root@vagrant:/home/vagrant# echo 0 > /proc/sys/kernel/yama/ptrace_scope  
	root@vagrant:/home/vagrant# exit  
	vagrant@vagrant:$ reptyr 2097  
	
14. sudo echo string > /root/new_file не даст выполнить перенаправление под обычным пользователем, так как перенаправлением занимается процесс shell'а, который запущен без sudo под вашим пользователем. Для решения данной проблемы можно использовать конструкцию echo string | sudo tee /root/new_file. Узнайте что делает команда tee и почему в отличие от sudo echo команда с sudo tee будет работать.  
	tee - читает stdin и записывает в файл    
	vagrant@vagrant:$ echo string | sudo tee /root/new_file  
	string  
	vagrant@vagrant:$ sudo cat /root/new_file  
	string  
	Работать будет потомучто tee вызывается через sudo и имеет права на запись , а оболочка bash из под обычного пользователя с его правами  






















