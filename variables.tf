variable "region" {
  description = "OCI region where resources will be created"
  type        = string
  default     = "sa-saopaulo-1" # Default region, can be overridden in terraform.tfvars
}

variable "compartment_ocid" {
  description = "OCID of the compartment where resources will be created"
  type        = string
}

variable "profile" {
  description = "Profile from OCI CLI config file"
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
    setup_local_storage     = optional(bool, false)
  }))
  default = {
    "dense-io" = {
      shape                   = "BM.DenseIO2.52"
      public_ip               = true
      instance_count          = 1
      boot_volume_size_in_gbs = 50
      image_id                = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaanvwztmp6itiny5bbua4fdbnfocpkro77r45nymjo7ooqs3oi7f5q"
      ssh_user                = "opc"
      setup_docker            = false
      setup_nvidia_docker     = false
      setup_oci_growfs        = false
      setup_local_storage     = true
    }
    "cpu-node-public" = {
      shape                   = "VM.Standard.E5.Flex"
      instance_count          = 0
      ocpus                   = 1
      memory_in_gbs           = 8
      boot_volume_size_in_gbs = 50
      image_id                = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaanvwztmp6itiny5bbua4fdbnfocpkro77r45nymjo7ooqs3oi7f5q"
      ssh_user                = "opc"
      setup_docker            = true
      setup_nvidia_docker     = false
      setup_oci_growfs        = true
    },
    "cpu-node-private" = {
      shape                   = "VM.Standard.E5.Flex"
      public_ip               = false
      instance_count          = 0
      ocpus                   = 1
      memory_in_gbs           = 8
      boot_volume_size_in_gbs = 50
      image_id                = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaanvwztmp6itiny5bbua4fdbnfocpkro77r45nymjo7ooqs3oi7f5q"
      ssh_user                = "opc"
      setup_docker            = false
      setup_nvidia_docker     = false
      setup_oci_growfs        = true
    }
    "gpu-node" = {
      shape                   = "VM.GPU.A10.1"
      instance_count          = 0
      boot_volume_size_in_gbs = 150
      image_id                = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaauewtoydpxzbdp26dcpuqzp5cdgqadbcpb7a45zgt4vvfg2ztuaaq"
      ssh_user                = "opc"
      setup_docker            = true
      setup_nvidia_docker     = true
      setup_oci_growfs        = true
    }
  }
}