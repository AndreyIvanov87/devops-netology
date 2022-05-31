# Домашнее задание к занятию "7.3. Основы и принцип работы Терраформ"

## Задача 1. Создадим бэкэнд в S3 (необязательно, но крайне желательно).

Если в рамках предыдущего задания у вас уже есть аккаунт AWS, то давайте продолжим знакомство со взаимодействием
терраформа и aws. 

1. Создайте s3 бакет, iam роль и пользователя от которого будет работать терраформ. Можно создать отдельного пользователя,
а можно использовать созданного в рамках предыдущего задания, просто добавьте ему необходимы права, как описано 
[здесь](https://www.terraform.io/docs/backends/types/s3.html).
1. Зарегистрируйте бэкэнд в терраформ проекте как описано по ссылке выше. 

```bash
vagrant@server2:~/homework-tf-02/s3-create$ cat provider.tf 
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = "${var.yandex_token}"
  cloud_id  = "${var.yandex_cloud_id}"
  folder_id = "${var.yandex_folder_id}"
  zone      = "${var.yandex_zone_default}"
}

resource "yandex_storage_bucket" "s3-test" {
  access_key = "${var.yandex_s3_access_key}"
  secret_key = "${var.yandex_s3_secret_key}"
  bucket = "s3-test-bucket-for-terraform"
}
vagrant@server2:~/homework-tf-02/s3-create$ terraform apply --auto-approve

Terraform used the selected providers to generate the following execution plan. Resource actions are
indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # yandex_storage_bucket.s3-test will be created
  + resource "yandex_storage_bucket" "s3-test" {
      + access_key         = "YCAJE3KAiJBNsNnd5-0VCgRgZ"
      + acl                = "private"
      + bucket             = "s3-test-bucket-for-terraform"
      + bucket_domain_name = (known after apply)
      + force_destroy      = false
      + id                 = (known after apply)
      + secret_key         = (sensitive value)
      + website_domain     = (known after apply)
      + website_endpoint   = (known after apply)

      + versioning {
          + enabled = (known after apply)
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.
yandex_storage_bucket.s3-test: Creating...
yandex_storage_bucket.s3-test: Creation complete after 1s [id=s3-test-bucket-for-terraform]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```


## Задача 2. Инициализируем проект и создаем воркспейсы. 

1. Выполните `terraform init`:
    * если был создан бэкэнд в S3, то терраформ создат файл стейтов в S3 и запись в таблице 
dynamodb.
    * иначе будет создан локальный файл со стейтами.  
```bash
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"


  backend "s3" {
    endpoint = "storage.yandexcloud.net"
    bucket   = "s3-test-bucket-for-terraform"
    region   = "ru-central1"
    key      = "current-netology.tfstate"
    access_key = "XXXXXXXXXXXXXX"
    secret_key = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

    skip_region_validation      = true
    skip_credentials_validation = true
  }

}

provider "yandex" {
  token     = var.yandex_token
  cloud_id  = var.yandex_cloud_id
  folder_id = var.yandex_folder_id
  zone      = var.yandex_zone_default
}
vagrant@server2:~/homework-tf-02/dz-osnovnoe$ terraform init

Initializing the backend...

Initializing provider plugins...
- Reusing previous version of yandex-cloud/yandex from the dependency lock file
- Using previously-installed yandex-cloud/yandex v0.74.0

Terraform has been successfully initialized!



```
1. Создайте два воркспейса `stage` и `prod`.
```bash
vagrant@server2:~/homework-tf-02/dz-osnovnoe$ terraform workspace new stage
vagrant@server2:~/homework-tf-02/dz-osnovnoe$ terraform workspace new prod
vagrant@server2:~/homework-tf-02/dz-osnovnoe$ terraform workspace list
  default
* prod
  stage
```
1. В уже созданный `aws_instance` добавьте зависимость типа инстанса от вокспейса, что бы в разных ворскспейсах использовались разные `instance_type`.
1. Добавим `count`. Для `stage` должен создаться один экземпляр `ec2`, а для `prod` два. 
1. Создайте рядом еще один `aws_instance`, но теперь определите их количество при помощи `for_each`, а не `count`.
1. Что бы при изменении типа инстанса не возникло ситуации, когда не будет ни одного инстанса добавьте параметр
жизненного цикла `create_before_destroy = true` в один из рессурсов `aws_instance`.
1. При желании поэкспериментируйте с другими параметрами и рессурсами.

В виде результата работы пришлите:
* Вывод команды `terraform workspace list`.
* Вывод команды `terraform plan` для воркспейса `prod`.  
```bash
vagrant@server2:~/homework-tf-02/dz-osnovnoe$ cat structure.tf 
#выбираем тип платформы в зависимости от воркспейса
locals {
  web_instance_type_map = {
    stage = "standard-v1"
    prod  = "standard-v2"
  }
}

#задаем число нод в каждом воркспейсе
locals {
  web_instance_count_map = {
    stage = 1
    prod  = 2
  }
}

#выбираем тип платформы и образ через for each
locals {
  instances = {
    "standard-v1" = "fd83mo49vdjcugs26k8l"
    "standard-v2" = "fd83mo49vdjcugs26k8l"
  }
}


resource "yandex_compute_instance" "vm-1" {
  #name = "terraform1"
  platform_id = local.web_instance_type_map[terraform.workspace]
  hostname    = "tf-${count.index}.netology.ru"
  count       = local.web_instance_count_map[terraform.workspace]
  name        = format("terraform-%03d", count.index + 1)
  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd83mo49vdjcugs26k8l"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys  = "${file("~/.ssh/id_rsa.pub")}"
    user-data = "${file("~/homework-tf-02/dz-osnovnoe/user-meta.txt")}"
  }
}

resource "yandex_compute_instance" "vm-2" {
  for_each = local.instances
  platform_id = each.key
  name        = each.key
  #hostname    = "foreach.netology.ru"
  lifecycle {
	create_before_destroy = true
	#prevent_destroy = true
	#ignore_changes = ["tags"]
  }  
  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = each.value
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys  = "${file("~/.ssh/id_rsa.pub")}"
    user-data = "${file("~/homework-tf-02/dz-osnovnoe/user-meta.txt")}"
  }
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

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1[0].network_interface.0.ip_address
}

output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1[0].network_interface.0.nat_ip_address
}

output "subnet-1" {
  value = yandex_vpc_subnet.subnet-1.id
}

##################################################################
vagrant@server2:~/homework-tf-02/dz-osnovnoe$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are
indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # yandex_compute_instance.vm-1[0] will be created
  + resource "yandex_compute_instance" "vm-1" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = "tf-0.netology.ru"
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys"  = <<-EOT
            EOT
          + "user-data" = <<-EOT
                #cloud-config
                users:
                  - name: vagrant
                    groups: sudo
                    shell: /bin/bash
                    sudo: ['ALL=(ALL) NOPASSWD:ALL']
                    ssh_authorized_keys:
                
            EOT
        }
      + name                      = "terraform-001"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v2"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd83mo49vdjcugs26k8l"
              + name        = (known after apply)
              + size        = (known after apply)
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
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.vm-1[1] will be created
  + resource "yandex_compute_instance" "vm-1" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = "tf-1.netology.ru"
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys"  = <<-EOT
            EOT
          + "user-data" = <<-EOT
                #cloud-config
                users:
                  - name: vagrant
                    groups: sudo
                    shell: /bin/bash
                    sudo: ['ALL=(ALL) NOPASSWD:ALL']
                    ssh_authorized_keys:
                
            EOT
        }
      + name                      = "terraform-002"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v2"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd83mo49vdjcugs26k8l"
              + name        = (known after apply)
              + size        = (known after apply)
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
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.vm-2["standard-v1"] will be created
  + resource "yandex_compute_instance" "vm-2" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys"  = <<-EOT
            EOT
          + "user-data" = <<-EOT
                #cloud-config
                users:
                  - name: vagrant
                    groups: sudo
                    shell: /bin/bash
                    sudo: ['ALL=(ALL) NOPASSWD:ALL']
                    ssh_authorized_keys:
                
            EOT
        }
      + name                      = "standard-v1"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd83mo49vdjcugs26k8l"
              + name        = (known after apply)
              + size        = (known after apply)
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
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.vm-2["standard-v2"] will be created
  + resource "yandex_compute_instance" "vm-2" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys"  = <<-EOT
            EOT
          + "user-data" = <<-EOT
                #cloud-config
                users:
                  - name: vagrant
                    groups: sudo
                    shell: /bin/bash
                    sudo: ['ALL=(ALL) NOPASSWD:ALL']
                    ssh_authorized_keys:
                
            EOT
        }
      + name                      = "standard-v2"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v2"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd83mo49vdjcugs26k8l"
              + name        = (known after apply)
              + size        = (known after apply)
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
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

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

Plan: 6 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + external_ip_address_vm_1 = (known after apply)
  + internal_ip_address_vm_1 = (known after apply)
  + subnet-1                 = (known after apply)

────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly
these actions if you run "terraform apply" now.

##############################################
vagrant@server2:~/homework-tf-02/dz-osnovnoe$ terraform apply --auto-approve

Terraform used the selected providers to generate the following execution plan. Resource actions are
indicated with the following symbols:
  + create
...
yandex_vpc_network.network-1: Creating...
yandex_vpc_network.network-1: Creation complete after 2s [id=enpe7e829nkgssthpd7q]
yandex_vpc_subnet.subnet-1: Creating...
yandex_vpc_subnet.subnet-1: Creation complete after 1s [id=e9b0rnoinnmovvcodd08]
yandex_compute_instance.vm-1[1]: Creating...
yandex_compute_instance.vm-2["standard-v2"]: Creating...
yandex_compute_instance.vm-1[0]: Creating...
yandex_compute_instance.vm-2["standard-v1"]: Creating...
yandex_compute_instance.vm-1[1]: Still creating... [10s elapsed]
yandex_compute_instance.vm-2["standard-v2"]: Still creating... [10s elapsed]
yandex_compute_instance.vm-1[0]: Still creating... [10s elapsed]
yandex_compute_instance.vm-2["standard-v1"]: Still creating... [10s elapsed]
yandex_compute_instance.vm-1[1]: Still creating... [20s elapsed]
yandex_compute_instance.vm-2["standard-v2"]: Still creating... [20s elapsed]
yandex_compute_instance.vm-1[0]: Still creating... [20s elapsed]
yandex_compute_instance.vm-2["standard-v1"]: Still creating... [20s elapsed]
yandex_compute_instance.vm-2["standard-v1"]: Creation complete after 22s [id=fhm51arpocvbfonnufo7]
yandex_compute_instance.vm-2["standard-v2"]: Creation complete after 24s [id=fhmfmsehk60na5ln9hbn]
yandex_compute_instance.vm-1[0]: Creation complete after 24s [id=fhmjrrtqrtd27u4ul5dv]
yandex_compute_instance.vm-1[1]: Creation complete after 27s [id=fhmpco845p6hmcu7jb1l]

Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:

external_ip_address_vm_1 = "51.250.89.228"
internal_ip_address_vm_1 = "192.168.10.24"
subnet-1 = "e9b0rnoinnmovvcodd08"
vagrant@server2:~/homework-tf-02/dz-osnovnoe$ terraform workspace show
prod
vagrant@server2:~/homework-tf-02/dz-osnovnoe$ yc compute instance list
+----------------------+---------------+---------------+---------+---------------+---------------+
|          ID          |     NAME      |    ZONE ID    | STATUS  |  EXTERNAL IP  |  INTERNAL IP  |
+----------------------+---------------+---------------+---------+---------------+---------------+
| fhm51arpocvbfonnufo7 | standard-v1   | ru-central1-a | RUNNING | 51.250.94.33  | 192.168.10.8  |
| fhmfmsehk60na5ln9hbn | standard-v2   | ru-central1-a | RUNNING | 51.250.80.158 | 192.168.10.22 |
| fhmjrrtqrtd27u4ul5dv | terraform-001 | ru-central1-a | RUNNING | 51.250.89.228 | 192.168.10.24 |
| fhmpco845p6hmcu7jb1l | terraform-002 | ru-central1-a | RUNNING | 51.250.81.253 | 192.168.10.28 |
+----------------------+---------------+---------------+---------+---------------+---------------+

vagrant@server2:~/homework-tf-02/dz-osnovnoe$ terraform destroy --auto-approve
```







---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
