output "public_instance_ip" {
  value = [ for instance in oci_core_instance.instances : instance.public_ip ]
}

output "ssh_private_key" {
  value     = local_file.private_key.filename
}