variable "regiao" {
  description = "Região da AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
    description = "Bloco CIDR para VPC"
    type = string
    default = "192.168.0.0/16"
}

variable "private_subnets_cidr" {
  description = "Subnet Privada"
  type = list(string)
  default = ["192.168.6.0/24"]
}