variable "compartment_ocid" {
    description = "OCID of the compartment where resources will be created"
    type        = string
}

variable "availability_domain" {
    description = "Availability domain where resources will be created"
    type        = string
}

variable "public_subnet_id" {
    description = "OCID of the public subnet"
    type        = string
}

variable "private_subnet_id" {
    description = "OCID of the private subnet"
    type        = string
}

variable "shapes" {
  description = "List of shapes to use for the instances"
  type = map(object({
    shape                   = string
    public_ip               = optional(bool, true)
    instance_count          = optional(number, 1)
    ocpus                   = optional(number)
    memory_in_gbs           = optional(number)
    boot_volume_size_in_gbs = number
    image_id                = string
    ssh_user                = string
    setup_docker            = optional(bool, true)
    setup_nvidia_docker     = optional(bool, false)
    setup_oci_growfs        = optional(bool, true)
  }))
}