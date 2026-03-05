# 1. Création du groupe de sécurité (Le Pare-feu)
resource "aws_security_group" "web_sg" {
  # checkov:skip=CKV_AWS_260: Port 80 volontairement ouvert pour l'app Symfony/Vue
  # checkov:skip=CKV_AWS_382: Egress illimite pour permettre les updates packages/Docker
  name        = "sg_projet_fil_rouge"
  description = "Autorise le trafic SSH et HTTP"
  vpc_id      = aws_vpc.main_vpc.id

  # [CORRECTION CKV_AWS_24 & CKV_AWS_23] 
  # Règle d'entrée : Autoriser le SSH uniquement depuis ton IP
  ingress {
    description      = "SSH restreint a mon IP uniquement"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    
    # Pour l'exercice et la validation Checkov, on evite le 0.0.0.0/0
    cidr_blocks      = ["90.90.236.101/32"] 
  }

  # [CORRECTION CKV_AWS_23]
  # Règle d'entrée : Autoriser le HTTP (Port 80)
  ingress {
    description      = "Acces HTTP public pour application web"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] # CKV_AWS_260 restera en failed car il prefere le HTTPS (443)
  }

  # [CORRECTION CKV_AWS_23]
  # Règle d'entrée : Port 5432 pour PostgreSQL (uniquement entre membres du meme SG)
  ingress {
    description = "Acces PostgreSQL interne au groupe de securite"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    self        = true
  }

  # [CORRECTION CKV_AWS_23 & CKV_AWS_382]
  # Règle de sortie : On limite souvent la sortie, mais ici on ajoute au moins une description
  egress {
    description      = "Autorise toute la sortie vers Internet pour mises a jour et Docker"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-web-fil-rouge"
  }
}