Домашнее задание к занятию "3.3. Операционные системы, лекция 1"

1.    Какой системный вызов делает команда cd? В прошлом ДЗ мы выяснили, что cd не является самостоятельной программой, это shell builtin, поэтому запустить strace непосредственно на cd не получится. Тем не менее, вы можете запустить strace на /bin/bash -c 'cd /tmp'. В этом случае вы увидите полный список системных вызовов, которые делает сам bash при старте. Вам нужно найти тот единственный, который относится именно к cd. Обратите внимание, что strace выдаёт результат своей работы в поток stderr, а не в stdout.  
	chdir("/tmp")                           = 0  


2.    Попробуйте использовать команду file на объекты разных типов на файловой системе. Например:  

    vagrant@netology1:~$ file /dev/tty  
    /dev/tty: character special (5/0)  
    vagrant@netology1:~$ file /dev/sda  
    /dev/sda: block special (8/0)  
    vagrant@netology1:~$ file /bin/bash  
    /bin/bash: ELF 64-bit LSB shared object, x86-64  
  
    Используя strace выясните, где находится база данных file на основании которой она делает свои догадки.   
	openat(AT_FDCWD, "/usr/share/misc/magic.mgc", O_RDONLY) = 3  
ivanov@lusankiya:/usr/lib/file$ ls -alh /usr/share/misc/magic.mgc   
lrwxrwxrwx 1 root root 24 окт 27 14:02 /usr/share/misc/magic.mgc -> ../../lib/file/magic.mgc  
В убунте у меня оно тут в итоге:  
ivanov@lusankiya:/usr/lib/file$ file  /usr/lib/file/magic.mgc  
/usr/lib/file/magic.mgc: magic binary file for file(1) cmd (version 14) (little endian)  


3.    Предположим, приложение пишет лог в текстовый файл. Этот файл оказался удален (deleted в lsof), однако возможности сигналом сказать приложению переоткрыть файлы или просто перезапустить приложение – нет. Так как приложение продолжает писать в удаленный файл, место на диске постепенно заканчивается. Основываясь на знаниях о перенаправлении потоков предложите способ обнуления открытого удаленного файла (чтобы освободить место на файловой системе).

vagrant@vagrant:/proc/3077/fd$ echo 'some data' > /tmp/do_not_delete_me  
vagrant@vagrant:/proc/3077/fd$ python3 -c "import time; f=open('/tmp/do_not_delete_me','r') ; time.sleep(6000);" &  
[1] 3308  
vagrant@vagrant:/proc/3077/fd$ cat /tmp/do_not_delete_me  
some data  
vagrant@vagrant:/proc/3077/fd$ lsof -p 3308 | grep /tmp/do_not_delete_me  
python3 3308 vagrant    3r   REG  253,0       10 3670033 /tmp/do_not_delete_me  
vagrant@vagrant:/proc/3077/fd$ rm /tmp/do_not_delete_me  
vagrant@vagrant:/proc/3077/fd$ lsof -p 3308 | grep /tmp/do_not_delete_me  
python3 3308 vagrant    3r   REG  253,0       10 3670033 /tmp/do_not_delete_me (deleted)  
vagrant@vagrant:/proc/3077/fd$ cat /tmp/do_not_delete_me  
cat: /tmp/do_not_delete_me: No such file or directory  
vagrant@vagrant:/proc/3077/fd$ cat /proc/3308/fd/3   
some data  
vagrant@vagrant:/proc/3077/fd$ echo '' > /proc/3308/fd/3   
vagrant@vagrant:/proc/3077/fd$ cat /proc/3308/fd/3   
  
vagrant@vagrant:/proc/3077/fd$   


4.    Занимают ли зомби-процессы какие-то ресурсы в ОС (CPU, RAM, IO)?
	Нет. При завершении он освобождает все свои ресурсы и становится «зомби» — пустой записью в таблице процессов, хранящей статус завершения, предназначенный для чтения родительским процессом.   
5.    В iovisor BCC есть утилита opensnoop:  
  
    root@vagrant:~# dpkg -L bpfcc-tools | grep sbin/opensnoop  
    /usr/sbin/opensnoop-bpfcc  
  
    На какие файлы вы увидели вызовы группы open за первую секунду работы утилиты? Воспользуйтесь пакетом bpfcc-tools для Ubuntu 20.04. Дополнительные сведения по установке.  
	strace -tt  -e trace=openat -o/tmp/open-simple.log  opensnoop-bpfcc  
