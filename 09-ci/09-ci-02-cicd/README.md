# Домашнее задание к занятию "09.02 CI\CD"

## Знакомоство с SonarQube

### Подготовка к выполнению

1. Выполняем `docker pull sonarqube:8.7-community`
2. Выполняем `docker run -d --name sonarqube -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true -p 9000:9000 sonarqube:8.7-community`
3. Ждём запуск, смотрим логи через `docker logs -f sonarqube`
4. Проверяем готовность сервиса через [браузер](http://localhost:9000)
5. Заходим под admin\admin, меняем пароль на свой

```bash
docker run -d --name sonarqube -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true  --net host  --rm --oom-kill-disable sonarqube:8.7-community
```
В целом, в [этой статье](https://docs.sonarqube.org/latest/setup/install-server/) описаны все варианты установки, включая и docker, но так как нам он нужен разово, то достаточно того набора действий, который я указал выше.

### Основная часть

1. Создаём новый проект, название произвольное
2. Скачиваем пакет sonar-scanner, который нам предлагает скачать сам sonarqube
```bash
vagrant@server3:~$ wget -4  https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.7.0.2747.zip
vagrant@server3:~$ sudo apt-get install unzip
vagrant@server3:~$ unzip sonar-scanner-cli-4.7.0.2747.zip 
vagrant@server3:~/sonar-scanner-4.7.0.2747/bin$ PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/home/vagrant/sonar-scanner-4.7.0.2747/bin'
```	
3. Делаем так, чтобы binary был доступен через вызов в shell (или меняем переменную PATH или любой другой удобный вам способ)
4. Проверяем `sonar-scanner --version`
```bash
vagrant@server3:~/sonar-scanner-4.7.0.2747/bin$ sudo apt-get install openjdk-17-jre
vagrant@server3:~/sonar-scanner-4.7.0.2747$ cd ~/example/
vagrant@server3:~/example$ sonar-scanner -v
INFO: Scanner configuration file: /home/vagrant/sonar-scanner-4.7.0.2747/conf/sonar-scanner.properties
INFO: Project root configuration file: NONE
INFO: SonarScanner 4.7.0.2747
INFO: Java 17.0.3 Private Build (64-bit)
INFO: Linux 5.4.0-80-generic amd64
```
5. Запускаем анализатор против кода из директории [example](./example) с дополнительным ключом `-Dsonar.coverage.exclusions=fail.py`
```bash
vagrant@server3:~/example$ sonar-scanner   -Dsonar.projectKey=netology   -Dsonar.sources=.   -Dsonar.host.url=http://192.168.1.153:9000   -Dsonar.login=f47001c9f3ac3db0250299b82066baa51564d934 -Dsonar.coverage.exclusions=fail.py
```
6. Смотрим результат в интерфейсе
7. Исправляем ошибки, которые он выявил(включая warnings)
8. Запускаем анализатор повторно - проверяем, что QG пройдены успешно
9. Делаем скриншот успешного прохождения анализа, прикладываем к решению ДЗ  
https://github.com/AndreyIvanov87/devops-netology/blob/main/09-ci/09-ci-02-cicd/sonarqube-fixed.png


## Знакомство с Nexus

### Подготовка к выполнению

1. Выполняем `docker pull sonatype/nexus3`
2. Выполняем `docker run -d -p 8081:8081 --name nexus sonatype/nexus3`
3. Ждём запуск, смотрим логи через `docker logs -f nexus`
```bash
vagrant@server3:~$ docker pull sonatype/nexus3
vagrant@server3:~$ docker run -d --net host --name nexus sonatype/nexus3
123019b9fd40f2d0c9abad8b43f2173c8432ee766b3381a605a5b211dca8cb0c
vagrant@server3:~$ docker ps
CONTAINER ID   IMAGE                     COMMAND                  CREATED         STATUS         PORTS     NAMES
123019b9fd40   sonatype/nexus3           "sh -c ${SONATYPE_DI…"   6 seconds ago   Up 6 seconds             nexus
4fa90ccb3676   sonarqube:8.7-community   "bin/run.sh bin/sona…"   5 minutes ago   Up 5 minutes             sonarqube
vagrant@server3:~$ docker exec -it nexus /bin/bash
bash-4.4$ cat nexus-data/admin.password 
```
4. Проверяем готовность сервиса через [бразуер](http://localhost:8081)
5. Узнаём пароль от admin через `docker exec -it nexus /bin/bash`
6. Подключаемся под админом, меняем пароль, сохраняем анонимный доступ

### Основная часть

1. В репозиторий `maven-public` загружаем артефакт с GAV параметрами:
   1. groupId: netology
   2. artifactId: java
   3. version: 8_282
   4. classifier: distrib
   5. type: tar.gz
2. В него же загружаем такой же артефакт, но с version: 8_102
3. Проверяем, что все файлы загрузились успешно
4. В ответе присылаем файл `maven-metadata.xml` для этого артефекта
  
http://192.168.1.153:8081/repository/maven-public/netology/java/maven-metadata.xml  
  
	<?xml version="1.0" encoding="UTF-8"?>  
	<metadata modelVersion="1.1.0">  
	  <groupId>netology</groupId>  
	  <artifactId>java</artifactId>  
	  <versioning>  
	    <latest>8_282</latest>  
	    <release>8_282</release>  
	    <versions>  
	      <version>8_102</version>  
	      <version>8_282</version>  
	    </versions>  
	    <lastUpdated>20220518114400</lastUpdated>  
	  </versioning>  
	</metadata>  
  

### Знакомство с Maven

### Подготовка к выполнению

1. Скачиваем дистрибутив с [maven](https://maven.apache.org/download.cgi)
2. Разархивируем, делаем так, чтобы binary был доступен через вызов в shell (или меняем переменную PATH или любой другой удобный вам способ)
3. Проверяем `mvn --version`
4. Забираем директорию [mvn](./mvn) с pom
```bash
vagrant@server3:~$ wget -4 https://dlcdn.apache.org/maven/maven-3/3.8.5/binaries/apache-maven-3.8.5-bin.zip
vagrant@server3:~$ unzip apache-maven-3.8.5-bin.zip 
Archive:  apache-maven-3.8.5-bin.zip
   creating: apache-maven-3.8.5/
vagrant@server3:~/apache-maven-3.8.5/bin$ PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/home/vagrant/sonar-scanner-4.7.0.2747/bin:/home/vagrant/apache-maven-3.8.5/bin'
vagrant@server3:~/apache-maven-3.8.5/bin$ cd
vagrant@server3:~$ mvn --version
Apache Maven 3.8.5 (3599d3414f046de2324203b78ddcf9b5e4388aa0)
Maven home: /home/vagrant/apache-maven-3.8.5
Java version: 17.0.3, vendor: Private Build, runtime: /usr/lib/jvm/java-17-openjdk-amd64
Default locale: en_US, platform encoding: UTF-8
OS name: "linux", version: "5.4.0-80-generic", arch: "amd64", family: "unix"
```

### Основная часть

1. Меняем в `pom.xml` блок с зависимостями под наш артефакт из первого пункта задания для Nexus (java с версией 8_282)
2. Запускаем команду `mvn package` в директории с `pom.xml`, ожидаем успешного окончания
3. Проверяем директорию `~/.m2/repository/`, находим наш артефакт
4. В ответе присылаем исправленный файл `pom.xml`

```bash
vagrant@server3:~/mvn$ pwd
/home/vagrant/mvn
vagrant@server3:~/mvn$ ls
pom.xml  pom.xml-orig
vagrant@server3:~/mvn$ mvn package
[INFO] Scanning for projects...
[INFO] 
[INFO] --------------------< com.netology.app:simple-app >---------------------
[INFO] Building simple-app 1.0-SNAPSHOT
[INFO] --------------------------------[ jar ]---------------------------------
...............................
[INFO] Building jar: /home/vagrant/mvn/target/simple-app-1.0-SNAPSHOT.jar
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  18.944 s
[INFO] Finished at: 2022-05-18T13:31:13Z
[INFO] ------------------------------------------------------------------------
vagrant@server3:~/mvn$ find ~ -name *simple-app*
/home/vagrant/mvn/target/simple-app-1.0-SNAPSHOT.jar
vagrant@server3:~/mvn$ ls ~/.m2/repository/
backport-util-concurrent  com          commons-lang     junit  org
classworlds               commons-cli  commons-logging  log4j
vagrant@server3:~/mvn$ cat pom.xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
 
  <groupId>com.netology.app</groupId>
  <artifactId>simple-app</artifactId>
  <version>1.0-SNAPSHOT</version>
   <repositories>
    <repository>
      <id>my-repo</id>
      <name>maven-public</name>
      <url>http://localhost:8081/repository/maven-public/</url>
    </repository>
  </repositories>
  <dependencies>
<!--     <dependency>
      <groupId>netology</groupId>
      <artifactId>java</artifactId>
      <version>8_282</version>
      <classifier>distrib</classifier>
      <type>tar.gz</type>
    </dependency> -->
  </dependencies>
</project>
```

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
