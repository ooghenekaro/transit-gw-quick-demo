variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "vpc_cidr_blocks" {
  description = "CIDR blocks for the VPCs"
  type        = map(string)
  default = {
    vpc1 = "10.0.0.0/16"
    vpc2 = "10.1.0.0/16"
    vpc3 = "10.2.0.0/16"
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = map(string)
  default = {
    vpc1_subnet1 = "10.0.1.0/24"
    vpc2_subnet1 = "10.1.1.0/24"
    vpc3_subnet1 = "10.2.1.0/24"
  }
}






provider "aws" {
  region = var.region
}


resource "aws_vpc" "vpc1" {
  cidr_block = var.vpc_cidr_blocks["vpc1"]
}

resource "aws_vpc" "vpc2" {
  cidr_block = var.vpc_cidr_blocks["vpc2"]
}

resource "aws_vpc" "vpc3" {
  cidr_block = var.vpc_cidr_blocks["vpc3"]
}

resource "aws_subnet" "vpc1_subnet1" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = var.public_subnet_cidrs["vpc1_subnet1"]
}

resource "aws_subnet" "vpc2_subnet1" {
  vpc_id     = aws_vpc.vpc2.id
  cidr_block = var.public_subnet_cidrs["vpc2_subnet1"]
}

resource "aws_subnet" "vpc3_subnet1" {
  vpc_id     = aws_vpc.vpc3.id
  cidr_block = var.public_subnet_cidrs["vpc3_subnet1"]
}



resource "aws_internet_gateway" "vpc1_igw" {
  vpc_id = aws_vpc.vpc1.id
}

resource "aws_internet_gateway" "vpc2_igw" {
  vpc_id = aws_vpc.vpc2.id
}

resource "aws_internet_gateway" "vpc3_igw" {
  vpc_id = aws_vpc.vpc3.id
}





resource "aws_route_table" "vpc1_rt" {
  vpc_id = aws_vpc.vpc1.id
}

resource "aws_route_table" "vpc2_rt" {
  vpc_id = aws_vpc.vpc2.id
}

resource "aws_route_table" "vpc3_rt" {
  vpc_id = aws_vpc.vpc3.id
}

resource "aws_route_table_association" "vpc1_rta" {
  subnet_id      = aws_subnet.vpc1_subnet1.id
  route_table_id = aws_route_table.vpc1_rt.id
}

resource "aws_route_table_association" "vpc2_rta" {
  subnet_id      = aws_subnet.vpc2_subnet1.id
  route_table_id = aws_route_table.vpc2_rt.id
}

resource "aws_route_table_association" "vpc3_rta" {
  subnet_id      = aws_subnet.vpc3_subnet1.id
  route_table_id = aws_route_table.vpc3_rt.id
}

resource "aws_route" "vpc1_igw_route" {
  route_table_id         = aws_route_table.vpc1_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.vpc1_igw.id
}

resource "aws_route" "vpc2_igw_route" {
  route_table_id         = aws_route_table.vpc2_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.vpc2_igw.id
}

resource "aws_route" "vpc3_igw_route" {
  route_table_id         = aws_route_table.vpc3_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.vpc3_igw.id
}





resource "aws_ec2_transit_gateway" "main" {
  description = "Transit Gateway"
  auto_accept_shared_attachments = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
}



resource "aws_ec2_transit_gateway_vpc_attachment" "vpc1_attachment" {
  subnet_ids         = [aws_subnet.vpc1_subnet1.id]
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = aws_vpc.vpc1.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc2_attachment" {
  subnet_ids         = [aws_subnet.vpc2_subnet1.id]
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = aws_vpc.vpc2.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc3_attachment" {
  subnet_ids         = [aws_subnet.vpc3_subnet1.id]
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = aws_vpc.vpc3.id
}



resource "aws_ec2_transit_gateway_route" "vpc1_to_vpc2" {
  destination_cidr_block         = var.vpc_cidr_blocks["vpc2"]
  transit_gateway_route_table_id = aws_ec2_transit_gateway.main.association_default_route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc1_attachment.id
}

/*
resource "aws_ec2_transit_gateway_route" "vpc1_to_vpc3" {
  destination_cidr_block         = var.vpc_cidr_blocks["vpc3"]
  transit_gateway_route_table_id = aws_ec2_transit_gateway.main.association_default_route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc1_attachment.id
}
*/

resource "aws_ec2_transit_gateway_route" "vpc2_to_vpc1" {
  destination_cidr_block         = var.vpc_cidr_blocks["vpc1"]
  transit_gateway_route_table_id = aws_ec2_transit_gateway.main.association_default_route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc2_attachment.id
}

