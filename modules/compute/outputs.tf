output "ssh_private_key" {
  value     = local_file.private_key.filename
}

output "instances" {
  value = {
    for name, instance in oci_core_instance.instances :
    name => {
      shape_config = local.instances_expanded[name]
      public_ip    = instance.public_ip
    }
  }
}