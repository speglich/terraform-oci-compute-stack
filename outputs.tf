output "instances_summary" {
  description = "Summary of all instances with their public and private IPs"
  value = {
    for name, instance in module.compute.instances :
    name => {
      public_ip  = instance.public_ip
      private_ip = instance.private_ip
      shape      = instance.shape_config.shape
    }
  }
}