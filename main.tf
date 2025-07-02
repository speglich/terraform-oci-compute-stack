module "network" {
  source              = "./modules/network"
  compartment_ocid    = var.compartment_ocid
  vcn_cidr            = "10.0.0.0/16"
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
  network_name        = local.environment_name
  exposed_ports       = [22]
}

module "compute" {
  source              = "./modules/compute"
  compartment_ocid    = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  public_subnet_id    = module.network.public_subnet_id
  shapes              = var.shapes
}

module "tools" {
  source              = "./modules/tools"
  ssh_private_key     = module.compute.ssh_private_key
  shapes              = module.compute.instances
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}