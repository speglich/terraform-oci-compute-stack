variable "setup_docker" {
    description = "Whether to set up Docker on the instance"
    default     = true
    type        = bool
}
variable "setup_nvidia_container_toolkit" {
    description = "Whether to set up NVIDIA container toolkit on the instance"
    default     = true
    type        = bool
}
variable "instance_public_ip" {
    description = "Public IP address of the instance"
    type        = list(string)
}
variable "ssh_user" {
    description = "SSH user for accessing the instance"
    default     = "opc"
    type        = string
}
variable "ssh_private_key" {
    description = "SSH private key for accessing the instance"
    type        = string
}
variable "replicas" {
  type    = number
  default = 1
}