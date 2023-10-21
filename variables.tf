variable "certificate_password" {
  type        = string
  description = "Password for the pfx file specified in data."
  sensitive   = true
}

variable "certificate_path" {
  type        = string
  description = "Relative path to the required certificate."
}