provider "aws" {
  region = "ap-southeast-1"
}

# Data sources to get VPC and default security group details
data "aws_vpc" "default" {
  id = "vpc-077791b0103f822e8"
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

# Security group which is used as an argument in complete-sg
module "main_sg" {
  source = "../../modules/terraform-aws-sg"
  #create = false
  name        = "main-sg"
  description = "Security group which is used as an argument in complete-sg"
  vpc_id      = data.aws_vpc.default.id

  ingress_cidr_blocks = ["10.10.0.0/16"]
  ingress_rules       = ["https-443-tcp"]
}

# Security group with complete set of arguments
module "complete_sg" {
  source = "../../modules/terraform-aws-sg"

  name        = "complete-sg"
  description = "Security group with all available arguments set (this is just an example)"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Cash       = "king"
    Department = "kingdom"
  }

  ingress_cidr_blocks = ["10.10.0.0/16"]

  # Prefix list ids to use in all ingress rules in this module.
  # Open for all CIDRs defined in ingress_cidr_blocks

  #ingress_rules = ["https-443-tcp"]


  computed_ingress_rules           = ["ssh-tcp"]
  number_of_computed_ingress_rules = 1


  ingress_with_cidr_blocks = [
    {
      rule        = "postgresql-tcp"
      cidr_blocks = "0.0.0.0/0,2.2.2.2/32"
    },
    {
      rule        = "postgresql-tcp"
      cidr_blocks = "30.30.30.30/32"
    },
    {
      from_port   = 10
      to_port     = 20
      protocol    = 1
      description = "Service name"
      cidr_blocks = "10.10.0.0/20"
    },
  ]

  computed_ingress_with_cidr_blocks = [
    {
      rule        = "postgresql-tcp"
      cidr_blocks = "3.3.3.3/32,10.2.0.0/16"
    },
    {
      from_port   = 15
      to_port     = 25
      protocol    = 6
      description = "Service name with vpc cidr"
      cidr_blocks = "10.2.0.0/16"
    },
  ]

  number_of_computed_ingress_with_cidr_blocks = 1

  ingress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      source_security_group_id = data.aws_security_group.default.id
    },
    {
      from_port                = 10
      to_port                  = 10
      protocol                 = 6
      description              = "Service name"
      source_security_group_id = data.aws_security_group.default.id
    },
  ]

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "postgresql-tcp"
      source_security_group_id = module.main_sg.this_security_group_id
    },
    {
      from_port                = 23
      to_port                  = 23
      protocol                 = 6
      description              = "Service name"
      source_security_group_id = module.main_sg.this_security_group_id
    },
  ]

  number_of_computed_ingress_with_source_security_group_id = 2

  # Default CIDR blocks, which will be used for all egress rules in this module. Typically these are CIDR blocks of the VPC.
  # If this is not specified then no CIDR blocks will be used.

  egress_cidr_blocks = ["10.10.0.0/16"]


  # Prefix list ids to use in all egress rules in this module.
  # Open for all CIDRs defined in egress_cidr_blocks
  
  egress_rules = ["http-80-tcp"]

  computed_egress_rules           = ["ssh-tcp"]
  number_of_computed_egress_rules = 1

  # Open to CIDRs blocks (rule or from_port+to_port+protocol+description)
  egress_with_cidr_blocks = [
    {
      rule        = "postgresql-tcp"
      cidr_blocks = "0.0.0.0/0,2.2.2.2/32"
    },
    {
      rule        = "https-443-tcp"
      cidr_blocks = "30.30.30.30/32"
    },
    {
      from_port   = 10
      to_port     = 20
      protocol    = 6
      description = "Service name"
      cidr_blocks = "10.10.0.0/20"
    },
  ]

  computed_egress_with_cidr_blocks = [
    {
      rule        = "https-443-tcp"
      cidr_blocks = "10.2.0.0/16"
    },
  ]

  number_of_computed_egress_with_cidr_blocks = 1

  # Open for security group id (rule or from_port+to_port+protocol+description)
  egress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      source_security_group_id = data.aws_security_group.default.id
    },
    {
      from_port                = 10
      to_port                  = 10
      protocol                 = 6
      description              = "Service name"
      source_security_group_id = data.aws_security_group.default.id
    },
  ]

  computed_egress_with_source_security_group_id = [
    {
      rule                     = "postgresql-tcp"
      source_security_group_id = module.main_sg.this_security_group_id
    },
  ]

  number_of_computed_egress_with_source_security_group_id = 1

}
