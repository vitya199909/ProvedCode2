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


resource "proxmox_lxc" "nginx" {
  vmid       = var.vmid_nginx
  hostname   = "nginx"
  target_node = "proxmox"

  ostemplate = "local:vztmpl/alpine-3.22-default_20250617_amd64.tar.xz"

  cores      = 4
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
    ip     = "${var.nginx_ip}/24"
    ip6    = "auto"
  }

  unprivileged = false
  start = false
  password = var.node_pass_nginx

}
resource "null_resource" "enable_nesting_nginx" {
  depends_on = [proxmox_lxc.nginx]

  provisioner "local-exec" {
    command = <<EOT
sshpass -p "${var.proxmox_password}" \
ssh -o StrictHostKeyChecking=no \
    -o HostKeyAlgorithms=+ssh-rsa \
    -o PubkeyAcceptedAlgorithms=+ssh-rsa \
    root@${var.proxmox_host} \
    "pct set ${var.vmid_nginx} -features nesting=1,keyctl=1 && \
     echo 'lxc.apparmor.profile: unconfined' >> /etc/pve/lxc/${var.vmid_nginx}.conf && \
     echo 'lxc.cap.drop:' >> /etc/pve/lxc/${var.vmid_nginx}.conf && \
     (pct status ${var.vmid_nginx} | grep -q running || pct start ${var.vmid_nginx})"
EOT
  }
}

resource "null_resource" "setup_ssh_nginx" {
  depends_on = [null_resource.enable_nesting_nginx]

  provisioner "local-exec" {
    command = <<EOT
ssh-keygen -f ~/.ssh/known_hosts -R ${var.nginx_ip}
sleep 15
sshpass -p "${var.proxmox_password}" \
ssh -o StrictHostKeyChecking=no \
    -o HostKeyAlgorithms=+ssh-rsa \
    -o PubkeyAcceptedAlgorithms=+ssh-rsa \
    root@${var.proxmox_host} \
    "pct exec ${var.vmid_nginx} -- apk update &&
     pct exec ${var.vmid_nginx} -- apk add openssh &&
     pct exec ${var.vmid_nginx} -- apk add python3 &&
     pct exec ${var.vmid_nginx} -- rc-update add sshd &&
     pct exec ${var.vmid_nginx} -- sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config &&
     pct exec ${var.vmid_nginx} -- rc-service sshd start"
EOT
  }
}










resource "proxmox_lxc" "backend1" {
  vmid       = var.vmid_backend1
  hostname   = "backend1"
  target_node = "proxmox"

  ostemplate = "local:vztmpl/alpine-3.22-default_20250617_amd64.tar.xz"

  cores      = 4
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
    ip     = "${var.backend1_ip}/24"
    ip6    = "auto"
  }

  unprivileged = false
  start = false
  password = var.node_pass_backend

}
resource "null_resource" "enable_nesting_backend1" {
  depends_on = [proxmox_lxc.backend1]

  provisioner "local-exec" {
    command = <<EOT
sshpass -p "${var.proxmox_password}" \
ssh -o StrictHostKeyChecking=no \
    -o HostKeyAlgorithms=+ssh-rsa \
    -o PubkeyAcceptedAlgorithms=+ssh-rsa \
    root@${var.proxmox_host} \
    "pct set ${var.vmid_backend1} -features nesting=1,keyctl=1 && \
     echo 'lxc.apparmor.profile: unconfined' >> /etc/pve/lxc/${var.vmid_backend1}.conf && \
     echo 'lxc.cap.drop:' >> /etc/pve/lxc/${var.vmid_backend1}.conf && \
     (pct status ${var.vmid_backend1} | grep -q running || pct start ${var.vmid_backend1})"
EOT
  }
}

resource "null_resource" "setup_ssh_backend1" {
  depends_on = [null_resource.enable_nesting_backend1]

  provisioner "local-exec" {
    command = <<EOT
ssh-keygen -f ~/.ssh/known_hosts -R ${var.backend1_ip}
sleep 15
sshpass -p "${var.proxmox_password}" \
ssh -o StrictHostKeyChecking=no \
    -o HostKeyAlgorithms=+ssh-rsa \
    -o PubkeyAcceptedAlgorithms=+ssh-rsa \
    root@${var.proxmox_host} \
    "pct exec ${var.vmid_backend1} -- apk update &&
     pct exec ${var.vmid_backend1} -- apk add openssh &&
     pct exec ${var.vmid_backend1} -- apk add python3 &&
     pct exec ${var.vmid_backend1} -- rc-update add sshd &&
     pct exec ${var.vmid_backend1} -- sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config &&
     pct exec ${var.vmid_backend1} -- rc-service sshd start"
EOT
  }
}










