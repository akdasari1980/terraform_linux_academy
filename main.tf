variable "image" {
    description = "image for container"
    default = "ghost:latest"
}

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

# Download the latest Ghost image
resource "docker_image" "la_docker_image" {
    name = "${var.image}"
}

# Start the Container
resource "docker_container" "la_docker_container" {
    name = "${var.container_name}"
    image = "${docker_image.la_docker_image.latest}"
    ports {
        internal = "${var.container_port_internal}"
        external = "${var.container_port_external}"
    }
}

# Output the IP Address of the Container
output "IP Address" {
    value = "${docker_container.la_docker_container.ip_address}"
}

output "Container Name" {
    value = "${docker_container.la_docker_container.name}"
}