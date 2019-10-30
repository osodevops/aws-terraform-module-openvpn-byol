resource "aws_security_group" "openvpn-sg" {
  name        = "${var.environment}-OPENVPN-AS-SG"
  description = "Security group for all public internet traffic to the Openvpn server"
  vpc_id      = var.vpc_id

  # Client GUI
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Admin GUI
  ingress {
    from_port   = 943
    to_port     = 943
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Connect Client
  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-OPENVPN-AS-SG"
  }
}

resource "aws_security_group" "openvpn-rds-sg" {
  depends_on  = [aws_security_group.openvpn-sg]
  name        = "${var.environment}-OPENVPN-RDS-SG"
  description = "Security group for traffic to the OpenVPN RDS backend"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.environment}-OPENVPN-RDS-SG"
  }
}

resource "aws_security_group_rule" "openvpn-rds-ingress" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.openvpn-rds-sg.id
  source_security_group_id = aws_security_group.openvpn-sg.id
}

