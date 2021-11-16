# devops-netology homework 2021-11-10
#Домашнее задание к занятию "3.1. Работа в терминале, лекция 1"  

  
......  

5. Ознакомьтесь с графическим интерфейсом VirtualBox, посмотрите как выглядит виртуальная машина, которую создал для вас Vagrant, какие аппаратные ресурсы ей выделены. Какие ресурсы выделены по-умолчанию?  
cpu 2x100%  
ram 1024G  
VBoxVGA 4M  
SATA disk 64G (динамически расширяемый)  
  
6. Ознакомьтесь с возможностями конфигурации VirtualBox через Vagrantfile: документация. Как добавить оперативной памяти или ресурсов процессора виртуальной машине?  

Добавить в файл конфигурации  виртуальной машины Vagrantfile нужные параметры (до запуска виртуальной машины) 
Vagrant.configure("2") do |config|  
 	config.vm.box = "bento/ubuntu-20.04"  
	config.vm.provider "virtualbox" do |v|  
	        v.memory = 2048	  
	        v.cpus = 2  
	end  
 end  	
  
Или в графическом окне virtualbox кнопка "настроить" - "система".  




8. Ознакомиться с разделами man bash, почитать о настройках самого bash:

    какой переменной можно задать длину журнала history, и на какой строчке manual это описывается?  
      HISTSIZE  
              The number of commands to remember in the command history (see HISTORY below).  If  the  value  is  0,  
              commands are not saved in the history list.  Numeric values less than zero result in every command be‐  
              ing saved on the history list (there is no limit).  The shell sets the  default  value  to  500  after  
              reading any startup files.  

	man bash > /tmp/test ; cat /tmp/test | grep -n HISTSIZE  
	864:       HISTSIZE  
	строка 864.  

    что делает директива ignoreboth в bash?  
	При таком значении $HISTCONTROL не сохранять в истории команды которые начинаются с пробела или повторяют прошлую команду   

9. В каких сценариях использования применимы скобки {} и на какой строчке man bash это описано?  
	последовательность команд в скобках должна заканчиваться ; и просто выполняется в текущем shell окружении  
	man bash > /tmp/test ; cat /tmp/test | grep -n '{ list; }'  
	строка 257:       { list; }  
10. С учётом ответа на предыдущий вопрос, как создать однократным вызовом touch 100000 файлов? Получится ли аналогичным образом создать 300000? Если нет, то почему?  
	{ list } может так же использоваться как агрумент цикла или функции  
	touch {000001..100000}.txt  
	300 000 не получится   
	-bash: /usr/bin/touch: Argument list too long  

11. В man bash поищите по /\[\[. Что делает конструкция [[ -d /tmp ]]  
	Вычисляет значение [[ логического выражения ]], возвращает 1 или 0  
	Оператор в задании возвращает true если такая директория существует  
	vagrant@vagrant:/tmp$ if [[ -d /tmp1 ]] ; then  echo 'yes'; else echo 'no' ;  fi   
	no  
	vagrant@vagrant:/tmp$ if [[ -d /tmp ]] ; then  echo 'yes'; else echo 'no' ;  fi   
	yes  

12. Основываясь на знаниях о просмотре текущих (например, PATH) и установке новых переменных; командах, которые мы рассматривали, добейтесь в выводе type -a bash в виртуальной машине наличия первым пунктом в списке:  
	vagrant@vagrant:/tmp$ mkdir /tmp/new_path_directory  
	vagrant@vagrant:/tmp$ cp /usr/bin/bash /tmp/new_path_directory  
	vagrant@vagrant:/tmp$ PATH="/tmp/new_path_directory:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"  
	vagrant@vagrant:/tmp$ type -a bash  
	bash is /tmp/new_path_directory/bash  
	bash is /usr/bin/bash  
	bash is /bin/bash  

13. Чем отличается планирование команд с помощью batch и at?  
	at выполняет команду в установленное время в любом случае, а batch если нагрузка на систему меньше 1.5 load average  







