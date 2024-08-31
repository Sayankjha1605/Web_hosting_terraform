#vpc

resource "aws_vpc" "sayankvpc" {
  cidr_block       = var.cidr
  instance_tenancy = "default"

  tags = {
    Name = "sayankvpc"
  }
}


# public subnet

resource "aws_subnet" "sayankpublicsubnet" {
  vpc_id     = aws_vpc.sayankvpc.id
  cidr_block = var.publiccidr

  tags = {
    Name = "sayankpublicsubnet"
  }
}


# ing

resource "aws_internet_gateway" "sayankgw" {
  vpc_id = aws_vpc.sayankvpc.id

  tags = {
    Name = "sayankgw"
  }
}


#subnet-association

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.sayankpublicsubnet.id
  route_table_id = aws_route_table.sayankroute.id
}


#route

resource "aws_route_table" "sayankroute" {
  vpc_id = aws_vpc.sayankvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sayankgw.id
  }
  tags = {
    Name = "sayankroute"
  }
}



# private subnet

resource "aws_subnet" "sayankpvtsubnet" {
  vpc_id     = aws_vpc.sayankvpc.id
  cidr_block = var.pvtcidr

  tags = {
    Name = "sayankpvtsubnet"
  }
}


# Elastic iP

resource "aws_eip" "lb" {
  vpc = true
}


# nat gateway

resource "aws_nat_gateway" "sayanknatgw" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.sayankpvtsubnet.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.sayankgw]
}



# private route

resource "aws_route_table" "sayankpvtroute" {
  vpc_id = aws_vpc.sayankvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sayankgw.id
  }
  tags = {
    Name = "sayankroute"
  }
}

# private subnet-association

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.sayankpvtsubnet.id
  route_table_id = aws_route_table.sayankpvtroute.id
}


# private subnet for database

resource "aws_subnet" "sayankpvtsubnetdb" {
  vpc_id     = aws_vpc.sayankvpc.id
  cidr_block = var.pvtcidrdb

  tags = {
    Name = "sayankpvtsubnet"
  }
}


# Elastic iP

resource "aws_eip" "lb" {
  vpc = true
}


# nat gateway

resource "aws_nat_gateway" "sayanknatgwdb" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.sayankpvtsubnetdb

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.sayankgw]
}



# private route

resource "aws_route_table" "sayankpvtroutedb" {
  vpc_id = aws_vpc.sayankvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sayankgw.id
  }
  tags = {
    Name = "sayankroute"
  }
}

# private subnet-association

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.sayankpvtsubnetdb.id
  route_table_id = aws_route_table.sayankpvtroutedb.id
}



# create an security group

resource "aws_security_group" "sayanksg" {
  name        = "sayanksg"
  description = "Enable SSH access on Port 22"

  dynamic "ingress" {
    for_each = [22, 80, 443, 5000, 3000]
    iterator = port
    content {
      description = "TLS from VPC"
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# create an key pair

resource "aws_key_pair" "sayankkavision" {
  key_name = "sayankkavision"
  public_key = file("${path.module}/sayankkavision.pub")
}


# create an instance

resource "aws_instance" "sayankec2" {
  ami                         = "ami-0557a15b87f6559cf"
  instance_type               = "t2.micro"
  key_name                    = "sayankkavision"
  subnet_id                   = aws_subnet.sayankpublicsubnet.id
  vpc_security_group_ids      = [aws_security_group.sayanksw.id]
  associate_public_ip_address = true
 

  tags = {
    Name = "sayankec2"
  }

}

# Command run in ec2
  user_data = <<-EOF
          #!bin/bash
          sudo apt update
          sudo apt install mysql-server -y
          sudo systemctl status mysql
          sudo mysql
          sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'sayank1605';"
          exit
  EOF


# Connection Login to Ec2

connection {
  type        = "ssh"
  user        = "ubuntu"
  private_key = file("./sayank")
  host        = self.public_ip
}





