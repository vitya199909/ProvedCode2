variable "proxmox_host" {
  type = string
}
variable "proxmox_endpoint" {
  type = string
}
variable "proxmox_api_token_id" {
  type      = string
}
variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}
variable "proxmox_username" {
  type      = string
}
variable "proxmox_password" {
  type      = string
  sensitive = true
}
variable "proxmox_disk" {
  type      = string
}



variable "vmid_nginx" {
  type      = number
}
variable "vmid_backend1" {
  type      = number
}
variable "vmid_backend2" {
  type      = number
}
variable "vmid_backend3" {
  type      = number
}
variable "gateway_ip" {
  type      = string
}
variable "nginx_ip" {
  type      = string
}
variable "backend1_ip" {
  type      = string
}
variable "backend2_ip" {
  type      = string
}
variable "backend3_ip" {
  type      = string
}


variable "node_pass_nginx" {
  type      = string
  sensitive = true
}
variable "node_pass_backend" {
  type      = string
  sensitive = true
}
variable "ssh_public_key" {
  type      = string
  sensitive = true
}