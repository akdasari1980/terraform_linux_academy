#======./main.tf======

provider "aws" {
    region = "${var.aws_region}"
}

# Deploy Storage Resources
module "storage" {
    source = "./storage"
    project_name = "${var.project_name}"
}

# Deploy Networking Resources
module "networking" {
    source = "./networking"
    vpc_cidr = "${var.vpc_cidr}"
    public_cidrs = "${var.public_cidrs}"
    accessip = "${var.accessip}"
}

# Deploy Compute Resources
module "compute" {
    source = "./compute"
    key_name = "${var.key_name}"
    public_key_path = "${var.public_key_path}"
    instance_count = "${var.instance_count}"
    instance_type = "${var.instance_type}"
    security_group = "${module.networking.public_sg}"
    subnets = "${module.networking.public_subnets}"
    subnet_ips = "${module.networking.subnet_ips}"
}