data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_key_pair" "chave_ssh" {
  key_name   = "key-samba" # O nome que vai aparecer no console da AWS
  public_key = file("~/home/andre/Documentos/Projeto_Acme (Samba)/ssh/samba-key.pub")
}

resource "aws_instance" "srv_samba" {
 ami           = data.aws_ami.ubuntu.id
 instance_type = "t3.micro"
  private_ip    = "192.168.6.10"
  key_name      = "key-samba"
  subnet_id              = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.Acesso_Servidores.id]
  associate_public_ip_address = true

  tags = {
    Name = "SRV_SAMBA"
  }
}

resource "aws_instance" "srv_arquivos" {
 ami           = data.aws_ami.ubuntu.id
 instance_type = "t3.micro"
  private_ip    = "192.168.6.20"
  key_name      = "key-samba"
  subnet_id              = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.Acesso_Servidores.id]
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.file_server_profile.name
  user_data = <<-EOF
              #!/bin/bash
              echo "192.168.6.10 acme.local" >> /etc/hosts
              EOF
   
  tags = {
    Name = "SRV_ARQUIVOS"
  }
}

resource "aws_instance" "srv_grafana" {
 ami           = data.aws_ami.ubuntu.id
 instance_type = "t3.micro"
  private_ip    = "192.168.6.30"
  key_name      = "key-samba"
  subnet_id              = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.Acesso_Servidores.id]
  associate_public_ip_address = true
 
   tags = {
    Name = "SRV_GRAFANA"
  }
}


# Recurso para gerar o arquivo de inventário do Ansible automaticamente
#resource "local_file" "ansible_inventory" {
 # filename = "${path.module}/inventory.ini"
  
  # Altere "aws_instance.srv_samba" para o nome correto do seu recurso de EC2 no Terraform
  #content  = <<EOT
#[srv_samba]
#srv_samba ansible_host=${aws_instance.srv_samba.public_ip} ansible_user=ubuntu
#[srv_arquivos]
#srv_arquivos ansible_host=${aws_instance.srv_arquivos.public_ip} ansible_user=ubuntu
#EOT
#}
