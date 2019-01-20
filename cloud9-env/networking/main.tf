#======networking/main.tf======

# Providers may have data sources that can be invoked to get information
# related to that provider.  Since the AWS provider is so large and diverse
# and an expansive catalog of items to use, I'll just re-link to the docs
# for the provider to have those data source documentation references at the
# ready
#
# https://www.terraform.io/docs/providers/aws/index.html#
#
# Another thing to note is while I was trying to troubleshoot some of this
# work, the terraform console command would not return values for some of
# the items that would indeed show up during a terraform plan.  I'm assuming
# this is to do with the fact it needs to reach AWS to get those values and
# a terraform console does not do that.

data "aws_availability_zones" "available" {}

resource "aws_vpc" "tf_vpc" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags {
        name = "tf_vpc"
    }
}

resource "aws_internet_gateway" "tf_internet_gateway" {
    vpc_id = "${aws_vpc.tf_vpc.id}"
    tags {
        name = "tf_igw"
    }
}

resource "aws_route_table" "tf_public_rt" {
    vpc_id = "${aws_vpc.tf_vpc.id}"
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.tf_internet_gateway.id}"
    }
    
    tags {
        name = "tf_public"
    }
}

resource "aws_default_route_table" "tf_private_rt" {
    default_route_table_id = "${aws_vpc.tf_vpc.default_route_table_id}"

    tags{
        name = "tf_private"
    }
}

resource "aws_subnet" "tf_public_subnet" {
    count = 2
    vpc_id = "${aws_vpc.tf_vpc.id}"
    cidr_block = "${var.public_cidrs[count.index]}"
    map_public_ip_on_launch = true
    availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
    
    tags {
        name = "tf_public_${count.index + 1}"
    }
}

resource "aws_route_table_association" "tf_public_assoc" {
    count = "${aws_subnet.tf_public_subnet.count}"
    subnet_id = "${aws_subnet.tf_public_subnet.*.id[count.index]}"
    route_table_id = "${aws_route_table.tf_public_rt.id}"
}

resource "aws_security_group" "tf_public_sg" {
    name = "tf_public_sg"
    description = "Used for access to the public instances"
    vpc_id = "${aws_vpc.tf_vpc.id}"
    
    #SSH
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.accessip}"]
    }
    
    #HTTP
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["${var.accessip}"]
    }
    
    egress {
        from_port = 0
        to_port = 0
        # specifying -1 allows all protocols
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}