terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.2-rc07"
    }
  }
}

provider "proxmox" {
  pm_api_url          = "https://${var.proxmox_host}:8006/api2/json"
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure     = true
}


resource "proxmox_lxc" "build_front" {
  vmid       = var.vmid_build_front
  hostname   = "build-front"
  target_node = "proxmox"

  ostemplate = "local:vztmpl/alpine-3.22-default_20250617_amd64.tar.xz"

  cores      = 4
  memory     = 4096
  swap       = 256
  
  rootfs {
    storage = var.proxmox_disk
    size    = "5G"
  }
  
  network {
    name   = "eth0"
    bridge = "vmbr0"
    gw     = var.gateway_ip
    ip     = "${var.build_front_ip}/24"
    ip6    = "auto"
  }

  unprivileged = false
  start = true
  password = var.node_pass_build

}
resource "null_resource" "setup_ssh_build_front" {
  depends_on = [proxmox_lxc.build_front]

  provisioner "local-exec" {
    command = <<EOT
ssh-keygen -f ~/.ssh/known_hosts -R ${var.build_front_ip}
sleep 15
sshpass -p "${var.proxmox_password}" \
ssh -o StrictHostKeyChecking=no \
    -o HostKeyAlgorithms=+ssh-rsa \
    -o PubkeyAcceptedAlgorithms=+ssh-rsa \
    root@${var.proxmox_host} \
    "pct exec ${var.vmid_build_front} -- apk update &&
     pct exec ${var.vmid_build_front} -- apk add openssh &&
     pct exec ${var.vmid_build_front} -- apk add python3 &&
     pct exec ${var.vmid_build_front} -- rc-update add sshd &&
     pct exec ${var.vmid_build_front} -- sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config &&
     pct exec ${var.vmid_build_front} -- rc-service sshd start"
EOT
  }
}









resource "proxmox_lxc" "build_back" {
  vmid       = var.vmid_build_back
  hostname   = "build-back"
  target_node = "proxmox"

  ostemplate = "local:vztmpl/alpine-3.22-default_20250617_amd64.tar.xz"

  cores      = 4
  memory     = 2048
  swap       = 256
  
  rootfs {
    storage = var.proxmox_disk
    size    = "15G"
  }
  
  network {
    name   = "eth0"
    bridge = "vmbr0"
    gw     = var.gateway_ip
    ip     = "${var.build_back_ip}/24"
    ip6    = "auto"
  }

  unprivileged = false
  start = true
  password = var.node_pass_build

}
resource "null_resource" "setup_ssh_build_back" {
  depends_on = [proxmox_lxc.build_back]

  provisioner "local-exec" {
    command = <<EOT
ssh-keygen -f ~/.ssh/known_hosts -R ${var.build_back_ip}
sleep 15
sshpass -p "${var.proxmox_password}" \
ssh -o StrictHostKeyChecking=no \
    -o HostKeyAlgorithms=+ssh-rsa \
    -o PubkeyAcceptedAlgorithms=+ssh-rsa \
    root@${var.proxmox_host} \
    "pct exec ${var.vmid_build_back} -- apk update &&
     pct exec ${var.vmid_build_back} -- apk add openssh &&
     pct exec ${var.vmid_build_back} -- apk add python3 &&
     pct exec ${var.vmid_build_back} -- rc-update add sshd &&
     pct exec ${var.vmid_build_back} -- sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config &&
     pct exec ${var.vmid_build_back} -- rc-service sshd start"
EOT
  }
}