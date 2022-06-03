# Заменить на ID своего облака
# https://console.cloud.yandex.ru/cloud?section=overview
variable "yandex_cloud_id" {
  default = "b1ghsk460b4nn8sps0p2"
}

# Заменить на Folder своего облака
# https://console.cloud.yandex.ru/cloud?section=overview
variable "yandex_folder_id" {
  default = "b1gq9soqejoerr49t4a4"
}


#Зона размещения инфраструктуры по-умолчанию
variable "yandex_zone_default" {
  default = "ru-central1-a"
}

#Токен. вообще  можно взять из yc config list
#variable "yandex_token" {
#  default = "token here not recommended, use cli"
# example bash: TF_VAR_yandex_token=("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX") terraform plan 
#}
variable "yandex_token" {
  type = string
}

# Заменить на ID своего образа
# ID можно узнать с помощью команды yc compute image list
variable "ubuntu" {
  default = "fd83mo49vdjcugs26k8l"
}


