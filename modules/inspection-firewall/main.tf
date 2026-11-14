resource "aws_security_group" "wan" {
  name        = "${var.environment}-wan-sg"
  description = "Allow inbound external traffic to firewall WAN"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.environment}-wan-sg" }
}

resource "aws_security_group" "transit" {
  name        = "${var.environment}-transit-sg"
  description = "Allow internal inspection traffic from TGW"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.environment}-transit-sg" }
}

resource "aws_security_group" "management" {
  name        = "${var.environment}-mgmt-sg"
  description = "Allow administrative access to pfSense GUI/SSH"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.environment}-mgmt-sg" }
}

# 1. WAN Network Interface
resource "aws_network_interface" "wan" {
  subnet_id         = var.public_subnet_ids[0]
  private_ips       = ["10.200.0.10"]
  security_groups   = [aws_security_group.wan.id]
  source_dest_check = false

  tags = { Name = "eni-${var.environment}-wan-0" }
}

# 2. Transit Network Interface (Falls within 10.200.0.64/27)
resource "aws_network_interface" "transit" {
  subnet_id         = var.transit_subnet_ids[0]
  private_ips       = ["10.200.0.72"]
  security_groups   = [aws_security_group.transit.id]
  source_dest_check = false

  tags = { Name = "eni-${var.environment}-transit-0" }
}

# 3. Management Network Interface (Falls within 10.200.0.128/27)
resource "aws_network_interface" "management" {
  subnet_id         = var.management_subnet_ids[0]
  private_ips       = ["10.200.0.138"]
  security_groups   = [aws_security_group.management.id]
  source_dest_check = true

  tags = { Name = "eni-${var.environment}-mgmt-0" }
}

# 4. pfSense EC2 Instance with Primary WAN ENI bound inline at launch
resource "aws_instance" "pfsense" {
  ami           = var.pfsense_ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interface {
    network_interface_id = aws_network_interface.wan.id
    device_index         = 0
  }

  tags = { Name = "ec2-${var.environment}-pfsense-01" }
}

# Secondary Interface Attachments
resource "aws_network_interface_attachment" "transit" {
  instance_id          = aws_instance.pfsense.id
  network_interface_id = aws_network_interface.transit.id
  device_index         = 1
}

resource "aws_network_interface_attachment" "management" {
  instance_id          = aws_instance.pfsense.id
  network_interface_id = aws_network_interface.management.id
  device_index         = 2
}

# Dedicated Elastic IP for WAN (Dependent on the instance provisioning)
resource "aws_eip" "wan" {
  domain     = "vpc"
  depends_on = [aws_instance.pfsense]

  tags = { Name = "${var.environment}-pfsense-wan-eip" }
}

resource "aws_eip_association" "wan" {
  allocation_id        = aws_eip.wan.id
  network_interface_id = aws_network_interface.wan.id
}

