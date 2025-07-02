variable "compartment_ocid" {
  description = "OCID of the compartment where resources will be created"
  type        = string
}

variable "vcn_cidr" {
  description = "CIDR block for the VCN"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
}

variable "exposed_ports" {
  description = "List of ports to expose"
  type        = list(number)
}

variable "network_name" {
  description = "Name of the network"
  type        =  string
}