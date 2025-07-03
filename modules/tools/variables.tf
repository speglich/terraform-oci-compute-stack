variable "shapes" {
  description = "List of shapes to use for the instances"
  type = map(object({
    shape_config = object({
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
      setup_local_storage     = optional(bool, false)
    })
    public_ip = string
    private_ip = optional(string, null)
  }))
}

variable "ssh_private_key" {
    description = "SSH private key for accessing the instance"
    type        = string
}