resource "null_resource" "oci_grow_fs" {
  for_each = {
    for name, shape in var.shapes :
    name => {
      public_ip = shape.public_ip
      ssh_user  = shape.shape_config.ssh_user
    }
    if try(shape.shape_config.setup_oci_growfs, true)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo /usr/libexec/oci-growfs -y"
    ]

    connection {
      type        = "ssh"
      user        = each.value.ssh_user
      private_key = file(var.ssh_private_key)
      host        = each.value.public_ip
      timeout     = "600m"
    }
  }
}

resource "null_resource" "docker_install" {
  for_each = {
    for name, shape in var.shapes :
    name => {
      public_ip = shape.public_ip
      ssh_user  = shape.shape_config.ssh_user
    }
    if try(shape.shape_config.setup_docker, true) || try(shape.shape_config.setup_nvidia_docker, false)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo dnf -y install dnf-plugins-core",
      "sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo",
      "sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
      "sudo systemctl enable --now docker",
      "sudo groupadd docker",
      "sudo usermod -aG docker $USER"
    ]

    connection {
      type        = "ssh"
      user        = each.value.ssh_user
      private_key = file(var.ssh_private_key)
      host        = each.value.public_ip
      timeout     = "600m"
    }
  }
}

resource "null_resource" "nvidia_container_toolkit_install" {
  for_each = {
    for name, shape in var.shapes :
    name => {
      public_ip = shape.public_ip
      ssh_user  = shape.shape_config.ssh_user
    }
    if try(shape.shape_config.setup_nvidia_docker, false)
  }

  depends_on = [ null_resource.docker_install ]

  provisioner "remote-exec" {
    inline = [
      "curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo",
      "sudo dnf-config-manager --enable nvidia-container-toolkit-experimental",
      "sudo dnf install -y nvidia-container-toolkit",
      "sudo nvidia-ctk runtime configure --runtime=docker",
      "sudo systemctl restart docker",
    ]

    connection {
      type        = "ssh"
      user        = each.value.ssh_user
      private_key = file(var.ssh_private_key)
      host        = each.value.public_ip
      timeout     = "600m"
    }
  }
}

resource "null_resource" "create_raid0" {
  for_each = {
    for name, shape in var.shapes :
    name => {
      public_ip = shape.public_ip
      ssh_user  = shape.shape_config.ssh_user
    }
    if try(shape.shape_config.setup_local_storage, false)
  }

  provisioner "file" {
    source      = "${path.module}/scripts/create_raid0.sh"
    destination = "/tmp/create_raid0.sh"

    connection {
      type        = "ssh"
      user        = each.value.ssh_user
      private_key = file(var.ssh_private_key)
      host        = each.value.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/create_raid0.sh",
      "sudo /tmp/create_raid0.sh"
    ]

    connection {
      type        = "ssh"
      user        = each.value.ssh_user
      private_key = file(var.ssh_private_key)
      host        = each.value.public_ip
    }
  }
}
