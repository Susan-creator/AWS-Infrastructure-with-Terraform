variable "cidr_block" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  description = "Instance type for EC2"
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key pair name for SSH access"
  default     = "all-key-pair"
}

variable "ami_id" {
    description = "ami id"
    default = "ami-0866a3c8686eaeeba"
  
}