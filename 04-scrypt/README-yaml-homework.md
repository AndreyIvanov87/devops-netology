### Как сдавать задания

Вы уже изучили блок «Системы управления версиями», и начиная с этого занятия все ваши работы будут приниматься ссылками на .md-файлы, размещённые в вашем публичном репозитории.

Скопируйте в свой .md-файл содержимое этого файла; исходники можно посмотреть [здесь](https://raw.githubusercontent.com/netology-code/sysadm-homeworks/devsys10/04-script-03-yaml/README.md). Заполните недостающие части документа решением задач (заменяйте `???`, ОСТАЛЬНОЕ В ШАБЛОНЕ НЕ ТРОГАЙТЕ чтобы не сломать форматирование текста, подсветку синтаксиса и прочее, иначе можно отправиться на доработку) и отправляйте на проверку. Вместо логов можно вставить скриншоты по желани.

# Домашнее задание к занятию "4.3. Языки разметки JSON и YAML"


## Обязательная задача 1
Мы выгрузили JSON, который получили через API запрос к нашему сервису:
```json
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            }
            { "name" : "second",
            "type" : "proxy",
            "ip : 71.78.22.43
            }
        ]
    }
```
  Нужно найти и исправить все ошибки, которые допускает наш сервис

```json
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : "7.1.7.5"
            }
            { "name" : "second",
            "type" : "proxy",
            "ip" : "71.78.22.43"
            }
        ]
    }
```


## Обязательная задача 2
В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису: `{ "имя сервиса" : "его IP"}`. Формат записи YAML по одному сервису: `- имя сервиса: его IP`. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import os
# import sys
import json
import yaml

dictglob = {}
f = open('/tmp/ip-log.txt', 'r')
for line in f:
	list1 = list(line.split(" "))
	dictglob[list1[0]] = list1[1]
f.close()
# print(dictglob)

f = open('/tmp/ip-log.txt', 'w')
fjson = open('/tmp/ip-log.json', 'w')
fyaml = open('/tmp/ip-log.yaml', 'w')
sitelist = ("drive.google.com", "mail.google.com", "google.com")
datayaml = []

for site in sitelist:
	bash_command = ("host "+site+"| grep  address| head -n 1  | awk '{print $4}'")
	# print(bash_command)
	result_os = os.popen(bash_command).read()	
	print("http://"+site, " - ", result_os)
	if (dictglob[site] != result_os):
		print("[ERROR]", "http://"+site, "IP mismatch:", dictglob[site], result_os)
	f.write(site+" "+result_os)

	data = {site: result_os.replace("\n", "")}
	json.dump(data, fjson)
	fjson.write('\n')
	datayaml.append({site: result_os.replace("\n", "")})


yaml.dump({"services": datayaml}, fyaml)

f.close()
fyaml.close()
fjson.close()

```

### Вывод скрипта при запуске при тестировании:
```
/usr/bin/python3.8 /home/ivanov/netology/devops-netology/python-test-4.py
http://drive.google.com  -  142.251.1.194

[ERROR] http://drive.google.com IP mismatch: 74.125.131.194
 142.251.1.194

http://mail.google.com  -  74.125.131.17

http://google.com  -  173.194.222.100


Process finished with exit code 0

```

### json-файл(ы), который(е) записал ваш скрипт:
```json
{"drive.google.com": "142.251.1.194"}
{"mail.google.com": "74.125.131.17"}
{"google.com": "173.194.222.100"}
```

### yml-файл(ы), который(е) записал ваш скрипт:
```yaml
services:
- drive.google.com: 142.251.1.194
- mail.google.com: 74.125.131.17
- google.com: 173.194.222.100
```

## Дополнительное задание (со звездочкой*) - необязательно к выполнению

Так как команды в нашей компании никак не могут прийти к единому мнению о том, какой формат разметки данных использовать: JSON или YAML, нам нужно реализовать парсер из одного формата в другой. Он должен уметь:
   * Принимать на вход имя файла
   * Проверять формат исходного файла. Если файл не json или yml - скрипт должен остановить свою работу
   * Распознавать какой формат данных в файле. Считается, что файлы *.json и *.yml могут быть перепутаны
   * Перекодировать данные из исходного формата во второй доступный (из JSON в YAML, из YAML в JSON)
   * При обнаружении ошибки в исходном файле - указать в стандартном выводе строку с ошибкой синтаксиса и её номер
   * Полученный файл должен иметь имя исходного файла, разница в наименовании обеспечивается разницей расширения файлов

### Ваш скрипт:
```python
???
```

### Пример работы скрипта:
???
