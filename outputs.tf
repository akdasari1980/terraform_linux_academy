# Output the IP Address of the Container
output "IP Address" {
    value = "${module.container.ipv4_addr}"
}

output "container_name" {
    value = "${module.container.container_name}"
}