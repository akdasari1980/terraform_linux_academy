# Download the latest Ghost image
resource "docker_image" "la_docker_image" {
    name = "ghost:alpine"
}

# Start the Container
resource "docker_container" "la_docker_container" {
    name = "blog"
    image = "${docker_image.la_docker_image.latest}"
    ports {
        internal = "2368"
        external = "80"
    }
}