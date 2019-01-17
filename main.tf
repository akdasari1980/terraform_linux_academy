# Download the latest Ghost image
module "image" {
    source = "./image"
    image = "${lookup(var.image, var.env)}"
}

# Start the Container

module "container" {
    source = "./container"
    image = "${module.image.image_out}"
    container_name = "${lookup(var.container_name, var.env)}"
    container_port_internal = "${var.container_port_internal}"
    container_port_external = "${lookup(var.container_port_external, var.env)}"
}

resource "null_resource" "null_id" {
    provisioner "local-exec" {
        command = "echo ${module.container.container_name}:${module.container.ipv4_addr} >> container.txt"
    }
}