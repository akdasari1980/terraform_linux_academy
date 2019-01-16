variable "env" {
    description = "env: dev or prod"
}

variable "image" {
    description = "image for container"
    type = "map"
    default = {
        dev = "ghost:latest"
        prod = "ghost:alpine"
    }
}

variable "container_name" {
    description = "name for container"
    type = "map"
    default = {
        dev = "dev"
        prod = "blog"
    }
}

variable "container_port_internal" {
    description = "container port mapping"
    default = "2368"
}

variable "container_port_external" {
    description = "host port mapping to container port"
    type = "map"
    default = {
        dev = "8080"
        prod = "80"
    }
}