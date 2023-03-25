resource "aws_subnet" "airflow_priv_subnet1" {
  vpc_id                  = var.vpc_id
  cidr_block              = "172.31.64.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "mwaa-${var.environment_name}-private-subnet-1"
  }
}

resource "aws_subnet" "airflow_priv_subnet2" {
  vpc_id                  = var.vpc_id
  cidr_block              = "172.31.128.0/24"
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "mwaa-${var.environment_name}-private-subnet-2"
  }
}

resource "aws_route_table" "airflow_priv_route_table" {
  vpc_id = var.vpc_id
  route  = []

  tags = {
    Name = "mwaa-${var.environment_name}-private-routes-a"
  }
}

resource "aws_route_table_association" "airflow_route_table_asso_1" {
  subnet_id      = aws_subnet.airflow_priv_subnet1.id
  route_table_id = aws_route_table.airflow_priv_route_table.id
}

resource "aws_route_table_association" "airflow_route_table_asso_2" {
  subnet_id      = aws_subnet.airflow_priv_subnet2.id
  route_table_id = aws_route_table.airflow_priv_route_table.id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_endpoint_type = "Gateway"
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  route_table_ids   = [aws_route_table.airflow_priv_route_table.id]

  tags = {
    Name = "mwaa-${var.environment_name}-vpc-endpoint-s3"
  }
}

resource "aws_security_group" "airflow_sg" {
  vpc_id = var.vpc_id
  name   = "mwaa-${var.environment_name}-no-ingress-sg"
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "mwaa-${var.environment_name}-no-ingress-sg"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_endpoint_type = "Interface"
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.ecr.api"

  private_dns_enabled = true
  subnet_ids = [
    aws_subnet.airflow_priv_subnet1.id, aws_subnet.airflow_priv_subnet2.id
  ]
  security_group_ids = [aws_security_group.airflow_sg.id]

  tags = {
    Name = "mwaa-${var.environment_name}-vpc-endpoint-ecr-api"
  }
}

resource "aws_vpc_endpoint" "airflow_api" {
  vpc_endpoint_type = "Interface"
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.airflow.api"

  private_dns_enabled = true
  subnet_ids = [
    aws_subnet.airflow_priv_subnet1.id, aws_subnet.airflow_priv_subnet2.id
  ]
  security_group_ids = [aws_security_group.airflow_sg.id]

  tags = {
    Name = "mwaa-${var.environment_name}-vpc-endpoint-airflow-api"
  }
}

resource "aws_vpc_endpoint" "airflow_env" {
  vpc_endpoint_type = "Interface"
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.airflow.env"

  private_dns_enabled = true
  subnet_ids = [
    aws_subnet.airflow_priv_subnet1.id, aws_subnet.airflow_priv_subnet2.id
  ]
  security_group_ids = [aws_security_group.airflow_sg.id]

  tags = {
    Name = "mwaa-${var.environment_name}-vpc-endpoint-airflow-env"
  }
}

resource "aws_vpc_endpoint" "airflow_ops" {
  vpc_endpoint_type = "Interface"
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.airflow.ops"

  private_dns_enabled = true
  subnet_ids = [
    aws_subnet.airflow_priv_subnet1.id, aws_subnet.airflow_priv_subnet2.id
  ]
  security_group_ids = [aws_security_group.airflow_sg.id]

  tags = {
    Name = "mwaa-${var.environment_name}-vpc-endpoint-airflow-ops"
  }
}


