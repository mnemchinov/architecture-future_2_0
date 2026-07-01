output "network_id" {
  description = "ID созданной VPC-сети"
  value       = yandex_vpc_network.arch.id
}

output "subnet_a_id" {
  description = "ID подсети в зоне A"
  value       = yandex_vpc_subnet.a.id
}

output "subnet_b_id" {
  description = "ID подсети в зоне B"
  value       = yandex_vpc_subnet.b.id
}

output "k8s_cluster_id" {
  description = "ID кластера Managed Kubernetes"
  value       = yandex_kubernetes_cluster.main.id
}

output "k8s_node_group_id" {
  description = "ID группы нод Kubernetes"
  value       = yandex_kubernetes_node_group.main.id
}

output "k8s_cluster_endpoint" {
  description = "End-точка Kubernetes API"
  value       = yandex_kubernetes_cluster.main.master[0].endpoint
}

output "postgresql_cluster_id" {
  description = "ID кластера Managed PostgreSQL"
  value       = yandex_mdb_postgresql_cluster.main.id
}

output "postgresql_hosts" {
  description = "Хосты PostgreSQL"
  value       = yandex_mdb_postgresql_cluster.main.host[*].fqdn
}

output "clickhouse_cluster_id" {
  description = "ID кластера Managed ClickHouse"
  value       = yandex_mdb_clickhouse_cluster.main.id
}

output "clickhouse_host" {
  description = "Хост ClickHouse"
  value       = yandex_mdb_clickhouse_cluster.main.host[0].fqdn
}

output "kafka_cluster_id" {
  description = "ID кластера Managed Kafka"
  value       = yandex_mdb_kafka_cluster.main.id
}

output "kafka_brokers" {
  description = "Список брокеров Kafka"
  value       = yandex_mdb_kafka_cluster.main.host[*].fqdn
}

output "storage_bucket" {
  description = "Имя бакета Object Storage для Lakehouse"
  value       = yandex_storage_bucket.lakehouse.bucket
}

output "bastion_ip" {
  description = "Публичный IP адрес bastion-хоста"
  value       = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
}

output "service_account_k8s_id" {
  description = "ID сервисного аккаунта для K8s"
  value       = yandex_iam_service_account.k8s.id
}

output "service_account_storage_id" {
  description = "ID сервисного аккаунта для Object Storage"
  value       = yandex_iam_service_account.storage.id
}
