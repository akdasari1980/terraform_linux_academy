#======./variables.tf======

variable "aws_region" {}

#---Vars for storage module
variable "project_name" {}

#---Vars for networking module
variable "vpc_cidr" {}
variable "public_cidrs" {
    type = "list"
}
variable "accessip" {}

#---Vars for compute module
variable "key_name" {}
variable "public_key_path" {}
variable "instance_count" {
    default = 1
}

variable "instance_type" {}
