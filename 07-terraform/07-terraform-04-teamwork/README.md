# Домашнее задание к занятию "7.4. Средства командной работы над инфраструктурой."

## Задача 1. Настроить terraform cloud (необязательно, но крайне желательно).

В это задании предлагается познакомиться со средством командой работы над инфраструктурой предоставляемым
разработчиками терраформа. 

1. Зарегистрируйтесь на [https://app.terraform.io/](https://app.terraform.io/).
(регистрация бесплатная и не требует использования платежных инструментов).
1. Создайте в своем github аккаунте (или другом хранилище репозиториев) отдельный репозиторий с
 конфигурационными файлами прошлых занятий (или воспользуйтесь любым простым конфигом).
1. Зарегистрируйте этот репозиторий в [https://app.terraform.io/](https://app.terraform.io/).
1. Выполните plan и apply. 

В качестве результата задания приложите снимок экрана с успешным применением конфигурации.  
https://github.com/AndreyIvanov87/devops-netology/blob/main/07-terraform/07-terraform-04-teamwork/app.terraform.io-success.png  

## Задача 2. Написать серверный конфиг для атлантиса. 

Смысл задания – познакомиться с документацией 
о [серверной](https://www.runatlantis.io/docs/server-side-repo-config.html) конфигурации и конфигурации уровня 
 [репозитория](https://www.runatlantis.io/docs/repo-level-atlantis-yaml.html).

Создай `server.yaml` который скажет атлантису:
1. Укажите, что атлантис должен работать только для репозиториев в вашем github (или любом другом) аккаунте.
1. На стороне клиентского конфига разрешите изменять `workflow`, то есть для каждого репозитория можно 
будет указать свои дополнительные команды. 
1. В `workflow` используемом по-умолчанию сделайте так, что бы во время планирования не происходил `lock` состояния.

```bash
root@host2:~# iptables -I INPUT 3 -p tcp  --dport 4141 -j ACCEPT
ivanov@host2:~$ wget https://github.com/runatlantis/atlantis/releases/download/v0.16.0/atlantis_linux_amd64.zip
root@host2:~# apt-get install unzip
ivanov@host2:~$ unzip atlantis_linux_amd64.zip 
ivanov@host2:~$ wget https://releases.hashicorp.com/terraform/0.14.5/terraform_0.14.5_linux_amd64.zip--2022-06-07 13:35:43--  https://releases.hashicorp.com/terraform/0.14.5/terraform_0.14.5_linux_amd64.zip
ivanov@host2:~$ ./atlantis server --gh-user fake --gh-token fake --repo-config=/home/ivanov/server.yaml --repo-allowlist='github.com/AndreyIvanov87/terraform-cloud' --atlantis-url http://78.24.223.17:4141/
```
go http://78.24.223.17:4141/github-app/setup  
Github app created successfully!  
https://www.runatlantis.io/docs/access-credentials.html#generating-an-access-token

```bash
root@host2:~# apt-get install git
ivanov@host2:~$ curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
ivanov@host2:~$ ./atlantis server --gh-user AndreyIvanov87 --gh-token xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --repo-config=/home/ivanov/server.yaml --repo-allowlist='github.com/AndreyIvanov87/terraform-cloud' --atlantis-url http://78.24.223.17:4141/ --gh-app-key-file="./gh-app-key-file.pem" --gh-webhook-secret="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" --gh-app-id="208512" 


ivanov@host2:~$ cat server.yaml  | grep -v '#'
repos:
- id: /.*/
  branch: /.*/

  apply_requirements: [approved, mergeable]

  workflow: custom

  allowed_overrides: [apply_requirements, workflow, delete_source_branch_on_merge]

  allowed_workflows: [custom]

  allow_custom_workflows: true

  delete_source_branch_on_merge: true
  
  

- id: github.com/AndreyIvanov87/terraform-cloud

workflows:
  custom:
    plan:
      steps:
      - run: export TF_VAR_yandex_token=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      - init
      - plan:
          extra_args: ["-lock", "false"]
    apply:
      steps:
      - run: echo hi
      - apply



```

Создай `atlantis.yaml` который, если поместить в корень terraform проекта, скажет атлантису:
1. Надо запускать планирование и аплай для двух воркспейсов `stage` и `prod`.
1. Необходимо включить автопланирование при изменении любых файлов `*.tf`.


В качестве результата приложите ссылку на файлы `server.yaml` и `atlantis.yaml`.

```bash
ivanov@lusankiya:~/netology/terraform-cloud$ cat atlantis.yaml 
version: 3

projects:
- name: my-project-name
  dir: .
  workspace: stage
  autoplan:
    when_modified: ["*.tf", "../modules/**/*.tf", "atlantis.yaml"]
    enabled: true
  apply_requirements: [mergeable, approved]
  workflow: custom
- name: my-project-2
  dir: .
  workspace: prod
  autoplan:
    when_modified: ["*.tf", "../modules/**/*.tf", "atlantis.yaml"]
    enabled: true
  apply_requirements: [mergeable, approved]
  workflow: custom


workflows:
  custom:
    plan:
      steps:
      - run: echo 'plan start'
      - init
      - plan:
          extra_args: ["-lock", "false", "-var-file", "/home/ivanov/terraform.tfvars"]
      - run: echo 'plan finish'
    apply:
      steps:
      - run: echo apply
      - apply
```




## Задача 3. Знакомство с каталогом модулей. 

1. В [каталоге модулей](https://registry.terraform.io/browse/modules) найдите официальный модуль от aws для создания
`ec2` инстансов.  
Так как с работой с AWS из России сейчас проблемы и в курсе сказано делать упор на яндекс облако, модуль для рассмотрения выбран для него:   
https://registry.terraform.io/modules/olezhuravlev/compute-instance/yandex/latest
2. Изучите как устроен модуль. Задумайтесь, будете ли в своем проекте использовать этот модуль или непосредственно ресурс `aws_instance` без помощи модуля?  
Модуль имеет возможность создавать несколько инстансов через переменную   
variable instance_count { default = 1 }  
И присваивать им удобные имена  
```bash
# Service variables.  
#start numbering from X+1 (e.g. name-1 if '0', name-3 if '2', etc.)  
variable count_offset { default = 0 }  
#server number format (-1, -2, etc.)
variable count_format { default = "%01d" }
```
Так что в проекте может быть полезно. Ради одного инстанса подгружать модуль наоборот смысла не вижу.  
3. В рамках предпоследнего задания был создан ec2 при помощи ресурса `aws_instance`. 
Создайте аналогичный инстанс при помощи найденного модуля.   

В качестве результата задания приложите ссылку на созданный блок конфигураций. 
```bash
vagrant@server2:~/homework-tf-04$ mkdir ../modules
vagrant@server2:~/homework-tf-04$ cd ../modules/
vagrant@server2:~/modules$ git clone https://github.com/olezhuravlev/terraform-yandex-compute-instance
Cloning into 'terraform-yandex-compute-instance'...
remote: Enumerating objects: 9, done.
remote: Counting objects: 100% (9/9), done.
remote: Compressing objects: 100% (9/9), done.
remote: Total 9 (delta 0), reused 9 (delta 0), pack-reused 0
Unpacking objects: 100% (9/9), 3.61 KiB | 410.00 KiB/s, done.
vagrant@server2:~/modules$ ls terraform-yandex-compute-instance/
main.tf  outputs.tf  README.md  variables.tf  versions.tf
vagrant@server2:~/homework-tf-05$ terraform init
Initializing modules...
Downloading file:///home/vagrant/modules/terraform-yandex-compute-instance/ for yc-instance...
- yc-instance in .terraform/modules/yc-instance

Initializing the backend...

Initializing provider plugins...
- Finding latest version of yandex-cloud/yandex...
- Finding latest version of terraform-registry.storage.yandexcloud.net/yandex-cloud/yandex...
- Installing yandex-cloud/yandex v0.75.0...
- Installed yandex-cloud/yandex v0.75.0 (unauthenticated)
- Installing terraform-registry.storage.yandexcloud.net/yandex-cloud/yandex v0.72.0...
- Installed terraform-registry.storage.yandexcloud.net/yandex-cloud/yandex v0.72.0 (self-signed, key ID E40F590B50BB8E40)
vagrant@server2:~/homework-tf-05$ cat main.tf 
provider "yandex" {
  token     = var.yandex_token
  cloud_id  = var.yandex_cloud_id
  folder_id = var.yandex_folder_id
  zone      = var.yandex_zone_default
}

module "yc-instance" {
  source             = "/home/vagrant/modules/terraform-yandex-compute-instance/"
  yandex_cloud_id    = var.yandex_cloud_id
  folder_id          = var.yandex_folder_id
  path_to_public_key = "~/.ssh/id_rsa.pub"
  instance_count     = 3
}


resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

vagrant@server2:~/homework-tf-05$ terraform plan -var-file ~/terraform.tfvars 

Terraform used the selected providers to generate the following execution plan. Resource actions are
indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # yandex_vpc_network.network-1 will be created
  + resource "yandex_vpc_network" "network-1" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "network1"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_subnet.subnet-1 will be created
  + resource "yandex_vpc_subnet" "subnet-1" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "subnet1"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.10.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

  # module.yc-instance.yandex_compute_instance.instance[0] will be created
  + resource "yandex_compute_instance" "instance" {
      + allow_stopping_for_update = true
      + created_at                = (known after apply)
      + description               = "Instance"
      + folder_id                 = "b1gq9soqejoerr49t4a4"
      + fqdn                      = (known after apply)
      + hostname                  = "instance-1"
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
            EOT
        }
      + name                      = "instance-1"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = "ru-central1-a"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd80o2eikcn22b229tsa"
              + name        = (known after apply)
              + size        = 30
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + placement_group_id = (known after apply)
        }

      + resources {
          + core_fraction = 20
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # module.yc-instance.yandex_compute_instance.instance[1] will be created
  + resource "yandex_compute_instance" "instance" {
      + allow_stopping_for_update = true
      + created_at                = (known after apply)
      + description               = "Instance"
      + folder_id                 = "b1gq9soqejoerr49t4a4"
      + fqdn                      = (known after apply)
      + hostname                  = "instance-2"
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
            EOT
        }
      + name                      = "instance-2"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = "ru-central1-a"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd80o2eikcn22b229tsa"
              + name        = (known after apply)
              + size        = 30
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + placement_group_id = (known after apply)
        }

      + resources {
          + core_fraction = 20
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # module.yc-instance.yandex_compute_instance.instance[2] will be created
  + resource "yandex_compute_instance" "instance" {
      + allow_stopping_for_update = true
      + created_at                = (known after apply)
      + description               = "Instance"
      + folder_id                 = "b1gq9soqejoerr49t4a4"
      + fqdn                      = (known after apply)
      + hostname                  = "instance-3"
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
            EOT
        }
      + name                      = "instance-3"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = "ru-central1-a"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd80o2eikcn22b229tsa"
              + name        = (known after apply)
              + size        = 30
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + placement_group_id = (known after apply)
        }

      + resources {
          + core_fraction = 20
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # module.yc-instance.yandex_iam_service_account.iam_sa will be created
  + resource "yandex_iam_service_account" "iam_sa" {
      + created_at  = (known after apply)
      + description = "Service account to be used by Terraform"
      + folder_id   = "b1gq9soqejoerr49t4a4"
      + id          = (known after apply)
      + name        = "terraform-netology-sa-default"
    }

  # module.yc-instance.yandex_iam_service_account_static_access_key.iam-sa-static-key will be created
  + resource "yandex_iam_service_account_static_access_key" "iam-sa-static-key" {
      + access_key           = (known after apply)
      + created_at           = (known after apply)
      + description          = "Static access key for service account"
      + encrypted_secret_key = (known after apply)
      + id                   = (known after apply)
      + key_fingerprint      = (known after apply)
      + secret_key           = (sensitive value)
      + service_account_id   = (known after apply)
    }

  # module.yc-instance.yandex_resourcemanager_folder_iam_member.storage-admin will be created
  + resource "yandex_resourcemanager_folder_iam_member" "storage-admin" {
      + folder_id = "b1gq9soqejoerr49t4a4"
      + id        = (known after apply)
      + member    = (known after apply)
      + role      = "storage.admin"
    }

  # module.yc-instance.yandex_storage_bucket.storage-bucket will be created
  + resource "yandex_storage_bucket" "storage-bucket" {
      + access_key         = (known after apply)
      + acl                = "private"
      + bucket             = "netology-bucket-default"
      + bucket_domain_name = (known after apply)
      + force_destroy      = false
      + id                 = (known after apply)
      + secret_key         = (sensitive value)
      + website_domain     = (known after apply)
      + website_endpoint   = (known after apply)

      + grant {
          + id          = (known after apply)
          + permissions = [
              + "READ",
              + "WRITE",
            ]
          + type        = "CanonicalUser"
        }

      + versioning {
          + enabled = (known after apply)
        }
    }

  # module.yc-instance.yandex_vpc_network.vpc-network will be created
  + resource "yandex_vpc_network" "vpc-network" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + description               = "Netology module network"
      + folder_id                 = "b1gq9soqejoerr49t4a4"
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "netology-module-network"
      + subnet_ids                = (known after apply)
    }

  # module.yc-instance.yandex_vpc_subnet.vpc-subnet will be created
  + resource "yandex_vpc_subnet" "vpc-subnet" {
      + created_at     = (known after apply)
      + description    = "Netology subnet 0"
      + folder_id      = "b1gq9soqejoerr49t4a4"
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "netology-subnet-0"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.100.0.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

Plan: 11 to add, 0 to change, 0 to destroy.




```

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
