    pipeline {
    agent any

    environment {
        // O Terraform reconhece essas variáveis de ambiente automaticamente para autenticar na AWS
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
        AWS_DEFAULT_REGION    = 'us-east-1' // Altere para a região do seu projeto
    }

    stages {
        stage('Sincronizar Código') {
            steps {
                echo 'Buscando a última versão do código no GitHub...'
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                echo 'Inicializando o Terraform dentro do container...'
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                echo 'Gerando o plano de execução da infraestrutura...'
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Aprovação Manual') {
            steps {
                // Esta etapa pausa a esteira e espera você clicar em "Prosseguir" no painel do Jenkins
                input message: 'Deseja aplicar as alterações de infraestrutura na AWS?', ok: 'Sim, aplicar!'
            }
        }

        stage('Terraform Apply') {
            steps {
                echo 'Aplicando as alterações na nuvem...'
                sh 'terraform apply -auto-approve tfplan'
            }
        }

        stage('Ansible Configuration') {
            steps {
                echo 'Iniciando o Ansible para configurar os servidores...'
                // Exemplo de execução do playbook apontando para o inventário gerado
                // sh 'ansible-playbook -i inventory.ini playbook.yml'
                echo 'Infraestrutura configurada com sucesso pelo Ansible!'
            }
        }
    }

    post {
        always {
            echo 'Limpando o workspace...'
            // Remove arquivos temporários sensíveis, como o plano local
            sh 'rm -f tfplan'
        }
        success {
            echo 'Parabéns! O deploy do projeto ACME foi concluído com sucesso!'
        }
        failure {
            echo 'O pipeline falhou. Verifique a Saída do Console para investigar os erros.'
        }
    }
}