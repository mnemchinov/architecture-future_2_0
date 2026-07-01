variable "cloud_id" {
  description = "ID облака Yandex Cloud"
  type        = string
}

variable "folder_id" {
  description = "ID каталога Yandex Cloud"
  type        = string
}

variable "zone_a" {
  description = "Зона доступности A"
  type        = string
  default     = "ru-central1-a"
}

variable "zone_b" {
  description = "Зона доступности B"
  type        = string
  default     = "ru-central1-b"
}

variable "environment" {
  description = "Окружение (production, staging, dev)"
  type        = string
  default     = "production"
}

# K8s
variable "k8s_node_cores" {
  description = "Количество ядер ноды K8s"
  type        = number
  default     = 4
}

variable "k8s_node_memory" {
  description = "Память ноды K8s (ГБ)"
  type        = number
  default     = 16
}

variable "k8s_node_disk_size" {
  description = "Размер диска ноды K8s (ГБ)"
  type        = number
  default     = 100
}

variable "k8s_node_count" {
  description = "Количество нод K8s"
  type        = number
  default     = 3
}

# PostgreSQL
variable "pg_version" {
  description = "Версия PostgreSQL"
  type        = string
  default     = "16"
}

variable "pg_preset" {
  description = "Тип хоста PostgreSQL"
  type        = string
  default     = "s3-c2-m8"
}

variable "pg_disk_size" {
  description = "Размер диска PostgreSQL (ГБ)"
  type        = number
  default     = 100
}

# ClickHouse
variable "ch_preset" {
  description = "Тип хоста ClickHouse"
  type        = string
  default     = "s3-c2-m8"
}

variable "ch_disk_size" {
  description = "Размер диска ClickHouse (ГБ)"
  type        = number
  default     = 200
}

# Kafka
variable "kafka_version" {
  description = "Версия Kafka"
  type        = string
  default     = "3.6"
}

variable "kafka_brokers" {
  description = "Количество брокеров Kafka"
  type        = number
  default     = 2
}

variable "kafka_preset" {
  description = "Тип хоста Kafka"
  type        = string
  default     = "s3-c2-m8"
}

variable "kafka_disk_size" {
  description = "Размер диска Kafka (ГБ)"
  type        = number
  default     = 100
}

# Object Storage
variable "bucket_name" {
  description = "Имя бакета Object Storage для Lakehouse"
  type        = string
}

# SSH
variable "ssh_public_key" {
  description = "Публичный SSH-ключ для доступа к bastion"
  type        = string
}
