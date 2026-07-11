# Projeto ACME: Infraestrutura Híbrida e Servidor de Arquivos Seguro na AWS

Este repositório contém os arquivos de configuração (Terraform e Ansible) para a implementação da infraestrutura de rede, conectividade híbrida e servidores de arquivos do **Projeto ACME**. O foco central deste projeto é fornecer um ambiente corporativo robusto, altamente seguro, isolado e financeiramente otimizado na nuvem AWS.

![Arquitetura do Projeto](images/arquitetura.png)

## 🎯 Cenário e Desafio Técnico
O objetivo do projeto é estruturar a infraestrutura de TI de uma organização de forma híbrida, integrando a rede local (*on-premises*) à nuvem AWS de maneira totalmente privada. Os servidores críticos (Controlador de Domínio e Servidor de Arquivos) precisavam ser migrados/estruturados na nuvem, mas sem qualquer exposição à internet pública e mitigando custos tradicionais de licenciamento de software.

---

## 💡 Destaques de Arquitetura e Decisões Técnicas

### 1. Otimização de Custos (Samba AD vs. Windows Server)
Para eliminar a necessidade de licenças comerciais caras (CALs de Windows Server), o ambiente utiliza o **Samba 4** rodando em instâncias Ubuntu Server. 
* **Active Directory Nativo:** O Samba foi configurado para atuar como um Controlador de Domínio (DC) compatível com o protocolo Active Directory da Microsoft.
* **Gerenciamento Centralizado:** Permite o gerenciamento completo de políticas, ingresso de dispositivos no domínio, criação de usuários e grupos utilizando as ferramentas de gerenciamento padrão do Windows (RSAT).
* **Servidor de Arquivos com Permissões ACL:** O compartilhamento de rede é controlado via Samba, aplicando permissões detalhadas de acesso a pastas com base nos grupos de usuários do domínio, mantendo a governança dos dados idêntica a um ambiente Windows tradicional.

### 2. Isolamento de Rede e Segurança Corporativa
* **VPC Privada:** Toda a computação (instâncias EC2 para Samba e Servidor de Arquivos) está isolada dentro de uma **Sub-rede Privada (192.168.6.0/24)**. Nenhuma máquina possui endereço IP público associado.
* **Segurança de Borda (Security Groups):** O tráfego de entrada é restrito no nível do Security Group, permitindo apenas a comunicação legítima vinda da rede corporativa local ou entre os próprios servidores internos.

### 3. Conectividade Híbrida Segura (VPN Site-to-Site)
* A comunicação entre a matriz física da empresa (`192.168.5.0/24`) e a AWS é feita exclusivamente através de uma **VPN Site-to-Site** baseada em túneis IPSec redundantes e criptografados.
* A infraestrutura do Terraform já mapeia o **Customer Gateway (CGW)** e o **Virtual Private Gateway (VGW)**, garantindo que o tráfego corporativo nunca trafegue de forma exposta na internet.
* *Nota de Laboratório:* As estruturas de VPN e NAT Gateway encontram-se mapeadas e documentadas no código Terraform, porém comentadas para controle e otimização de custos de manutenção do laboratório.

### 4. Backup Eficiente e FinOps (VPC Endpoint para S3)
* O servidor de arquivos realiza rotinas automatizadas de backup incremental para um **Bucket Amazon S3** via AWS CLI.
* **Tráfego 100% Interno e Gratuito:** Em vez de utilizar a internet ou um NAT Gateway pago para enviar os dados ao S3, a arquitetura utiliza um **VPC Endpoint do tipo Gateway**. Isso força o tráfego do backup a correr estritamente por dentro da rede global interna da AWS, garantindo latência ultrabaixa, segurança total contra interceptações e custo zero de transferência de dados.
* **Autenticação Segura:** As instâncias EC2 não utilizam credenciais estáticas (`AWS_ACCESS_KEY_ID`) salvas em arquivos. O acesso ao bucket é concedido dinamicamente através de uma **IAM Role** anexada diretamente ao perfil do servidor.

---

## 🛠️ Tecnologias Utilizadas

* **Provedor de Nuvem:** AWS (VPC, EC2, S3, VPC Endpoints, VPN Site-to-Site, IAM)
* **Infraestrutura como Código (IaC):** Terraform
* **Gerenciamento de Configuração:** Ansible
* **Sistemas Operacionais:** Ubuntu Server
* **Serviços de Rede:** Samba 4 (Active Directory Domain Services / SMB)
* **Modelagem:** Draw.io