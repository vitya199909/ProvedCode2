terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.2-rc07"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.proxmox_endpoint
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure     = true
}


resource "proxmox_lxc" "db" {
  vmid       = var.vmid_db
  hostname   = "db"
  target_node = "proxmox"

  ostemplate = "local:vztmpl/alpine-3.22-default_20250617_amd64.tar.xz"

  cores      = 1
  memory     = 512
  swap       = 256
  
  rootfs {
    storage = var.proxmox_disk
    size    = "5G"
  }
  
  network {
    name   = "eth0"
    bridge = "vmbr0"
    gw     = var.gateway_ip
    ip     = var.db_ip
    ip6    = "auto"
  }

  unprivileged = false
  start = true
  password = var.node_pass_db

}
resource "null_resource" "setup_ssh" {
  depends_on = [proxmox_lxc.db]

  provisioner "local-exec" {
    command = <<EOT
ssh-keygen -f ~/.ssh/known_hosts -R ${var.db_ip}
sleep 15
sshpass -p "${var.proxmox_password}" \
ssh -o StrictHostKeyChecking=no \
    -o HostKeyAlgorithms=+ssh-rsa \
    -o PubkeyAcceptedAlgorithms=+ssh-rsa \
    root@${var.proxmox_host} \
    "pct exec ${var.vmid_db} -- apk update &&
     pct exec ${var.vmid_db} -- apk add openssh &&
     pct exec ${var.vmid_db} -- apk add python3 &&
     pct exec ${var.vmid_db} -- rc-update add sshd &&
     pct exec ${var.vmid_db} -- sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config &&
     pct exec ${var.vmid_db} -- rc-service sshd start"
EOT
  }
}