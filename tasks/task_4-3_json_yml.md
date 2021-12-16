### Как сдавать задания

Вы уже изучили блок «Системы управления версиями», и начиная с этого занятия все ваши работы будут приниматься ссылками на .md-файлы, размещённые в вашем публичном репозитории.

Скопируйте в свой .md-файл содержимое этого файла; исходники можно посмотреть [здесь](https://raw.githubusercontent.com/netology-code/sysadm-homeworks/devsys10/04-script-03-yaml/README.md). Заполните недостающие части документа решением задач (заменяйте `???`, ОСТАЛЬНОЕ В ШАБЛОНЕ НЕ ТРОГАЙТЕ чтобы не сломать форматирование текста, подсветку синтаксиса и прочее, иначе можно отправиться на доработку) и отправляйте на проверку. Вместо логов можно вставить скриншоты по желани.

# Домашнее задание к занятию "4.3. Языки разметки JSON и YAML"


## Обязательная задача 1
Мы выгрузили JSON, который получили через API запрос к нашему сервису:
```
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

A:
```json
{ "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 // с точки зрения формата json все хорошо, но здесь бы еще настроить jsonSchema, чтобы это поле имело формат, скажем IPv4
            },
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


import socket
import os
import json
import yaml

json_path = 'dns_data.json'
yml_path = 'dns_data.yaml'
dns_data_default = {'drive.google.com': 0, 'mail.google.com': 0, 'google.com': 0}

if os.path.exists(json_path):
    f_json = open(json_path, 'r')
    dns_data_last_json = json.load(f_json)
    f_json.close()
else:
    dns_data_last = dns_data_default

if os.path.exists(yml_path):
    f_yaml = open(yml_path, 'r')
    dns_data_last_yml = yaml.safe_load(f_yaml)
    f_yaml.close()
else:
    dns_data_last_yml = dns_data_default

dns_data_last = dns_data_last_json

urls_to_check = ['drive.google.com', 'mail.google.com', 'google.com']

for url_to_check in urls_to_check:
    ip = socket.gethostbyname(url_to_check)
    if dns_data_last[url_to_check] != ip:
        print(f'[ERROR] {url_to_check} IP mismatch: {dns_data_last[url_to_check]} {ip}')
    else:
        print(url_to_check + ' - ' + ip)
    dns_data_last[url_to_check] = ip

with open(json_path, "w") as f_json:
    json.dump(dns_data_last, f_json)
    f_json.close()

with open(yml_path, "w") as f_yaml:
    dns_data_for_yaml = []
    for url in dns_data_last:
        dns_data_for_yaml.append({url: dns_data_last[url]})
    yaml.dump(dns_data_for_yaml, f_yaml)
    f_yaml.close()
```

### Вывод скрипта при запуске при тестировании:
```
drive.google.com - 108.177.14.194
[ERROR] mail.google.com IP mismatch: 173.194.222.83 173.194.222.19
google.com - 173.194.222.101
```

### json-файл(ы), который(е) записал ваш скрипт:
```json
{"drive.google.com": "108.177.14.194", "mail.google.com": "173.194.222.19", "google.com": "173.194.222.101"}
```

### yml-файл(ы), который(е) записал ваш скрипт:
```yaml
- drive.google.com: 108.177.14.194
- mail.google.com: 173.194.222.19
- google.com: 173.194.222.101
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