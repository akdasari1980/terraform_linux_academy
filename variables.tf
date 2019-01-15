variable "container_name" {
    description = "name for container"
    default = "blog"
}

variable "container_port_internal" {
    description = "container port mapping"
    default = "2368"
}

variable "container_port_external" {
    description = "host port mapping to container port"
    default = "80"
}
