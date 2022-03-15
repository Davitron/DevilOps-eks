variable "default_vpc_id" {
  description = "the id of default vpc"
}

variable "cidr" {
  type = string
}

variable "private_subnets_cidr" {
  type = list(string)
}


variable "public_subnets_cidr" {
  type = list(string)
}