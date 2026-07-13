output "ec2_private_ip"{
  description = "IP público da instância do srv_samba"
  value       = aws_instance.srv_samba.private_ip
}

# Output que exibe apenas o IP público atual da máquina
output "instancia_ip_publico" {
  description = "O IP público atual do servidor Samba AD"
  value       = aws_instance.srv_samba.public_ip # Substitua 'sua_ec2' pelo nome do seu resource
}

# Output mágico que já gera a linha formatada para o inventário do Ansible
output "linha_inventario_srv_samba" {
  description = "Copie e cole esta linha diretamente dentro do seu arquivo inventory.ini"
  value       = "srv_samba ansible_host=${aws_instance.srv_samba.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=./samba-key.pem"
    # Dica: Substitua './sua-chave.pem' pelo caminho real do seu arquivo de chave
}
output "linha_inventario_srv_arquivos" {
  description = "Copie e cole esta linha diretamente dentro do seu arquivo inventory.ini"
  value       = "srv_arquivos ansible_host=${aws_instance.srv_arquivos.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=./samba-key.pem"
    # Dica: Substitua './sua-chave.pem' pelo caminho real do seu arquivo de chave
}
output "linha_inventario_srv_grafana" {
  description = "Copie e cole esta linha diretamente dentro do seu arquivo inventory.ini"
  value       = "srv_grafana ansible_host=${aws_instance.srv_grafana.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=./samba-key.pem"
    # Dica: Substitua './sua-chave.pem' pelo caminho real do seu arquivo de chave
}