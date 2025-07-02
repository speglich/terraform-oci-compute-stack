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

variable "shapes" {
  description = "List of shapes to use for the instances"
  type = map(object({
    shape                   = string
    instance_count          = optional(number, 1) # Default to 1 if not specified
    ocpus                   = optional(number)
    memory_in_gbs           = optional(number)
    boot_volume_size_in_gbs = number
    image_id                = string
  }))
}