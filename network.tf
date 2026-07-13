resource "aws_vpc" "main" {
    cidr_block  =   var.vpc_cidr
    enable_dns_hostnames    =   true
    tags    =   { 
        Name = "VPC_Principal"
        }
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id        = aws_vpc.main.id
  service_name  = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"

  tags = {
    Name        = "acme-vpc-endpoint-s3"
    Environment = "Production"
  }
}

resource "aws_subnet" "private" {
    count = length(var.private_subnets_cidr)
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnets_cidr[count.index]
    map_public_ip_on_launch = true
    tags = {
        Name = "Subnet_Principal"
    }

}

resource "aws_vpc_endpoint_route_table_association" "s3_endpoint_assoc" {
  route_table_id  = aws_route_table.private_route.id
  vpc_endpoint_id = aws_vpc_endpoint.s3_endpoint.id
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "IGW" 
    }
}

resource "aws_route_table" "private_route" {
    vpc_id = aws_vpc.main.id
    route { 
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "Tabela_Rota_Privada"
    }
}

# ==============================================================================
# ARQUITETURA DE REDE HÍBRIDA: VPN SITE-TO-SITE (PRODUÇÃO)
# ==============================================================================
# NOTA PARA O PORTFÓLIO: Os blocos abaixo configuram a conectividade híbrida segura
# via túneis IPSec redundantes, interligando a infraestrutura AWS à rede local 
# (on-premises) da corporação. Foram comentados neste laboratório para mitigação 
# de custos com conexões ativas gerenciadas na AWS.
# ==============================================================================

# 1. Registro do IP público do firewall/roteador da rede local física na AWS
# resource "aws_customer_gateway" "acme_fisica" {
#   bgp_asn    = 65000
#   ip_address = "131.100.123.241" # IP público fixo real do gateway on-premises
#   type       = "ipsec.1"
# 
#   tags = {
#     Name        = "acme-customer-gateway"
#     Environment = "Production"
#   }
# }

# 2. Criação do Virtual Private Gateway (VGW) acoplado à VPC da AWS
# resource "aws_vpn_gateway" "vpn_gw" {
#   vpc_id = aws_vpc.main.id # ID da VPC gerenciada pelo Terraform
# 
#   tags = {
#     Name        = "acme-virtual-private-gateway"
#     Environment = "Production"
#   }
# }

# 3. Criação da conexão VPN IPSec (Gera automaticamente os 2 túneis redundantes da AWS)
# resource "aws_vpn_connection" "site_to_site" {
#   vpn_gateway_id      = aws_vpn_gateway.vpn_gw.id
#   customer_gateway_id = aws_customer_gateway.acme_fisica.id
#   type                = "ipsec.1"
#   static_routes_only  = true
# 
#   tags = {
#     Name        = "acme-vpn-site-to-site"
#     Environment = "Production"
#   }
# }

# 4. Definição da rota estática que aponta para o bloco CIDR interno da rede local
# resource "aws_vpn_connection_route" "rota_empresa_local" {
#   destination_cidr_block = "192.168.3.0/24" # Bloco de IPs interno da rede on-premises
#   vpn_connection_id      = aws_vpn_connection.site_to_site.id
# }

# 5. Ativação da propagação automática de rotas na tabela de roteamento privada
# resource "aws_vpn_gateway_route_propagation" "propagar_rotas" {
#   vpn_gateway_id = aws_vpn_gateway.vpn_gw.id
#   route_table_id = aws_route_table.private.id # Tabela de rotas da sub-rede privada
# }


#Grupos de Segurança


resource "aws_security_group" "Acesso_Servidores" {
    name = "SG_SERVIDORES"
    description = "Grupo de Seguranca para o Servidores"
    vpc_id = aws_vpc.main.id

    #Obs: todas as portas estão sendo liberadas no bloco ["0.0.0.0/0"] para fim de testes de laboratorio, porém o ideal é no lugar colocar o bloco de IP do local
    #onde as estações estão conectadas para acessarem o servidor.
  ingress {
    description = "Acesso grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Acesso Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    description = "Acesso grafana"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    description = "Acesso SSH para Ansible e Administracao"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # --- PORTAS DO ACTIVE DIRECTORY & SAMBA ---
  ingress {
    description = "DNS (Samba AD gerencia as zonas)"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "DNS sobre UDP"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kerberos Authentication"
    from_port   = 88
    to_port     = 88
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kerberos Authentication sobre UDP"
    from_port   = 88
    to_port     = 88
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "NTP (Sincronismo de horario eh critico para o AD)"
    from_port   = 123
    to_port     = 123
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "NetBIOS Name Service"
    from_port   = 137
    to_port     = 137
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "NetBIOS Datagram Service"
    from_port   = 138
    to_port     = 138
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "NetBIOS Session Service / SAMBA"
    from_port   = 139
    to_port     = 139
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "LDAP Server"
    from_port   = 389
    to_port     = 389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "LDAP Server sobre UDP"
    from_port   = 389
    to_port     = 389
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SMB sobre IP (Compartilhamento de arquivos e GPOs)"
    from_port   = 445
    to_port     = 445
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kerberos Password Change"
    from_port   = 464
    to_port     = 464
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kerberos Password Change sobre UDP"
    from_port   = 464
    to_port     = 464
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "LDAPS (LDAP Seguro)"
    from_port   = 636
    to_port     = 636
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Active Directory Global Catalog"
    from_port   = 3268
    to_port     = 3269
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Portas RPC Dinâmicas (Samba usa para replicação e comunicação RPC do AD)
  ingress {
    description = "Samba RPC Dinamico"
    from_port   = 1024
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # --- SAÍDA LIVRE ---
  egress {
    description = "Permitir toda saida para a internet baixar pacotes"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG_SERVERS"
  }
}


# ==============================================================================
# ARQUITETURA DE REDE PRIVADA E NAT GATEWAY (PRODUÇÃO)
# ==============================================================================
# NOTA PARA O PORTFÓLIO: Os blocos abaixo mapeiam a infraestrutura ideal de produção,
# isolando os servidores em sub-redes privadas. Foram comentados neste laboratório
# estritamente para otimização de custos com recursos gerenciados da AWS.
# ==============================================================================

# 1. Alocação de IP Estático (EIP) para o NAT Gateway
# resource "aws_eip" "nat_eip" {
#   domain = "vpc"
#   tags = {
#     Name = "acme-nat-eip"
#   }
# }

# 2. Criação do NAT Gateway na Sub-rede Pública
# resource "aws_nat_gateway" "nat_gw" {
#   allocation_id = aws_eip.nat_eip.id
#   subnet_id     = aws_subnet.sua_subnet_publica.id # Deve ficar na subnet pública
#   tags = {
#     Name = "acme-nat-gateway"
#   }
# }

# 3. Tabela de Rotas para a Sub-rede Privada
# resource "aws_route_table" "private_rt" {
#   vpc_id = aws_vpc.sua_vpc.id
#   tags = {
#     Name = "acme-private-route-table"
#   }
# }

# 4. Rota padrão enviando tráfego de internet para o NAT Gateway
# resource "aws_route" "private_internet_route" {
#   route_table_id         = aws_route_table.private_rt.id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = aws_nat_gateway.nat_gw.id
# }

# 5. Associação da Tabela de Rotas Privada com a Sub-rede Privada
# resource "aws_route_table_association" "private_assoc" {
#   subnet_id      = aws_subnet.sua_subnet_privada.id
#   route_table_id = aws_route_table.private_rt.id
# }