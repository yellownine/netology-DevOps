# Домашнее задание к занятию "5.2. Применение принципов IaaC в работе с виртуальными машинами"

Q1:
- Опишите своими словами основные преимущества применения на практике IaaC паттернов.  
A1.1:
  - IaaC-паттерн позволяет ускорить практически все этапы цикла производства программного продукта: создать среду для песочницы, создать среду для тестирования (разные среды и еще и разное тестирование), доставить новую версию пользователям.
  - Можно избежать (минимизировать) дрейфа конфигурации и влияния этого явления на работу системы, т.е. повысить стабильность. Инвми словами - высокая повторяемость, о чем ниже.
- Какой из принципов IaaC является основополагающим?  
A1.2:
  - Собственно `идемпотентность` - способность повторять результат много раз, т.е. создавать одинаковое окружение/среду в большом количестве в разных местах.


Q2:
- Чем Ansible выгодно отличается от других систем управление конфигурациями?  
A2.1:
  - основывается на имеющемся практически везде SSH, т.е. не требует настройки дополнительного защищенного канала связи с ВМ
  - использует декларативный метод описания конфигурации => простота и наглядность (явное лучше, чем неявное:)
  - большое количество встроенных модулей, легкое подключение кастомных модулей, что позволяет выполнять широкий круг задач по настройке среды.
- Какой, на ваш взгляд, метод работы систем конфигурации более надёжный push или pull?  
A2.2:
  - хм... я бы выбрал push:
    - инициировать настройку лучше со стороны администратора, чем администрируемого - так больше контроля, мало ли чем там будет жить и дышать софт на ВМ.
    - при желании можно добавить гибкости, подложив в ВМ какой-нибудь надежный скрипт, реализующий обращение к администратору с целью поправить конфиг.
    - как я понял (просто промоделировал кейс), pull - это больше для autoscaling.

Q3:  
Установить на личный компьютер:

- VirtualBox
A3.1:  
```bash
leonid@mac ~ % vboxmanage --version
6.1.28r147628
```
- Vagrant
A3.2:
```bash
leonid@mac ~ % vagrant --version
Vagrant 2.2.19
```
- Ansible
A3.3:
```bash
leonid@mac ~ % ansible --version
ansible [core 2.12.1]
  config file = None
  configured module search path = ['/Users/leonid/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/local/Cellar/ansible/5.2.0/libexec/lib/python3.10/site-packages/ansible
  ansible collection location = /Users/leonid/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/local/bin/ansible
  python version = 3.10.1 (main, Dec  6 2021, 23:20:29) [Clang 13.0.0 (clang-1300.0.29.3)]
  jinja version = 3.0.3
  libyaml = True
```

Q4:
- Создать виртуальную машину.  
A4.1: ну тут какя понимаю IaaC все делается на одном дыхании
  - посмотрел в содержимое файлов Vagrantfile, inventory и provision.yml
  - повторил с некоторыми переименованиями и не стал разбивать файлы по директориям
  - не стал генерировать отдельные ключи ssh для работы с ВМ (получил одну проигнорированную ошибку)
- Зайти внутрь ВМ, убедиться, что Docker установлен с помощью команды docker ps   
A4.2:
```bash
vagrant@server:~$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```