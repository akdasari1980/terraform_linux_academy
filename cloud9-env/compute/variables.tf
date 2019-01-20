#======compute/variables.tf======

variable "key_name" {}

variable "public_key_path" {}

variable "instance_count" {}

variable "instance_type" {}

variable "security_group" {}

variable "subnet_ips" {
    type = "list"
}

variable "subnets" {
    type = "list"
}
