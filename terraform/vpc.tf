# 1. Création du réseau privé
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-projet-fil-rouge"
  }
}

# 2. Création de la porte d'entrée Internet
resource "aws_internet_gateway" "main_gw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "igw-projet-fil-rouge"
  }
}

# 3. Création d'une zone pour nos serveurs (Le sous-réseau)
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true # Pour accéder aux serveurs en SSH plus tard
  availability_zone       = "eu-west-3a"

  tags = {
    Name = "subnet-public"
  }
}

# 4. Table de routage
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_gw.id
  }
}

# 5. Association de la table au sous-réseau
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}