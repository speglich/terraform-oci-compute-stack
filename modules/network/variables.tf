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

variable "ingress_security_rules" {
  description = "Ingress security rules for the public subnet"
  type = list(object({
    protocol        = string
    source          = string
    source_type     = string
    tcp_options     = optional(object({ min = number, max = number }))
    udp_options     = optional(object({ min = number, max = number }))
    icmp_options    = optional(object({ type = number, code = number }))
  }))
}

variable "network_name" {
  description = "Name of the network"
  type        =  string
}