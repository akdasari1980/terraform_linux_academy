variable "env" {
    description = "env: dev or prod"
}

variable "image" {
    description = "image for container"
    type = "map"
}

variable "container_name" {
    description = "name for container"
    type = "map"
}

variable "container_port_internal" {
    description = "container port mapping"

}

variable "container_port_external" {
    description = "host port mapping to container port"
    type = "map"
}