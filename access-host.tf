# Fetch Latest Amazon Linux AMI

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# Security Group 

resource "aws_security_group" "bastion_sg" {
  name        = "eks-ssm-bastion-sg"
  description = "Security group for SSM Bastion"
  vpc_id      = module.vpc.vpc_id

  # No inbound rules required for SSM

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group_rule" "bastion_to_eks_api" {

  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"

  security_group_id        = module.eks.cluster_security_group_id
  source_security_group_id = aws_security_group.bastion_sg.id

  description = "Allow bastion to access private EKS API"
}


# IAM Role for Bastion

resource "aws_iam_role" "ssm_role" {
  name = "eks-ssm-bastion-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach Policies
resource "aws_iam_policy" "eks_describe_policy" {
  name = "EKSDescribeClusterPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster"
        ]
        Resource = module.eks.cluster_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_describe_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = aws_iam_policy.eks_describe_policy.arn
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


# Instance Profile

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "eks-ssm-bastion-profile"
  role = aws_iam_role.ssm_role.name
}

# Bastion EC2 Instance

resource "aws_instance" "eks_access_host" {

  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = module.vpc.private_subnets[0]
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
  associate_public_ip_address = false

  tags = {
    Name = "private-eks-ssm-bastion"
  }

  user_data = <<-EOF
#!/bin/bash
yum update -y
yum install -y unzip curl

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip awscliv2.zip
./aws/install

# Install kubectl
curl -LO "https://dl.k8s.io/release/v1.29.0/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

EOF
}

