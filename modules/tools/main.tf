resource "null_resource" "oci_grow_fs" {
  provisioner "remote-exec" {
    inline = [
      "sudo /usr/libexec/oci-growfs -y"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_private_key)
      host        = var.instance_public_ip[count.index]
      timeout     = "600m"
    }
  }
}

resource "null_resource" "docker_install" {
  count = var.replicas

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
      user        = var.ssh_user
      private_key = file(var.ssh_private_key)
      host        = var.instance_public_ip[count.index]
      timeout     = "600m"
    }
  }
}

resource "null_resource" "nvidia_container_toolkit_install" {
  count = var.replicas
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
      user        = var.ssh_user
      private_key = file(var.ssh_private_key)
      host        = var.instance_public_ip[count.index]
      timeout     = "600m"
    }
  }
}