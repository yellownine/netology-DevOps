# Домашнее задание к занятию "6.5. Elasticsearch"

Q1: Используя докер образ centos:7 как базовый и документацию по установке и запуску Elastcisearch:

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте push в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути / c хост-машины  
Требования к elasticsearch.yml:

- данные path должны сохраняться в /var/lib
- имя ноды должно быть netology_test  
В ответе приведите:

Q1.1: текст Dockerfile манифеста  
**A1.1:**
```Dockerfile
FROM centos:7
RUN yum install wget -y
RUN yum install perl-Digest-SHA -y
RUN yum clean all
RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.1.0-linux-x86_64.tar.gz
RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.1.0-linux-x86_64.tar.gz.sha512
RUN shasum -a 512 -c elasticsearch-8.1.0-linux-x86_64.tar.gz.sha512
RUN tar -xzf elasticsearch-8.1.0-linux-x86_64.tar.gz
COPY elasticsearch.yml /elasticsearch-8.1.0/config/
RUN useradd elastic_user -p password
RUN chown elastic_user -R /elasticsearch-8.1.0; chown elastic_user -R /var/lib
USER elastic_user
CMD /elasticsearch-8.1.0/bin/elasticsearch
```
Содержимое elasticsearch.yml
```yml
cluster.name: es_cluster

node.name: netology_test

path.data: /var/lib/data

xpack.security.enabled: false

xpack.security.enrollment.enabled: false

xpack.security.http.ssl:
  enabled: false

xpack.security.transport.ssl:
  enabled: false

http.host: [_local_, _site_]
```
Команда для запуска сервиса
```bash
docker build -t centos_es8 . && docker run --name centos_es8_con -p 9200:9200 -itd centos_es8; docker logs --follow centos_es8_con
```

Q1.2: ссылку на образ в репозитории dockerhub  
**A1.2:** https://hub.docker.com/repository/docker/leonaronov/centos_es8

Q1.3: ответ elasticsearch на запрос пути / в json виде  
**A1.3:**
```json
{
  "name" : "netology_test",
  "cluster_name" : "es_cluster",
  "cluster_uuid" : "6iW6BtUcSIqdBzcIvlMEYw",
  "version" : {
    "number" : "8.1.0",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "3700f7679f7d95e36da0b43762189bab189bc53a",
    "build_date" : "2022-03-03T14:20:00.690422633Z",
    "build_snapshot" : false,
    "lucene_version" : "9.0.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
```

Подсказки:

возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
при некоторых проблемах вам поможет docker директива ulimit
elasticsearch в логах обычно описывает проблему и пути ее решения
Далее мы будем работать с данным экземпляром elasticsearch.

---
Q2:
В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html)
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

**A2.1:** Получил состояние индексов запросом `GET 127.0.0.1:9200/ind-1,ind-2,ind-3?expand_wildcards=all`
```json
{
    "ind-1": {
        "aliases": {},
        "mappings": {},
        "settings": {
            "index": {
                "routing": {
                    "allocation": {
                        "include": {
                            "_tier_preference": "data_content"
                        }
                    }
                },
                "number_of_shards": "1",
                "provided_name": "ind-1",
                "creation_date": "1648039781588",
                "number_of_replicas": "0",
                "uuid": "A7zywmF0QBOYG2fAhlDLyQ",
                "version": {
                    "created": "8010099"
                }
            }
        }
    },
    "ind-2": {
        "aliases": {},
        "mappings": {},
        "settings": {
            "index": {
                "routing": {
                    "allocation": {
                        "include": {
                            "_tier_preference": "data_content"
                        }
                    }
                },
                "number_of_shards": "2",
                "provided_name": "ind-2",
                "creation_date": "1648039797125",
                "number_of_replicas": "1",
                "uuid": "bjekwhmBT1GSg06cDWH7Rw",
                "version": {
                    "created": "8010099"
                }
            }
        }
    },
    "ind-3": {
        "aliases": {},
        "mappings": {},
        "settings": {
            "index": {
                "routing": {
                    "allocation": {
                        "include": {
                            "_tier_preference": "data_content"
                        }
                    }
                },
                "number_of_shards": "4",
                "provided_name": "ind-3",
                "creation_date": "1648039801160",
                "number_of_replicas": "2",
                "uuid": "H6cvN8onTgSV4V1d3MtqCA",
                "version": {
                    "created": "8010099"
                }
            }
        }
    }
}
```

