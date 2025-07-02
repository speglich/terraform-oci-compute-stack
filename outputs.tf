output "public_instance_ip" {
  value = [for ip in module.compute.public_instance_ip : ip]
}