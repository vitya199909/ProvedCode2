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


resource "proxmox_lxc" "jenkins" {
  vmid       = var.vmid_jenkins
  hostname   = "jenkins"
  target_node = "proxmox"

  ostemplate = "local:vztmpl/alpine-3.22-default_20250617_amd64.tar.xz"

  cores      = 1
  memory     = 1024
  swap       = 256
  
  rootfs {
    storage = var.proxmox_disk
    size    = "20G"
  }
  
  network {
    name   = "eth0"
    bridge = "vmbr0"
    gw     = var.gateway_ip
    ip     = "${var.jenkins_ip}/24"
    ip6    = "auto"
  }

  unprivileged = false
  start = false
  password = var.node_pass_jenkins

}
resource "null_resource" "enable_nesting" {
  depends_on = [proxmox_lxc.jenkins]

  provisioner "local-exec" {
    command = <<EOT
sshpass -p "${var.proxmox_password}" \
ssh -o StrictHostKeyChecking=no \
    -o HostKeyAlgorithms=+ssh-rsa \
    -o PubkeyAcceptedAlgorithms=+ssh-rsa \
    root@${var.proxmox_host} \
    "pct set ${var.vmid_jenkins} -features nesting=1,keyctl=1 && \
     echo 'lxc.apparmor.profile: unconfined' >> /etc/pve/lxc/${var.vmid_jenkins}.conf && \
     echo 'lxc.cap.drop:' >> /etc/pve/lxc/${var.vmid_jenkins}.conf && \
     pct start ${var.vmid_jenkins}"
EOT
  }
}

resource "null_resource" "setup_ssh_jenkins" {
  depends_on = [null_resource.enable_nesting]

  provisioner "local-exec" {
    command = <<EOT
ssh-keygen -f ~/.ssh/known_hosts -R ${var.jenkins_ip}
sleep 15
sshpass -p "${var.proxmox_password}" \
ssh -o StrictHostKeyChecking=no \
    -o HostKeyAlgorithms=+ssh-rsa \
    -o PubkeyAcceptedAlgorithms=+ssh-rsa \
    root@${var.proxmox_host} \
    "pct exec ${var.vmid_jenkins} -- apk update &&
     pct exec ${var.vmid_jenkins} -- apk add openssh &&
     pct exec ${var.vmid_jenkins} -- apk add python3 &&
     pct exec ${var.vmid_jenkins} -- rc-update add sshd &&
     pct exec ${var.vmid_jenkins} -- sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config &&
     pct exec ${var.vmid_jenkins} -- rc-service sshd start"
EOT
  }
}