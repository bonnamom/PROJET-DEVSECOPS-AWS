# On déclare la clé publique pour AWS
resource "aws_key_pair" "deployer" {
  key_name   = "ma-cle-projet"
  public_key = file("~/.ssh/id_rsa.pub")
}

# 1. Définition des noms de nos environnements
variable "env_names" {
  type    = list(string)
  default = ["dev", "test", "prod"]
}

# 2. Récupérer l'ID de la dernière image Ubuntu disponible sur AWS
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # ID officiel de Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# 3. Création des instances EC2
resource "aws_instance" "my_servers" {
  # [SKIP CHECHOV] On autorise l'IP publique pour permettre l'accès direct via Ansible 
  # dans ce cadre de formation (Alternative réelle : Bastion ou VPN).
  # checkov:skip=CKV_AWS_88: IP publique necessaire pour l'acces Ansible direct
  # checkov:skip=CKV2_AWS_41: Pas de role IAM necessaire pour ce cas d'usage simple
  
  count         = length(var.env_names)
  
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro" 

  associate_public_ip_address = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required" # Force IMDSv2
  }

  monitoring = true
  ebs_optimized = true

  root_block_device {
    encrypted = true
    # [SKIP CHECHOV] Optionnel : evite une alerte si Checkov demande une cle KMS specifique
    # checkov:skip=CKV_AWS_3: Utilisation du chiffrement par defaut AWS amplement suffisant ici
  }

  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "server-${var.env_names[count.index]}"
  }

  key_name      = aws_key_pair.deployer.key_name
}