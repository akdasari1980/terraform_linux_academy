# Start the Container
resource "docker_container" "la_docker_container" {
    name = "${var.container_name}"
    image = "${var.image}"
    ports {
        internal = "${var.container_port_internal}"
        external = "${var.container_port_external}"
    }
}