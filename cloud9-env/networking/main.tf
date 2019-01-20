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