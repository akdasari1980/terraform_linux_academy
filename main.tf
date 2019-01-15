# Download the latest Ghost image
module "image" {
    source = "./image"
    image = "${var.image}"
}

# Start the Container

module "container" {
    source = "./container"
    image = "${module.image.image_out}"
    container_name = "${var.container_name}"
    container_port_internal = "${var.container_port_internal}"
    container_port_external = "${var.container_port_external}"
}