Получите состояние кластера `elasticsearch`, используя API.

**A2.2:** Запросим состояние кластера с раскрытием на уровне индексов. Запрос `GET 127.0.0.1:9200/_cluster/health?level=indices`
```json
{
    "cluster_name": "es_cluster",
    "status": "yellow",
    "timed_out": false,
    "number_of_nodes": 1,
    "number_of_data_nodes": 1,
    "active_primary_shards": 8,
    "active_shards": 8,
    "relocating_shards": 0,
    "initializing_shards": 0,
    "unassigned_shards": 10,
    "delayed_unassigned_shards": 0,
    "number_of_pending_tasks": 0,
    "number_of_in_flight_fetch": 0,
    "task_max_waiting_in_queue_millis": 0,
    "active_shards_percent_as_number": 44.44444444444444,
    "indices": {
        ".geoip_databases": {
            "status": "green",
            "number_of_shards": 1,
            "number_of_replicas": 0,
            "active_primary_shards": 1,
            "active_shards": 1,
            "relocating_shards": 0,
            "initializing_shards": 0,
            "unassigned_shards": 0
        },
        "ind-1": {
            "status": "green",
            "number_of_shards": 1,
            "number_of_replicas": 0,
            "active_primary_shards": 1,
            "active_shards": 1,
            "relocating_shards": 0,
            "initializing_shards": 0,
            "unassigned_shards": 0
        },
        "ind-3": {
            "status": "yellow",
            "number_of_shards": 4,
            "number_of_replicas": 2,
            "active_primary_shards": 4,
            "active_shards": 4,
            "relocating_shards": 0,
            "initializing_shards": 0,
            "unassigned_shards": 8
        },
        "ind-2": {
            "status": "yellow",
            "number_of_shards": 2,
            "number_of_replicas": 1,
            "active_primary_shards": 2,
            "active_shards": 2,
            "relocating_shards": 0,
            "initializing_shards": 0,
            "unassigned_shards": 2
        }
    }
}
```
Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

**A2.3:** `ind-1` имеет 1 шард и он, безусловно, assigned. У `ind-2` и `ind-3` более 1 шарда и часть шардов (secondary) в состоянии unassigned.

Удалите все индексы.  
Запрос `DELETE 127.0.0.1:9200/ind-1,ind-2,ind-3?expand_wildcards=all`

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

