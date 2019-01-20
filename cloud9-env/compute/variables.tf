#======compute/variables.tf======

variable "key_name" {
    default = "terraform"
}
variable "public_key_path" {
    default = "~/.ssh/terraform-key.pub"
}