resource "proxmox_lxc" "backend2" {
  vmid       = var.vmid_backend2
  hostname   = "backend2"
  target_node = "proxmox"

  ostemplate = "local:vztmpl/alpine-3.22-default_20250617_amd64.tar.xz"

  cores      = 4
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
    ip     = "${var.backend2_ip}/24"
    ip6    = "auto"
  }

  unprivileged = false
  start = false
  password = var.node_pass_backend

}
resource "null_resource" "enable_nesting_backend2" {
  depends_on = [proxmox_lxc.backend2]

  provisioner "local-exec" {
    command = <<EOT
sshpass -p "${var.proxmox_password}" \
ssh -o StrictHostKeyChecking=no \
    -o HostKeyAlgorithms=+ssh-rsa \
    -o PubkeyAcceptedAlgorithms=+ssh-rsa \
    root@${var.proxmox_host} \
    "pct set ${var.vmid_backend2} -features nesting=1,keyctl=1 && \
     echo 'lxc.apparmor.profile: unconfined' >> /etc/pve/lxc/${var.vmid_backend2}.conf && \
     echo 'lxc.cap.drop:' >> /etc/pve/lxc/${var.vmid_backend2}.conf && \
     (pct status ${var.vmid_backend2} | grep -q running || pct start ${var.vmid_backend2})"
EOT
  }
}

resource "null_resource" "setup_ssh_backend2" {
  depends_on = [null_resource.enable_nesting_backend2]

  provisioner "local-exec" {
    command = <<EOT
ssh-keygen -f ~/.ssh/known_hosts -R ${var.backend2_ip}
sleep 15
sshpass -p "${var.proxmox_password}" \
ssh -o StrictHostKeyChecking=no \
    -o HostKeyAlgorithms=+ssh-rsa \
    -o PubkeyAcceptedAlgorithms=+ssh-rsa \
    root@${var.proxmox_host} \
    "pct exec ${var.vmid_backend2} -- apk update &&
     pct exec ${var.vmid_backend2} -- apk add openssh &&
     pct exec ${var.vmid_backend2} -- apk add python3 &&
     pct exec ${var.vmid_backend2} -- rc-update add sshd &&
     pct exec ${var.vmid_backend2} -- sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config &&
     pct exec ${var.vmid_backend2} -- rc-service sshd start"
EOT
  }
}










resource "proxmox_lxc" "backend3" {
  vmid       = var.vmid_backend3
  hostname   = "backend3"
  target_node = "proxmox"

  ostemplate = "local:vztmpl/alpine-3.22-default_20250617_amd64.tar.xz"

  cores      = 4
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
    ip     = "${var.backend3_ip}/24"
    ip6    = "auto"
  }

  unprivileged = false
  start = false
  password = var.node_pass_backend

}
resource "null_resource" "enable_nesting_backend3" {
  depends_on = [proxmox_lxc.backend3]

  provisioner "local-exec" {
    command = <<EOT
sshpass -p "${var.proxmox_password}" \
ssh -o StrictHostKeyChecking=no \
    -o HostKeyAlgorithms=+ssh-rsa \
    -o PubkeyAcceptedAlgorithms=+ssh-rsa \
    root@${var.proxmox_host} \
    "pct set ${var.vmid_backend3} -features nesting=1,keyctl=1 && \
     echo 'lxc.apparmor.profile: unconfined' >> /etc/pve/lxc/${var.vmid_backend3}.conf && \
     echo 'lxc.cap.drop:' >> /etc/pve/lxc/${var.vmid_backend3}.conf && \
     (pct status ${var.vmid_backend3} | grep -q running || pct start ${var.vmid_backend3})"
EOT
  }
}

resource "null_resource" "setup_ssh_backend3" {
  depends_on = [null_resource.enable_nesting_backend3]

  provisioner "local-exec" {
    command = <<EOT
ssh-keygen -f ~/.ssh/known_hosts -R ${var.backend3_ip}
sleep 15
sshpass -p "${var.proxmox_password}" \
ssh -o StrictHostKeyChecking=no \
    -o HostKeyAlgorithms=+ssh-rsa \
    -o PubkeyAcceptedAlgorithms=+ssh-rsa \
    root@${var.proxmox_host} \
    "pct exec ${var.vmid_backend3} -- apk update &&
     pct exec ${var.vmid_backend3} -- apk add openssh &&
     pct exec ${var.vmid_backend3} -- apk add python3 &&
     pct exec ${var.vmid_backend3} -- rc-update add sshd &&
     pct exec ${var.vmid_backend3} -- sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config &&
     pct exec ${var.vmid_backend3} -- rc-service sshd start"
EOT
  }
}