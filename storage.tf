# 1. Cria o Bucket S3
resource "aws_s3_bucket" "bucket_arquivos" {
  bucket = "acme-arquivos-backup-09072026"
}

# 1. Criar o Bucket S3 para armazenar os backups
resource "aws_s3_bucket" "backup_bucket" {
  bucket = "acme-arquivos-backup-09072026"

  tags = {
    Name        = "S3-Backup-ACME"
    Environment = "Dev"
  }
}

# 2. Criar a IAM Policy com as permissões restritas ao Bucket
resource "aws_iam_policy" "s3_backup_policy" {
  name        = "ACMEFileServerS3BackupPolicy"
  description = "Permite que o servidor de arquivos envie backups para o S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          "${aws_s3_bucket.backup_bucket.arn}",
          "${aws_s3_bucket.backup_bucket.arn}/*"
        ]
      }
    ]
  })
}

# 3. Criar a IAM Role que a instância EC2 vai assumir
resource "aws_iam_role" "s3_backup_role" {
  name = "ACMEFileServerS3BackupRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# 4. Anexar a Policy na Role criada
resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.s3_backup_role.name
  policy_arn = aws_iam_policy.s3_backup_policy.arn
}

# 5. Criar o Instance Profile (o "conector" entre a Role e a instância EC2)
resource "aws_iam_instance_profile" "file_server_profile" {
  name = "ACMEFileServerInstanceProfile"
  role = aws_iam_role.s3_backup_role.name
}