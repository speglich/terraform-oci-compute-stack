# This module creates a public compute instance in OCI with the specified shape and configuration.
# It uses a dynamic block to configure the shape and memory for flex shapes.
# The instance is created in the specified compartment and availability domain.
# The instance is assigned a public IP address and uses the provided SSH public key for access.


locals {
  instances_expanded = merge([
    for shape_key, shape_config in var.shapes : {
      for i in range(shape_config.instance_count) :
      "${shape_key}-${i}" => shape_config
    }
  ]...)
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content          = tls_private_key.ssh_key.private_key_pem
  filename         = "${path.root}/keys/oci_instance_key.pem"
  file_permission  = "0600"
}

resource "oci_core_instance" "instances" {
  for_each = local.instances_expanded

  compartment_id      = var.compartment_ocid
  availability_domain = var.availability_domain
  shape               = each.value.shape
  display_name        = each.key

  dynamic "shape_config" {
    for_each = (
       each.value.ocpus != null
      && each.value.memory_in_gbs != null
    ) ? [1] : []

    content {
      ocpus         = each.value.ocpus
      memory_in_gbs = each.value.memory_in_gbs
    }
  }

  source_details {
    source_type              = "image"
    source_id                = each.value.image_id
    boot_volume_size_in_gbs = each.value.boot_volume_size_in_gbs
  }

  create_vnic_details {
    subnet_id        = var.public_subnet_id
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = tls_private_key.ssh_key.public_key_openssh
  }
}