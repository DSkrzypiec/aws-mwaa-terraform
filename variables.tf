variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "ExampleAppServerInstance"
}

variable "environment_name" {
  description = "Name of the environemnt"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "account-id" {
  description = "AWS account ID"
  type        = string
  default     = "605411976919"
}

variable "vpc_id" {
  description = "Main VPC_ID"
  type        = string
  default     = "vpc-0cb5c7e1d57103459"
}

