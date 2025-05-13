module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "SecurityGroup" {
  source = "./SG"
  vpc_id      = module.vpc.vpc_id
  sg_resources = {
    ecs = {
      sg_name        = "ec2-sg-v2"
      sg_description = "Security Group for EMS-Node Backend Application v2"
      ingress_rules = [
        {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
      egress_rules = [{
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }]
    }
  }
  tags = {
  }
  depends_on = [ module.vpc ]
}

module "keypair" {
  source  = "thomasvjoseph/keypair/aws"
   version = "1.1.1"
  key_pair_name = "my-key-pair"
}

module "ec2" {
  source = "./EC2"
   ec2_resources = {
    public_instance = {
      ami_id                = var.ami_id
      instance_type         = "t2.micro"
      availability_zone     = module.vpc.azs[0]
      vpc_security_group_id = [module.SecurityGroup.security_group_id["ecs"]]
      subnet_id             = module.vpc.public_subnets[0]
      name                  = "test-instance"
      env                   = "test"
    }
  }
  key_pair_name = module.keypair.key_pair_name
  ebs_size      = 8
  ebs_device_name = "/dev/sdh"
  depends_on = [ module.keypair, module.SecurityGroup ]
}