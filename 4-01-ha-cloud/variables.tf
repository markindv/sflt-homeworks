variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
  default     = "b1gukcv6slhf9pnitql5"
}

variable "folder_id" {
  description = "Yandex Cloud folder ID"
  type        = string
  default     = "b1g3ttkp3v3fh6md6eof"
}

variable "zone" {
  description = "Availability zone for the two identical VMs"
  type        = string
  default     = "ru-central1-a"
}

variable "name_prefix" {
  description = "Prefix for homework resources"
  type        = string
  default     = "netology-ha"
}

