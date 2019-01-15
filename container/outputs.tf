# Output the IP Address of the Container
output "ipv4_addr" {
    value = "${docker_container.la_docker_container.ip_address}"
}

output "container_name" {
    value = "${docker_container.la_docker_container.name}"
}
