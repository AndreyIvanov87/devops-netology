# Домашнее задание к занятию "09.06 Gitlab"

## Подготовка к выполнению

1. Необходимо [зарегистрироваться](https://about.gitlab.com/free-trial/)
2. Создайте свой новый проект
3. Создайте новый репозиторий в gitlab, наполните его [файлами](./repository)
4. Проект должен быть публичным, остальные настройки по желанию

```bash
vagrant@server3:~$ docker pull gitlab/gitlab-runner:latest
latest: Pulling from gitlab/gitlab-runner
d5fd17ec1767: Pull complete 
b72ae3311b2d: Pull complete 
8321a833c290: Pull complete 
Digest: sha256:0f8ee21c2ef77d5ffacdb8343c709ab7945c1760b492f8e0877973630a5d935f
Status: Downloaded newer image for gitlab/gitlab-runner:latest
docker.io/gitlab/gitlab-runner:latest
vagrant@server3:~$ mkdir gitlab-runner
vagrant@server3:~$ docker run --rm -it --net host --name gitlab-runner --privileged -v ~/gitlab-runner:/etc/gitlab-runner -v /var/run/docker.sock:/var/run/docker.sock gitlab/gitlab-runner:latest register
vagrant@server3:~$ docker run --rm -it --net host --name gitlab-runner --privileged -v ~/gitlab-runner:/etc/gitlab-runner -v /var/run/docker.sock:/var/run/docker.sock gitlab/gitlab-runner:latest
vagrant@server3:~$ sudo cat gitlab-runner/config.toml 
concurrent = 1
check_interval = 0

[session_server]
  session_timeout = 1800

[[runners]]
  name = "server3"
  url = "https://gitlab.com/"
  token = "*****************"
  executor = "docker"
  [runners.custom_build_dir]
  [runners.cache]
    [runners.cache.s3]
    [runners.cache.gcs]
    [runners.cache.azure]
  [runners.docker]
    tls_verify = false
    image = "docker:latest"
    privileged = false
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    volumes = ["/var/run/docker.sock:/var/run/docker.sock", "/cache"]
    shm_size = 0
```
## Основная часть

### DevOps

В репозитории содержится код проекта на python. Проект - RESTful API сервис. Ваша задача автоматизировать сборку образа с выполнением python-скрипта:
1. Образ собирается на основе [centos:7](https://hub.docker.com/_/centos?tab=tags&page=1&ordering=last_updated)
2. Python версии не ниже 3.7
3. Установлены зависимости: `flask` `flask-jsonpify` `flask-restful`
4. Создана директория `/python_api`
5. Скрипт из репозитория размещён в /python_api
6. Точка вызова: запуск скрипта
7. Если сборка происходит на ветке `master`: Образ должен пушится в docker registry вашего gitlab `python-api:latest`, иначе этот шаг нужно пропустить  
Конфиг пайплайна:   
```bash 
docker-build:
  # Use the official docker image.
  image: docker:latest
  variables:
    CI_REGISTRY: registry.gitlab.com
  stage: build
  services:
    - name: "docker:dind"
      command: ['--tls=false', '--host=tcp://0.0.0.0:2375']
  before_script:
    - echo "$CI_REGISTRY_USER" "$CI_REGISTRY_PASSWORD" $CI_REGISTRY
    - docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" $CI_REGISTRY
  # Default branch leaves tag empty (= latest tag)
  # All other branches are tagged with the escaped branch name (commit ref slug)
  script:
    - |
      if [[ "$CI_COMMIT_BRANCH" == "$CI_DEFAULT_BRANCH" ]]; then
        tag=""
        echo "Running on default branch '$CI_DEFAULT_BRANCH': tag = 'latest'"
      else
        tag=":$CI_COMMIT_REF_SLUG"
        echo "Running on branch '$CI_COMMIT_BRANCH': tag = $tag"
      fi
    - docker build --pull -t "$CI_REGISTRY_IMAGE${tag}" .
    - docker push "$CI_REGISTRY_IMAGE${tag}"
  # Run this job in a branch where a Dockerfile exists
  rules:
    - if: $CI_COMMIT_BRANCH
      exists:
        - Dockerfile
```
Докер-файл:  
```bash
FROM centos:centos7
RUN yum -y update; 
RUN yum install -y gcc openssl-devel bzip2-devel libffi-devel zlib-devel xz-devel wget make
RUN cd /usr/src; wget https://www.python.org/ftp/python/3.7.11/Python-3.7.11.tgz ; tar xzf Python-3.7.11.tgz; cd Python-3.7.11; \
    ./configure --enable-optimizations && make altinstall 
RUN /usr/local/bin/python3.7 -m pip install --upgrade pip
RUN /usr/local/bin/python3.7 -m pip install flask flask-jsonpify flask-restful

COPY python-api.py /opt/api/python-api.py

CMD ["python3.7","/opt/api/python-api.py"]
#CMD /bin/sh
```

Тестирование:  
Вывод job на гитлабе:
```bash
Step 8/8 : CMD ["python3.7","/opt/api/python-api.py"]
 ---> Running in bd3870cea56a
Removing intermediate container bd3870cea56a
 ---> b3ad0b340f23
Successfully built b3ad0b340f23
Successfully tagged registry.gitlab.com/andreyivanov871/09-ci-06-gitlab:latest
$ docker push "$CI_REGISTRY_IMAGE${tag}"
Using default tag: latest
The push refers to repository [registry.gitlab.com/andreyivanov871/09-ci-06-gitlab]
056b847768f4: Preparing
..................................
fbddcb8b0bfd: Layer already exists
174f56854903: Layer already exists
latest: digest: sha256:574e0523d14dc567708af583d96c9414604d992f5a2e079bcc629f92972e0783 size: 1796
Cleaning up project directory and file based variables 00:00
Job succeeded
```

Запуск образа:  
```bash
agrant@server3:~$ docker pull registry.gitlab.com/andreyivanov871/09-ci-06-gitlab:latest
latest: Pulling from andreyivanov871/09-ci-06-gitlab
Digest: sha256:574e0523d14dc567708af583d96c9414604d992f5a2e079bcc629f92972e0783
Status: Image is up to date for registry.gitlab.com/andreyivanov871/09-ci-06-gitlab:latest
registry.gitlab.com/andreyivanov871/09-ci-06-gitlab:latest
vagrant@server3:~$ docker run --rm -it registry.gitlab.com/andreyivanov871/09-ci-06-gitlab:latest 
 * Serving Flask app 'python-api' (lazy loading)
 * Environment: production
   WARNING: This is a development server. Do not use it in a production deployment.
   Use a production WSGI server instead.
 * Debug mode: off
 * Running on all addresses (0.0.0.0)
   WARNING: This is a development server. Do not use it in a production deployment.
 * Running on http://127.0.0.1:5290
 * Running on http://172.17.0.2:5290 (Press CTRL+C to quit)
172.17.0.1 - - [25/May/2022 09:54:12] "GET / HTTP/1.1" 404 -
172.17.0.1 - - [25/May/2022 09:54:34] "GET /get_info HTTP/1.1" 200 -
```
Тест api:  
```bash
vagrant@server3:~$ curl http://172.17.0.2:5290/get_info
{"version": 3, "method": "GET", "message": "Already started"}
```


### Product Owner

Вашему проекту нужна бизнесовая доработка: необходимо поменять JSON ответа на вызов метода GET `/rest/api/get_info`, необходимо создать Issue в котором указать:
1. Какой метод необходимо исправить
2. Текст с `{ "message": "Already started" }` на `{ "message": "Running"}`
3. Issue поставить label: feature  
https://gitlab.com/andreyivanov871/09-ci-06-gitlab/-/issues/1

### Developer

Вам пришел новый Issue на доработку, вам необходимо:
1. Создать отдельную ветку, связанную с этим issue
2. Внести изменения по тексту из задания
3. Подготовить Merge Requst, влить необходимые изменения в `master`, проверить, что сборка прошла успешно


### Tester
Разработчики выполнили новый Issue, необходимо проверить валидность изменений:
1. Поднять докер-контейнер с образом `python-api:latest` и проверить возврат метода на корректность
2. Закрыть Issue с комментарием об успешности прохождения, указав желаемый результат и фактически достигнутый

```bash
vagrant@server3:~$ docker pull registry.gitlab.com/andreyivanov871/09-ci-06-gitlab:latest
latest: Pulling from andreyivanov871/09-ci-06-gitlab
Digest: sha256:4947f4c38966ef610f748baf540474b944e3c198e6c9a2192f946c30e5e0b81d
Status: Image is up to date for registry.gitlab.com/andreyivanov871/09-ci-06-gitlab:latest
registry.gitlab.com/andreyivanov871/09-ci-06-gitlab:latest
vagrant@server3:~$ docker run --rm -it registry.gitlab.com/andreyivanov871/09-ci-06-gitlab:latest 
 * Serving Flask app 'python-api' (lazy loading)
 * Environment: production
   WARNING: This is a development server. Do not use it in a production deployment.
   Use a production WSGI server instead.
 * Debug mode: off
 * Running on all addresses (0.0.0.0)
   WARNING: This is a development server. Do not use it in a production deployment.
 * Running on http://127.0.0.1:5290
 * Running on http://172.17.0.2:5290 (Press CTRL+C to quit)
vagrant@server3:~$ curl http://172.17.0.2:5290/get_info
{"version": 3, "method": "GET", "message": "Running"}
```


## Итог

После успешного прохождения всех ролей - отправьте ссылку на ваш проект в гитлаб, как решение домашнего задания

https://gitlab.com/andreyivanov871/09-ci-06-gitlab/

## Необязательная часть

Автомазируйте работу тестировщика, пусть у вас будет отдельный конвейер, который автоматически поднимает контейнер и выполняет проверку, например, при помощи curl. На основе вывода - будет приниматься решение об успешности прохождения тестирования

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
