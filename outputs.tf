output "public_instance_ip" {
  value = [for instance in module.compute.instances : instance.public_ip]
}