vagrant@vagrant:~$ head /tmp/open-simple.log  
17:17:55.427553 openat(AT_FDCWD, "/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3  
17:17:55.428611 openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libc.so.6", O_RDONLY|O_CLOEXEC) = 3  
17:17:55.432318 openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libpthread.so.0", O_RDONLY|O_CLOEXEC) = 3  
17:17:55.434773 openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libdl.so.2", O_RDONLY|O_CLOEXEC) = 3   
17:17:55.436050 openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libutil.so.1", O_RDONLY|O_CLOEXEC) = 3  
17:17:55.437467 openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libm.so.6", O_RDONLY|O_CLOEXEC) = 3  
17:17:55.438932 openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libexpat.so.1", O_RDONLY|O_CLOEXEC) = 3  
17:17:55.440159 openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libz.so.1", O_RDONLY|O_CLOEXEC) = 3  
17:17:55.444499 openat(AT_FDCWD, "/usr/lib/locale/locale-archive", O_RDONLY|O_CLOEXEC) = 3  
17:17:55.444961 openat(AT_FDCWD, "/usr/lib/x86_64-linux-gnu/gconv/gconv-modules.cache", O_RDONLY) = 3  

vagrant@vagrant:~$ grep -c openat  /tmp/open-simple.log  
2137  

------------>>>>>>>>>>>>>>>>Доработанное задание  
vagrant@vagrant:~$ sudo  opensnoop-bpfcc -d 1  
PID    COMM               FD ERR PATH  
785    vminfo              4   0 /var/run/utmp  
609    dbus-daemon        -1   2 /usr/local/share/dbus-1/system-services  
609    dbus-daemon        18   0 /usr/share/dbus-1/system-services  
609    dbus-daemon        -1   2 /lib/dbus-1/system-services  
609    dbus-daemon        18   0 /var/lib/snapd/dbus-1/system-services/  
  
	

6.    Какой системный вызов использует uname -a? Приведите цитату из man по этому системному вызову, где описывается альтернативное местоположение в /proc, где можно узнать версию ядра и релиз ОС.    
 используется uname()  
       Part of the utsname information is also accessible via /proc/sys/kernel/{ostype, hostname, osrelease, version, domainname}.  

7.    Чем отличается последовательность команд через ; и через && в bash? Например:  
  
    root@netology1:~# test -d /tmp/some_dir; echo Hi  
    Hi  
    root@netology1:~# test -d /tmp/some_dir && echo Hi  
    root@netology1:~#  
  
   Через ; команды выполнятся обе одна за другой, назависимо от результата выполнения первой.   
   Через && вторая команда выполнится только если первая отработает без ошибок (exit code = 0)  
set  -e  Exit immediately if a command exits with a non-zero status.  
    Есть ли смысл использовать в bash &&, если применить set -e?  
	смысла нет, если первая команда выйдет с ошибкой , будет завершена оболочка и вторая команда не выполнится.

8.    Из каких опций состоит режим bash set -euxo pipefail и почему его хорошо было бы использовать в сценариях?  
    -e  Exit immediately if a command exits with a non-zero status.  
    -u      Treat unset variables and parameters other than the special parameters "@" and "*" as an error when performing parameter expansion.  If expansion is attempted on an unset variable or parameter, the shell prints  an  error  message, and, if not interactive, exits with a non-zero status.  
    -x      After expanding each simple command, for command, case command, select command, or arithmetic for command, display the expanded value of PS4, followed by the command and its expanded arguments or associated word list.  
    -o	pipefail  
         If  set,  the  return value of a pipeline is the value of the last (rightmost) command to exit with a non-zero status, or zero if all commands in the pipeline exit successfully.  This option is  disabled  by  de‐fault.  
  
	Такой набор опций обеспечивает вылет скрипта с ошибкой если: какая-то команда в скрипте вернула не нулевой статус работы (то есть завершилась с ошибкой), какая-то переменная не задана. Обеспечивает подробный вывод итераций циклов и не теряет код ошибки, если идет несколько команд через pipe (по уполчанию такая последовательность выдаст exit code последней команды в pipe , то есть ошибка в первой может потеряться).      



9.    Используя -o stat для ps, определите, какой наиболее часто встречающийся статус у процессов в системе. В man ps ознакомьтесь (/PROCESS STATE CODES) что значат дополнительные к основной заглавной буквы статуса процессов. Его можно не учитывать при расчете (считать S, Ss или Ssl равнозначными).  
vagrant@vagrant:~$ ps ax -o stat | sort | uniq -c | sort -g  
      1 R+  
      1 Sl  
      1 SLsl  
      1 S<s  
      1 Ss+  
      1 STAT  
      2 SN  
      4 S+  
      4 Ssl  
     10 I  
     16 Ss  
     26 S  
     40 I<  
	Чаще всего процессы в статусе S - interruptible sleep (waiting for an event to complete). Прерываемый сон.   
Дополнительные буквы статуса  
 For BSD formats and when the stat keyword is used, additional characters may be displayed:  
               <    high-priority (not nice to other users)  
               N    low-priority (nice to other users)  
               L    has pages locked into memory (for real-time and custom IO)  
               s    is a session leader  
               l    is multi-threaded (using CLONE_THREAD, like NPTL pthreads do)  
               +    is in the foreground process group  


