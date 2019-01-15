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
