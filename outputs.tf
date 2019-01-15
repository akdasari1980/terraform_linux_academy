# Output the IP Address of the Container
output "IP Address" {
    value = "${docker_container.la_docker_container.ip_address}"
}

output "Container Name" {
    value = "${docker_container.la_docker_container.name}"
}
