# Переменные
variable "service_account_key_file" {
  description = "Yandex Cloud Service account key file"
  type        = string
  sensitive   = true
}

variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

variable "zone" {
  description = "Yandex Cloud Zone"
  type        = string
  default     = "ru-central1-a"
}

variable "username" {
    description = "Host Username"
    type = string
}