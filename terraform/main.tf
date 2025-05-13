module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "web_server_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "web-server"
  description = "Security group for web-server with HTTP ports open within VPC"
  vpc_id      = "vpc-12345678"

  ingress_cidr_blocks = ["10.10.0.0/16"]
}

module "keypair" {
  source  = "thomasvjoseph/keypair/aws"
  version = "1.1.3"
  key_pair_name = "my-key-pair"
}

module "ec2" {
  source = "./EC2"
   ec2_resources = {
    public_instance = {
      ami_id                = var.ami_id
      instance_type         = "t2.micro"
      availability_zone     = module.vpc.azs[0]
      vpc_security_group_id = [module.web_server_sg.security_group_id]
      subnet_id             = module.vpc.public_subnets[0]
      name                  = "test-instance"
      env                   = "test"
    }
  }
  key_pair_name = module.keypair.key_pair_name
  ebs_size      = 8
  ebs_device_name = "/dev/sdh"
}