---
Q3:
В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository)
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.  
**A3.1:**
- Запрос на создание репозитория  
`PUT 127.0.0.1:9200/_snapshot/netology_backup`
- Ответ на запрос
```json
{
    "acknowledged": true
}
```

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.  
**A3.2:** Список индексов  
```json
{
    "cluster_name": "es_cluster",
    "status": "yellow",
    "timed_out": false,
    "number_of_nodes": 1,
    "number_of_data_nodes": 1,
    "active_primary_shards": 9,
    "active_shards": 9,
    "relocating_shards": 0,
    "initializing_shards": 0,
    "unassigned_shards": 10,
    "delayed_unassigned_shards": 0,
    "number_of_pending_tasks": 0,
    "number_of_in_flight_fetch": 0,
    "task_max_waiting_in_queue_millis": 0,
    "active_shards_percent_as_number": 47.368421052631575,
    "indices": {
        ".geoip_databases": {
            "status": "green",
            "number_of_shards": 1,
            "number_of_replicas": 0,
            "active_primary_shards": 1,
            "active_shards": 1,
            "relocating_shards": 0,
            "initializing_shards": 0,
            "unassigned_shards": 0
        },
        "test": {
            "status": "green",
            "number_of_shards": 1,
            "number_of_replicas": 0,
            "active_primary_shards": 1,
            "active_shards": 1,
            "relocating_shards": 0,
            "initializing_shards": 0,
            "unassigned_shards": 0
        },
        "ind-1": {
            "status": "green",
            "number_of_shards": 1,
            "number_of_replicas": 0,
            "active_primary_shards": 1,
            "active_shards": 1,
            "relocating_shards": 0,
            "initializing_shards": 0,
            "unassigned_shards": 0
        },
        "ind-3": {
            "status": "yellow",
            "number_of_shards": 4,
            "number_of_replicas": 2,
            "active_primary_shards": 4,
            "active_shards": 4,
            "relocating_shards": 0,
            "initializing_shards": 0,
            "unassigned_shards": 8
        },
        "ind-2": {
            "status": "yellow",
            "number_of_shards": 2,
            "number_of_replicas": 1,
            "active_primary_shards": 2,
            "active_shards": 2,
            "relocating_shards": 0,
            "initializing_shards": 0,
            "unassigned_shards": 2
        }
    }
}
```

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html)
состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами.  
**A3.3:** Список файлов в директории snapshot-репозитория
```
-rw-r--r-- 1 elastic_user elastic_user 1.7K Mar 23 19:09 index-0
-rw-r--r-- 1 elastic_user elastic_user    8 Mar 23 19:09 index.latest
drwxr-xr-x 7 elastic_user elastic_user 4.0K Mar 23 19:09 indices
-rw-r--r-- 1 elastic_user elastic_user  18K Mar 23 19:09 meta-b-EOPTKLQPOB42CDH3KnCw.dat
-rw-r--r-- 1 elastic_user elastic_user  456 Mar 23 19:09 snap-b-EOPTKLQPOB42CDH3KnCw.dat
```

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.  
**A3.4:** Список индексов  
```json
{
    "cluster_name": "es_cluster",
    "status": "yellow",
    "timed_out": false,
    "number_of_nodes": 1,
    "number_of_data_nodes": 1,
    "active_primary_shards": 9,
    "active_shards": 9,
    "relocating_shards": 0,
    "initializing_shards": 0,
    "unassigned_shards": 10,
    "delayed_unassigned_shards": 0,
    "number_of_pending_tasks": 0,
    "number_of_in_flight_fetch": 0,
    "task_max_waiting_in_queue_millis": 0,
    "active_shards_percent_as_number": 47.368421052631575,
    "indices": {
        ".geoip_databases": {
            "status": "green",
            "number_of_shards": 1,
            "number_of_replicas": 0,
            "active_primary_shards": 1,
            "active_shards": 1,
            "relocating_shards": 0,
            "initializing_shards": 0,
            "unassigned_shards": 0
        },
        "test-2": {
            "status": "green",
            "number_of_shards": 1,
            "number_of_replicas": 0,
            "active_primary_shards": 1,
            "active_shards": 1,
            "relocating_shards": 0,
            "initializing_shards": 0,
            "unassigned_shards": 0
        },
        "ind-1": {
            "status": "green",
            "number_of_shards": 1,
            "number_of_replicas": 0,
            "active_primary_shards": 1,
            "active_shards": 1,
            "relocating_shards": 0,
            "initializing_shards": 0,
            "unassigned_shards": 0
        },
        "ind-3": {
            "status": "yellow",
            "number_of_shards": 4,
            "number_of_replicas": 2,
            "active_primary_shards": 4,
            "active_shards": 4,
            "relocating_shards": 0,
            "initializing_shards": 0,
            "unassigned_shards": 8
        },
        "ind-2": {
            "status": "yellow",
            "number_of_shards": 2,
            "number_of_replicas": 1,
            "active_primary_shards": 2,
            "active_shards": 2,
            "relocating_shards": 0,
            "initializing_shards": 0,
            "unassigned_shards": 2
        }
    }
}
```
[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее.

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.  
**A3.5:**
- Запрос на восстановление кластера  
`POST 127.0.0.1:9200/_snapshot/netology_backup/with_test_snapshot/_restore?wait_for_completion=true`  
body
```json
{
  "rename_pattern": "(.*)",
  "rename_replacement": "restored_index_$1"
}
```
- Список индексов
```json
{
    "cluster_name": "es_cluster",
    "status": "yellow",
    "timed_out": false,
    "number_of_nodes": 1,
    "number_of_data_nodes": 1,
    "active_primary_shards": 17,
    "active_shards": 17,
    "relocating_shards": 0,
    "initializing_shards": 0,
    "unassigned_shards": 20,
    "delayed_unassigned_shards": 0,
    "number_of_pending_tasks": 0,
    "number_of_in_flight_fetch": 0,
    "task_max_waiting_in_queue_millis": 0,
    "active_shards_percent_as_number": 45.94594594594595,
    "indices": {
        "test-2": {
            "status": "green",
            "number_of_shards": 1,
            "number_of_replicas": 0,
            "active_primary_shards": 1,
            "active_shards": 1,
            "relocating_shards": 0,
            "initializing_shards": 0,
            "unassigned_shards": 0
        },
        ".geoip_databases": {
            "status": "green",
            "number_of_shards": 1,
            "number_of_replicas": 0,
            "active_primary_shards": 1,
            "active_shards": 1,
            "relocating_shards": 0,
            "initializing_shards": 0,
            "unassigned_shards": 0
        },
        "restored_index_testrestored_index_": {
            "status": "green",
            "number_of_shards": 1,
            "number_of_replicas": 0,
            "active_primary_shards": 1,
            "active_shards": 1,
            "relocating_shards": 0,
            "initializing_shards": 0,
            "unassigned_shards": 0
        },
        "ind-1": {
            "status": "green",
            "number_of_shards": 1,
            "number_of_replicas": 0,
            "active_primary_shards": 1,
            "active_shards": 1,
            "relocating_shards": 0,
            "initializing_shards": 0,
            "unassigned_shards": 0
        },
        "restored_index_ind-1restored_index_": {
            "status": "green",
            "number_of_shards": 1,
            "number_of_replicas": 0,
            "active_primary_shards": 1,
            "active_shards": 1,
            "relocating_shards": 0,
            "initializing_shards": 0,
            "unassigned_shards": 0
        },
        "restored_index_ind-3restored_index_": {
            "status": "yellow",
            "number_of_shards": 4,
            "number_of_replicas": 2,
            "active_primary_shards": 4,
            "active_shards": 4,
            "relocating_shards": 0,
            "initializing_shards": 0,
            "unassigned_shards": 8
        },
        "ind-3": {
            "status": "yellow",
            "number_of_shards": 4,
            "number_of_replicas": 2,
            "active_primary_shards": 4,
            "active_shards": 4,
            "relocating_shards": 0,
            "initializing_shards": 0,
            "unassigned_shards": 8
        },
        "ind-2": {
            "status": "yellow",
            "number_of_shards": 2,
            "number_of_replicas": 1,
            "active_primary_shards": 2,
            "active_shards": 2,
            "relocating_shards": 0,
            "initializing_shards": 0,
            "unassigned_shards": 2
        },
        "restored_index_ind-2restored_index_": {
            "status": "yellow",
            "number_of_shards": 2,
            "number_of_replicas": 1,
            "active_primary_shards": 2,
            "active_shards": 2,
            "relocating_shards": 0,
            "initializing_shards": 0,
            "unassigned_shards": 2
        }
    }
}
```

Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`