resource "aws_ec2_transit_gateway_route" "vpc2_to_vpc3" {
  destination_cidr_block         = var.vpc_cidr_blocks["vpc3"]
  transit_gateway_route_table_id = aws_ec2_transit_gateway.main.association_default_route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc2_attachment.id
}

/*
resource "aws_ec2_transit_gateway_route" "vpc3_to_vpc1" {
  destination_cidr_block         = var.vpc_cidr_blocks["vpc1"]
  transit_gateway_route_table_id = aws_ec2_transit_gateway.main.association_default_route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc3_attachment.id
}
*/

/*
resource "aws_ec2_transit_gateway_route" "vpc3_to_vpc2" {
  destination_cidr_block         = var.vpc_cidr_blocks["vpc2"]
  transit_gateway_route_table_id = aws_ec2_transit_gateway.main.association_default_route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc3_attachment.id
}
*/




resource "aws_instance" "ec2_vpc1" {
  ami                    = "ami-0eb260c4d5475b901" # Replace with a valid AMI ID
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.vpc1_subnet1.id
  key_name               = "solo-access-key"
  vpc_security_group_ids        = ["sg-000473178f362b71c"]
  associate_public_ip_address = true

  tags = {
    Name = "EC2-VPC1"
  }

    depends_on = [aws_security_group.allow_all]
}

resource "aws_instance" "ec2_vpc2" {
  ami                    = "ami-0eb260c4d5475b901" # Replace with a valid AMI ID
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.vpc2_subnet1.id
  key_name               = "solo-access-key"
  vpc_security_group_ids        = ["sg-0c4ddb65e1c97a2da"]
  associate_public_ip_address = true

  tags = {
    Name = "EC2-VPC2"
  }

    depends_on = [aws_security_group.vpc2_allow_all]
}

resource "aws_instance" "ec2_vpc3" {
  ami                    = "ami-0eb260c4d5475b901" # Replace with a valid AMI ID
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.vpc3_subnet1.id
  key_name               = "solo-access-key"
  vpc_security_group_ids        = ["sg-0612942cec437f9d2"]
  associate_public_ip_address = true

  tags = {
    Name = "EC2-VPC3"
  }
   
    depends_on = [aws_security_group.vpc3_allow_all]

}






resource "aws_security_group" "allow_all" {
  vpc_id = aws_vpc.vpc1.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_blocks["vpc1"], var.vpc_cidr_blocks["vpc2"], var.vpc_cidr_blocks["vpc3"]]
  }
  
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_blocks["vpc1"], var.vpc_cidr_blocks["vpc2"], var.vpc_cidr_blocks["vpc3"]]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }  
    
ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_blocks["vpc1"], var.vpc_cidr_blocks["vpc2"], var.vpc_cidr_blocks["vpc3"]]
  }   


ingress {
    description = "ICMP (Ping) from anywhere"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr_blocks["vpc1"], var.vpc_cidr_blocks["vpc2"], var.vpc_cidr_blocks["vpc3"]]
  }


  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all_1"
  }
}

resource "aws_security_group" "vpc2_allow_all" {
  vpc_id = aws_vpc.vpc2.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_blocks["vpc1"], var.vpc_cidr_blocks["vpc2"], var.vpc_cidr_blocks["vpc3"]]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_blocks["vpc1"], var.vpc_cidr_blocks["vpc2"], var.vpc_cidr_blocks["vpc3"]]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_blocks["vpc1"], var.vpc_cidr_blocks["vpc2"], var.vpc_cidr_blocks["vpc3"]]
  }
   
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   
ingress {
    description = "ICMP (Ping) from anywhere"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr_blocks["vpc1"], var.vpc_cidr_blocks["vpc2"], var.vpc_cidr_blocks["vpc3"]]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all_2"
  }
}

resource "aws_security_group" "vpc3_allow_all" {
  vpc_id = aws_vpc.vpc3.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_blocks["vpc1"], var.vpc_cidr_blocks["vpc2"], var.vpc_cidr_blocks["vpc3"]]
  }
   
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_blocks["vpc1"], var.vpc_cidr_blocks["vpc2"], var.vpc_cidr_blocks["vpc3"]]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_blocks["vpc1"], var.vpc_cidr_blocks["vpc2"], var.vpc_cidr_blocks["vpc3"]]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }

  ingress {
    description = "ICMP (Ping) from anywhere"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr_blocks["vpc1"], var.vpc_cidr_blocks["vpc2"], var.vpc_cidr_blocks["vpc3"]]
  }  

egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all_3"
  }
}





