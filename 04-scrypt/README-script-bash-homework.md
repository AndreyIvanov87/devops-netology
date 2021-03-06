### Как сдавать задания

Вы уже изучили блок «Системы управления версиями», и начиная с этого занятия все ваши работы будут приниматься ссылками на .md-файлы, размещённые в вашем публичном репозитории.

Скопируйте в свой .md-файл содержимое этого файла; исходники можно посмотреть [здесь](https://raw.githubusercontent.com/netology-code/sysadm-homeworks/devsys10/04-script-01-bash/README.md). Заполните недостающие части документа решением задач (заменяйте `???`, ОСТАЛЬНОЕ В ШАБЛОНЕ НЕ ТРОГАЙТЕ чтобы не сломать форматирование текста, подсветку синтаксиса и прочее, иначе можно отправиться на доработку) и отправляйте на проверку. Вместо логов можно вставить скриншоты по желани.

---

 
# Домашнее задание к занятию "4.1. Командная оболочка Bash: Практические навыки"

## Обязательная задача 1

Есть скрипт:
```bash
a=1
b=2
c=a+b
d=$a+$b
e=$(($a+$b))
```

Какие значения переменным c,d,e будут присвоены? Почему?

| Переменная  | Значение | Обоснование |
| ------------- | ------------- | ------------- |
| `c`  | a+b  | символы а, b, + баш воспримет как строки без подстановки значений переменных (перед именем переменной ставится $) |
| `d`  | 1+2  | Обращение к переменным будет, но их значение будет подставлено как строки и объединено в одну строку (+ тоже как символ, а не оператор)|
| `e`  | 3  | Значение переменных будет обработано как число и вычислен результат арифметической операции |


## Обязательная задача 2
На нашем локальном сервере упал сервис и мы написали скрипт, который постоянно проверяет его доступность, записывая дату проверок до тех пор, пока сервис не станет доступным (после чего скрипт должен завершиться). В скрипте допущена ошибка, из-за которой выполнение не может завершиться, при этом место на Жёстком Диске постоянно уменьшается. Что необходимо сделать, чтобы его исправить:
```bash
while ((1==1)
do
	curl https://localhost:4757
	if (($? != 0))
	then
		date >> curl.log
	fi
done
```
  
```bash
while ((1==1))
do
        curl http://localhost:4757
        if (($? != 0))
        then
                date > curl.log
	else 
		break
        fi
done
```

Необходимо написать скрипт, который проверяет доступность трёх IP: `192.168.0.1`, `173.194.222.113`, `87.250.250.242` по `80` порту и записывает результат в файл `log`. Проверять доступность необходимо пять раз для каждого узла.

### Ваш скрипт:
```bash
#!/usr/bin/env bash
a=5
i=1
echo > curl.log
while (($i <= $a))
	do
	echo $i
	ip_arr=(192.168.0.1 173.194.222.113 87.250.250.242)
	for ip in ${ip_arr[@]}
		do
		curl --connect-timeout 3 http://$ip
	        if (($? != 0))
	        then
	                echo "$i: $ip unavailable " >> curl.log
	        else 
	                echo "$i: $ip ok " >> curl.log
	        fi
		done

	sleep 2
	i=$(($i+1))
	done
```

___  
	root@vagrant:/tmp# cat /tmp/curl.log 
	
	1: 192.168.0.1 unavailable 
	1: 173.194.222.113 ok 
	1: 87.250.250.242 ok 
	2: 192.168.0.1 unavailable 
	2: 173.194.222.113 ok 
	2: 87.250.250.242 ok 
	3: 192.168.0.1 unavailable 
	3: 173.194.222.113 ok 
	3: 87.250.250.242 ok 
	4: 192.168.0.1 unavailable 
	4: 173.194.222.113 ok 
	4: 87.250.250.242 ok 
	5: 192.168.0.1 unavailable 
	5: 173.194.222.113 ok 
	5: 87.250.250.242 ok 
	
## Обязательная задача 3
Необходимо дописать скрипт из предыдущего задания так, чтобы он выполнялся до тех пор, пока один из узлов не окажется недоступным. Если любой из узлов недоступен - IP этого узла пишется в файл error, скрипт прерывается.

### Ваш скрипт:
```bash
#!/usr/bin/env bash
a=5
i=1
echo > curl.log
echo > error
while (( 1 == 1 ))
        do
        echo $i
        ip_arr=(173.194.222.113 87.250.250.242 192.168.0.1)
        for ip in ${ip_arr[@]}
                do
                curl --connect-timeout 3 http://$ip
                if (($? != 0))
                then
                        echo "$i: $ip unavailable " >> error
			exit 1
                else
                        echo "$i: $ip ok " >> curl.log
                fi
                done

        sleep 2
        i=$(($i+1))
        done

```
___  
	root@vagrant:/tmp# cat error curl.log 
	
	1: 192.168.0.1 unavailable 
	
	1: 173.194.222.113 ok 
	1: 87.250.250.242 ok 



## Дополнительное задание (со звездочкой*) - необязательно к выполнению

Мы хотим, чтобы у нас были красивые сообщения для коммитов в репозиторий. Для этого нужно написать локальный хук для git, который будет проверять, что сообщение в коммите содержит код текущего задания в квадратных скобках и количество символов в сообщении не превышает 30. Пример сообщения: \[04-script-01-bash\] сломал хук.

### Ваш скрипт:
```bash
???
```
