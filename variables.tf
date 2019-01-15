variable "image" {
    description = "name for container"
}

variable "container_name" {
    description = "name for container"
}

variable "container_port_internal" {
    description = "container port mapping"
}

variable "container_port_external" {
    description = "host port mapping to container port"
}