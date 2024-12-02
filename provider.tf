# Définition du provider cloud AWS
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.32.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "3.4.0"
    }
  }
}
# Définition du backend S3 afin de stocker le .tfstate (liste des éléments déployés) dans le cloud 
# terraform {
#   backend "s3" {
#     key    = "terraformstate/terraformeks.tfstate"
#     encrypt        = true
#   }
# }

# resource "aws_s3_bucket" "terraform_state" {
#   bucket = "my-terraform-state-bucket" # Remplacez par le nom unique du bucket
#   acl    = "private"

#   versioning {
#     enabled = true
#   }

#   tags = {
#     Name        = "TerraformState"
#     Environment = "Dev"
#   }
# }

# # Optionnel : Créer une table DynamoDB pour gérer les verrous
# resource "aws_dynamodb_table" "terraform_locks" {
#   name         = "terraform-locks"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }

#   tags = {
#     Name        = "TerraformLocks"
#     Environment = "Dev"
#   }
# }

# # Configurer le backend pour utiliser le bucket S3 et DynamoDB
# terraform {
#   backend "s3" {
#     bucket         = "my-terraform-state-bucket"  # Remplacez par le nom de votre bucket
#     key            = "terraform/state.tfstate"   # Chemin dans le bucket
#     region         = "us-west-2"                 # Remplacez par la région de votre bucket
#     dynamodb_table = "terraform-locks"           # Table DynamoDB pour le verrouillage
#     encrypt        = true                        # Chiffre les fichiers tfstate
#   }
# }