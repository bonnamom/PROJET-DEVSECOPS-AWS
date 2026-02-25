# 1. Création du groupe de sécurité (Le Pare-feu)
resource "aws_security_group" "web_sg" {
  name        = "sg_projet_fil_rouge"
  description = "Autorise le trafic SSH et HTTP"
  vpc_id      = aws_vpc.main_vpc.id # On le lie à ton VPC créé précédemment

  # Règle d'entrée : Autoriser le SSH (Port 22)
  ingress {
    description      = "SSH depuis mon IP"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] # /!\ Note SecOps : On l'ouvrira à tout le monde pour l'instant
  }

  # Règle d'entrée : Autoriser le HTTP (Port 80) pour ton app Symfony/Vue.js
  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  # Règle de sortie : Autoriser tout le trafic vers l'extérieur
  # Indispensable pour que le serveur puisse télécharger Docker, Symfony, etc.
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1" # Signifie "Tous les protocoles"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-web-fil-rouge"
  }
}