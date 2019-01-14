# Download the latest Ghost image
resource "docker_image" "linux_academy" {
    name = "ghost:latest"
}