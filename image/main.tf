# Download the latest Ghost image
resource "docker_image" "la_docker_image" {
    name = "${var.image}"
}
