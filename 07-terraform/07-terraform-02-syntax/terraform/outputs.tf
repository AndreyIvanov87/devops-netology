output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}

output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}

output "subnet-1" {
  value = yandex_vpc_subnet.subnet-1.id
}

data "yandex_iam_user" "admin" {
  login = "xxxxxxxxxxxxxxxxx@yandex.ru"
}

output "yandex_iam_user" {
  value = "${data.yandex_iam_user.admin.user_id}"
}

data "yandex_iam_service_account" "builder" {
  name = "my-robot"
}

output "yandex_iam_service_account" {
  value = "${data.yandex_iam_service_account.builder.service_account_id}"
}

